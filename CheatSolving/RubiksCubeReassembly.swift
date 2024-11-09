/********************* HEADER ****************/
#if canImport(CodingameCommon)
import CodingameCommon
import Darwin
#else
import Glibc
struct Config {
    static let verboseDebug = false
}

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

extension String {
    public static let eol = "\n"
    public static let empty = ""
    public static let defaultTerminator = eol
    public static let defaultSeparator = " "
}

public func print(_ args:Any..., separator:String = .defaultSeparator, terminator:String = .defaultTerminator) -> Void {
    let output = args.map{"\($0)"}.joined(separator: separator)
    
    Dialog.allOutputs.append(output)
    Swift.print(output,terminator: terminator)
}

public func debug(_ args:Any..., separator:String = .defaultSeparator, terminator:String = .defaultTerminator) {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print(output, terminator: terminator, to: &errStream)
    
    if Dialog.verboseDebug {
        Swift.print("-- all inputs ---", Dialog.allInputs.joined(separator: .eol), separator: .eol, to: &errStream)
        Swift.print("-- all outputs --", Dialog.allOutputs.joined(separator: .eol), separator: .eol, to: &errStream)
        Swift.print("-----------------", to: &errStream)
    }
}

struct Dialog {
    static var allInputs : [String] = []
    static var allOutputs : [String] = []
    static var verboseDebug : Bool { Config.verboseDebug }
}
public func readLine() -> String? {
    return readLine(nil)
}
public func readLine(_ message:String?) -> String? {
    let inputLine = Swift.readLine()
    if let inputLine = inputLine {
        if let message = message {
            Dialog.allInputs.append(" > \(message) > \(inputLine)")
        } else {
            Dialog.allInputs.append(inputLine)
        }
    }
    return inputLine
}
#endif
import Foundation
/********************* END of HEADER ****************/
extension Int {
    static let faceSize = 3
}

enum Sticker : String, CaseIterable {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
    case front = "F"
    case back = "B"
}

struct Piece : Hashable, CustomStringConvertible {
    var stickers: [Sticker] = []
    var description: String { stickers.map(\.rawValue).joined(separator: "-") }
}


/// Works for rows and for columns
func indicesInPattern(forFacePosition: Int) -> Range<Int> {
    return (.faceSize+1) * forFacePosition ..< ((.faceSize+1) * (forFacePosition+1) - 1)
}

func readPattern() -> [[String]] {
    var pattern = [[String]]()
    for _ in 0 ..< indicesInPattern(forFacePosition: 2).endIndex {
        pattern.append(readLine()!.map(String.init))
    }
    return pattern
}


struct Cube {

    init (pattern: [[String]]) {
        // reading vertical faces - filling vertical faces columns of pieces
        do {
            let patternRowOffset = indicesInPattern(forFacePosition: 1).lowerBound
            let patternLeftEdgesColumns = (0...3).map{ indicesInPattern(forFacePosition: $0).lowerBound }
            let patternStickerColumns = (0...3).flatMap{ indicesInPattern(forFacePosition: $0) }
            
            var verticalFacesColumnsIndex = 0
            
            for patternColumn in patternStickerColumns {
                if !patternLeftEdgesColumns.contains(patternColumn) {
                    verticalFacesColumnsIndex += 1
                    verticalFacesColumnsIndex %= verticalFacesColumns.count
                }
                
                for verticalPieceIndex in 0...(.faceSize-1) {
                    let patternLine: Int = patternRowOffset + verticalPieceIndex
                    let patternValue = pattern[patternLine][patternColumn]
                    
                    verticalFacesColumns[verticalFacesColumnsIndex][verticalPieceIndex].stickers.append(
                        Sticker(rawValue: patternValue)!
                    )
                }
            }
            
            // reverse order of the first  column (it has been filled in the reversed order)
            verticalFacesColumns[0].indices.forEach {
                verticalFacesColumns[0][$0].stickers.reverse()
            }
            // reverse order of the last element of each column = bottom edges (they have been filled in the reversed order)
            verticalFacesColumns.indices.forEach {
                verticalFacesColumns[$0][.faceSize-1].stickers.reverse()
            }
        }
        
        // reading the face up - filling only the 4 top edges pieces of verticalFacesColumns
        do {
            let faceUpEdgesIndicesInPattern = traverseEdgesOfSquaredMatrix(matrixSize: .faceSize, from: .topLeft, direction: .counterclockwise)
                .map{ (row: $0.row + indicesInPattern(forFacePosition: 0).lowerBound
                       , column: $0.column + indicesInPattern(forFacePosition: 1).lowerBound) }
            
            let verticalIndex = 0
            
            for verticalFacesColumnsIndex in 0..<verticalFacesColumns.count {
                let faceUpPatternValue = pattern[ faceUpEdgesIndicesInPattern[verticalFacesColumnsIndex].row ] [ faceUpEdgesIndicesInPattern[verticalFacesColumnsIndex].column ]
                verticalFacesColumns[verticalFacesColumnsIndex][verticalIndex].stickers.append(
                    Sticker(rawValue: faceUpPatternValue)!
                )
            }
        }
        
        // reading the face down - filling only the 4 bottom edges pieces of verticalFacesColumns
        do {
            let faceDownEdgesIndicesInPattern = traverseEdgesOfSquaredMatrix(matrixSize: .faceSize, from: .bottomLeft, direction: .clockwise)
                .map{ (row: $0.row + indicesInPattern(forFacePosition: 2).lowerBound
                       , column: $0.column + indicesInPattern(forFacePosition: 1).lowerBound) }
            
            let verticalIndex = .faceSize - 1
            
            for verticalFacesColumnsIndex in 0..<verticalFacesColumns.count {
                let faceDownPatternValue = pattern[ faceDownEdgesIndicesInPattern[verticalFacesColumnsIndex].row ] [ faceDownEdgesIndicesInPattern[verticalFacesColumnsIndex].column ]
                verticalFacesColumns[verticalFacesColumnsIndex][verticalIndex].stickers.append(
                    Sticker(rawValue: faceDownPatternValue)!
                )
            }
        }
//        debug(verticalFacesColumns.map(\.description).joined(separator: "\n"))
    }
    
