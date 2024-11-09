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
//extension Int {
//    static let faceSize = 3
//}
//
//enum FaceId : String, CaseIterable {
//    case up = "U"
//    case down = "D"
//    case left = "L"
//    case right = "R"
//    case front = "F"
//    case back = "B"
//}
//typealias StickerId = FaceId
//
//extension String {
//    var isFaceId: Bool {
//        return FaceId.allCases.contains(where: { self.contains($0.rawValue) })
//    }
//}
//
//struct Piece : Hashable, CustomStringConvertible {
//    var stickers: [StickerId] = []
//    var description: String { stickers.map(\.rawValue).joined(separator: "-") }
//    
//    var twoSided: Bool {
//        stickers.count == 2
//    }
//    var threeSided: Bool {
//        stickers.count == 3
//    }
//        
//    
//    func isThreeSided(complementaryOf other: Self, withCommonStickerId mainStickerId: StickerId) -> Bool {
//        guard threeSided && other.threeSided else { return false }
//        
//        let selfStickers = Set(self.stickers)
//        let otherStickers = Set(other.stickers)
//        let commonStickers = selfStickers.intersection(otherStickers)
//        
//        guard selfStickers.contains(mainStickerId)
//                && selfStickers.count == 3
//                && otherStickers.contains(mainStickerId)
//                && otherStickers.count == 3
//                && commonStickers.count == 2 else
//        {
//            return false
//        }
//        
//        
//        
//        return zip(self, other).allSatisfy(\.0 == \.1)
//    }
//}
//
////struct Face {
////    var pieces = [[StickerId]]()
////}
//
//extension Array where Element == [StickerId] {
//    mutating func appendNewLine<C: Collection>(from inputCharacters: C) where C.Element == String {
//        self.append( inputCharacters.map { StickerId(rawValue: $0)! })
//    }
//}
//
//
///// Works for rows and for columns
//func indicesInPattern(forFacePosition: Int) -> Range<Int> {
//    return (.faceSize+1) * forFacePosition ..< ((.faceSize+1) * (forFacePosition+1) - 1)
//}
//


//struct Cube {
//    enum Axis : CaseIterable {
//        case x, y, z
//    }
//    static let sideIndices = (0..<Int.faceSize)
//
//
//    var pieces = {
//        sideIndices.forEach { x in
//            sideIndices.forEach { y in
//                sideIndices.forEach { z in
//
//                }
//            }
//        }
//    }()
//
//    private var rotationMatrix: [[Int]]
//
//    func frontPiece(i:Int, j:Int) -> Piece {
//
//    }
//
//    init(patternFaces: [FaceId:Face]) {
//        rotate(aroundAxis: .y, .positive)
//        patternFaces[.left]
//
//        rotate(aroundAxis: .y, .positive)
//        patternFaces[.back]
//
//        rotate(aroundAxis: .y, .positive)
//        patternFaces[.right]
//
//        rotate(aroundAxis: .y, .positive)
//        self.currentFrontFace.integrateStickers(of: patternFaces[.front])
//
//        rotate(aroundAxis: .x, .positive)
//        patternFaces[.up]
//
//        rotate(aroundAxis: .x, .positive)
//        rotate(aroundAxis: .x, .positive)
//        patternFaces[.down]
//    }
//}

//func readPatternFaces() -> [FaceId:Face] {
//    var patternFaces: [FaceId:Face] = [FaceId:Face](uniqueKeysWithValues: FaceId.allCases.map{ ($0, Face()) })
//
//    let verticalFaces : [(faceId:FaceId, horizontalPositionInPattern:Int)] = [(.left, 0), (.front, 1), (.right, 2), (.back, 3)]
//
//    for lineNumber in 0 ... indicesInPattern(forFacePosition: 2).endIndex {
//        let currentLine = readLine()!.map(String.init)
//
//        switch (lineNumber) {
//        case indicesInPattern(forFacePosition: 0):
//            patternFaces[.up]!.pieces.appendNewLine(
//                from: currentLine[ indicesInPattern(forFacePosition: 1) ]
//            )
//        case indicesInPattern(forFacePosition: 2):
//            patternFaces[.down]!.pieces.appendNewLine(
//                from: currentLine[ indicesInPattern(forFacePosition: 1) ]
//            )
//        case indicesInPattern(forFacePosition: 1) :
//            verticalFaces.forEach {
//                patternFaces[$0.faceId]!.pieces.appendNewLine(
//                    from: currentLine[ indicesInPattern(forFacePosition: $0.horizontalPositionInPattern) ]
//                )
//            }
//        default:
//            break
//        }
//    }
//    return patternFaces
//}


    
public func RubiksCubeReassemblyV2() {
    var pattern = [[String]]()
    for _ in 0 ..< indicesInPattern(forFacePosition: 2).endIndex {
        pattern.append(readLine()!.map(String.init))
    }
    
    let cube = Cube(pattern: pattern)
    
    if checkSolvablePieces(pieces: cube.allEdges) {
        print("SOLVABLE")
    } else {
        print("UNSOLVABLE")
    }
}



//RubiksCubeReassembly()
