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

 struct IslandEscape {
    static let shared : Self = .init()

    let N : Int
    let grid : [[Int]]

   
    private init() {
        N = Int(readLine()!)!
        var grid = [[Int]]()
        if N > 0 {
            for _ in 0...(N-1) {
                grid.append( (readLine()!).split(separator: " ").map{Int($0)!} )
            }
        }
        self.grid = grid
    }

    struct Position : Hashable {
        let i,j:Int
        var elevation : Int { IslandEscape.shared.grid[i][j] }

        func offset(_ d: (i:Int,j:Int)) -> Self {
            offset(d.i, d.j)
        }
        func offset(_ di:Int, _ dj:Int) -> Self {
            Self(i: i+di, j: j+dj)
        }

        var visitableNeighbors : Set<Position> {
            var result = Set<Position>()
            
            let addNeighborIfVisitable : (Self) -> () = {
                if IslandEscape.shared.grid.indices ~= $0.i && IslandEscape.shared.grid.indices ~= $0.i {
                    if -1...1 ~= ($0.elevation - self.elevation) {
                        result.insert($0)
                    }
                }
            }
            let offsets : [(Int,Int)] = [(1,0),(-1,0),(0,1),(0,-1)]
            offsets.forEach {
                addNeighborIfVisitable(self.offset($0))
            }

            return result
        }
    }

    func solution() -> Bool {

        var visitedCells = Set<Position>()
        var cellsToVisit = Set<Position>()

        let middle = (N-1)/2
        let startPos : Position = Position(i: middle, j: middle)

        cellsToVisit.insert(startPos)

        while let cell = cellsToVisit.popFirst() {

            for neighbor in cell.visitableNeighbors.subtracting(visitedCells) {
                if grid[neighbor.i][neighbor.j] == 0 {
                    return true
                } else {
                    cellsToVisit.insert(neighbor)
                }
            }

            visitedCells.insert(cell)
        }
        return false
    }
}

//print(IslandEscape.shared.solution() ? "yes" : "no")