    typealias PiecesColumn = [Piece]
    
    var verticalFacesColumns: [PiecesColumn] = {
        var columns : [PiecesColumn] = []
        for _ in 0 ..< (.faceSize-1) * 4 {
            columns.append( [Piece](repeating: Piece(), count: .faceSize))
        }
        return columns
    }()
    
    var allEdges: Set<Piece> {
        Set<Piece>(verticalFacesColumns.flatMap{ $0 }.filter{ $0.stickers.count > 1 })
    }
}


enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
enum Direction { case clockwise, counterclockwise }

func traverseEdgesOfSquaredMatrix(matrixSize n: Int, from startCorner: Corner, direction: Direction) -> [(row:Int, column:Int)] {
    var result = [(Int, Int)]()
    let lastIndex = n - 1
    
    let start : (Int, Int) = {
        switch startCorner {
        case .topLeft:     return (0, 0)
        case .topRight:    return (0, lastIndex)
        case .bottomLeft:  return (lastIndex, 0)
        case .bottomRight: return (lastIndex, lastIndex)
        }
    }()
    
    var (i, j) = start
    
    let nextStep: (Int, Int) -> (Int, Int) = { (i, j) in
        switch direction {
        case .clockwise:
            if j < lastIndex && i == 0 {
                return (i, j + 1)
            } else if i < lastIndex && j == lastIndex {
                return (i + 1, j)
            } else if j > 0 && i == lastIndex {
                return (i, j - 1)
            } else {
                return (i - 1, j)
            }
        case .counterclockwise:
            if i < lastIndex && j == 0 {
                return (i + 1, j)
            } else if j < lastIndex && i == lastIndex {
                return (i, j + 1)
            } else if i > 0 && j == lastIndex {
                return (i - 1, j)
            } else {
                return (i, j - 1)
            }
        }
    }
    
    for _ in 0 ..< (4 * (n - 1)) {
        result.append((i, j))
        (i, j) = nextStep(i, j)
    }

    return result
}


func checkSolvablePieces(pieces:Set<Piece>) -> Bool {
    
    for sticker in Sticker.allCases {
        let currentStickerPieces = pieces.filter{ $0.stickers.contains(sticker) }
        
        let otherStickersOnSamePieces = Set(currentStickerPieces.flatMap(\.stickers).filter{ $0 != sticker })
        
        guard otherStickersOnSamePieces.count == 4 else {
            return false
        }
        
        for secondSticker in otherStickersOnSamePieces {
            
            let cornersWithSecondSticker = currentStickerPieces
                .filter{ $0.stickers.contains(secondSticker) }
                .filter{ $0.stickers.count == 3 }
            
            guard cornersWithSecondSticker.count == 2 else {
                return false
            }
            
            let cornersWithSecondStickerPair = { () -> (Piece, Piece) in
                var cornersWithSecondSticker = cornersWithSecondSticker
                return (cornersWithSecondSticker.popFirst()!, cornersWithSecondSticker.popFirst()!)
            }()
            
            guard cornersWithSecondStickerPair.0.isCornerComplementary(withOtherCorner: cornersWithSecondStickerPair.1, forStickers: (sticker, secondSticker)) else {
                return false
            }
        }
    }
    return true
}

extension Piece {
    func isCornerComplementary(withOtherCorner other: Self, forStickers stickerIds: (Sticker,Sticker)) -> Bool {
        
        let selfStickerIndices = (stickers.firstIndex(of: stickerIds.0)!, stickers.firstIndex(of: stickerIds.1)!)
        let otherStickerIndices = (other.stickers.firstIndex(of: stickerIds.0)!, other.stickers.firstIndex(of: stickerIds.1)!)
        
        func indicesOrderIsPositive(_ indices: (Int, Int)) -> Bool {
            let diff = indices.1 - indices.0
            let diffIsPositive = diff > 0
            
            switch abs(diff) {
            case 1: return diffIsPositive
            case 2: return !diffIsPositive
            default : fatalError()
            }
        }

        return indicesOrderIsPositive(selfStickerIndices) != indicesOrderIsPositive(otherStickerIndices)
    }
}

func RubiksCubeReassembly() {
    let pattern = readPattern()
    
    let cube = Cube(pattern: pattern)
    
    if checkSolvablePieces(pieces: cube.allEdges) {
        print("SOLVABLE")
    } else {
        print("UNSOLVABLE")
    }
}

//RubiksCubeReassembly()
