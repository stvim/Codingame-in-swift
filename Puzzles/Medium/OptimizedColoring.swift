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
/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

typealias CellPos = (x:Int,y:Int)

var grid = [[WhiteCell?]]()

struct WhiteCell {
    let subArea : Int

    static func previousNeighborsOfWhiteCell(i:Int, j:Int) -> [WhiteCell] {
        var result = [WhiteCell]()

        let appendCellInResultIfExists : (Int,Int) -> () = { (x,y) in
            if x>=0, y>=0 {
                if let cell = grid[x][y] {
                    result.append(cell)
                }
            }
        }
        appendCellInResultIfExists(i-1,j)
        appendCellInResultIfExists(i,j-1)
        return result
    }

     static func previousAdjacentsOfWhiteCell(i:Int, j:Int) -> [WhiteCell] {
        var result = [WhiteCell]()

        func appendCellInResultIfExists(_ pos:CellPos, withWallOn wallPos: CellPos) {
            if pos.x>=0, pos.y>=0 {
                if let cell = grid[pos.x][pos.y] {
                    if grid[wallPos.x][wallPos.y] == nil {
                        result.append(cell)
                    }
                }
            }
        }
        
        appendCellInResultIfExists( (x:i-2,y:j), withWallOn: (x:i-1,y:j))
        appendCellInResultIfExists( (x:i-2,y:j-1), withWallOn: (x:i-1,y:j-1))
        appendCellInResultIfExists( (x:i-1,y:j-2), withWallOn: (x:i-1,y:j-1))
        appendCellInResultIfExists( (x:i,y:j-2), withWallOn: (x:i,y:j-1))
        return result
    }
}

func optimizedColoring() {
    let w = Int(readLine()!)!
    let h = Int(readLine()!)!
    var boolGrid = [[Bool]]()
    
    var subAreaLinks = [Set<Int>]()
    
    var subAreaAdjacents = [Set<Int>]()
    
    /* bad algorithm - not using flood-filling as it should, but discovering 'subareas' while reading input and then applying a fusion between subareas to construct areas */
    if h > 0 {
        for i in 0...(h-1) {
            let line = readLine()!
//            print(line, to: &errStream)
            
            boolGrid.append(line.map{ $0 == " " })
            
            grid.append([])
            
            for j in 0 ..< w {
                if !boolGrid[i][j] {
                    grid[i].append(nil)
                } else {
                    
                    let whitePreviousNeighbors = WhiteCell.previousNeighborsOfWhiteCell(i:i, j:j)
                    
                    let subArea : Int
                    if whitePreviousNeighbors.count == 2 {
                        if whitePreviousNeighbors[0].subArea != whitePreviousNeighbors[1].subArea {
                            subAreaLinks[whitePreviousNeighbors[0].subArea].insert(whitePreviousNeighbors[1].subArea)
                            subAreaLinks[whitePreviousNeighbors[1].subArea].insert(whitePreviousNeighbors[0].subArea)
                        }
                        subArea = whitePreviousNeighbors[0].subArea
                        
                    } else if whitePreviousNeighbors.count == 1 {
                        subArea = whitePreviousNeighbors[0].subArea
                    } else {
                        subArea = subAreaLinks.count
                        subAreaLinks.append(Set())
                        subAreaAdjacents.append(Set())
                    }
                    
                    for previousAdjacent in WhiteCell.previousAdjacentsOfWhiteCell(i:i, j:j) {
                        subAreaAdjacents[subArea].insert(previousAdjacent.subArea)
                    }
                    
                    grid[i].append(WhiteCell(subArea: subArea))
                }
                
            }
        }
    }
    
    
    for subArea in subAreaLinks.indices {
        subAreaLinks[subArea].insert(subArea)
        
        let currentLinks = subAreaLinks[subArea]
        
        for link in subAreaLinks[subArea] {
            subAreaLinks[link].formUnion(currentLinks)
        }
    }
    
    var uniqueAreaBySubArea = [Int?](repeating: nil, count: subAreaLinks.count)
    var areasNum = 0
    for uniqueSubAreasGroup in Set<Set<Int>>(subAreaLinks) {
        for subAreaNum in uniqueSubAreasGroup {
            uniqueAreaBySubArea[subAreaNum] = areasNum
        }
        areasNum += 1
    }

    var areaAdjacents = [Set<Int>](repeating: Set(), count: areasNum)
    for i in 0 ..< areasNum {
        let subAreasOfThisArea = uniqueAreaBySubArea.enumerated().filter{ $0.element == i}.map{ $0.offset }
        for subArea in subAreasOfThisArea {
            for adjacentSubArea in subAreaAdjacents[subArea] {
                if let adjacentArea = uniqueAreaBySubArea[adjacentSubArea], adjacentArea != i {
                    areaAdjacents[i].insert( adjacentArea )
                    areaAdjacents[adjacentArea].insert( i )
                }
            }
        }
    }
    
    
    /* bad algorithm - it is working by chance */
    var colorByArea = [Int?](repeating: nil, count: areasNum)
    var allColors = Set<Int>()
    
    var areasToVisit = areaAdjacents.enumerated().sorted(by: { $0.element.count < $1.element.count }).map{ $0.offset }
    
    var nextToVisit : [Int] = []
    while !areasToVisit.isEmpty {
        let area : Int
        nextToVisit = nextToVisit.filter{ areasToVisit.contains($0) }
        if nextToVisit.count > 0 {
            area = nextToVisit.removeFirst()
            areasToVisit.remove(at: areasToVisit.firstIndex(of: area)!)
        } else {
            area = areasToVisit.removeLast()
        }
        
        let adjacentColors = Set( areaAdjacents[area].compactMap{ colorByArea[$0] } )
        if let color = allColors.subtracting(adjacentColors).first {
            colorByArea[area] = color
        } else {
            let color = allColors.count
            allColors.insert(color)
            colorByArea[area] = color
        }
        
        nextToVisit.append(contentsOf: areaAdjacents[area])
    }
            
    
    // Write an answer using print("message...")
    // To debug: print("Debug messages...", to: &errStream)
    // print(grid)
    print(areaAdjacents, to: &errStream)
    print(allColors.count)
}

//optimizedColoring()
