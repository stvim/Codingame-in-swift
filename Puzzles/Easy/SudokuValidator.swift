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

func sudokuValidator() {
    var grid = [[Int]]()
    
    for _ in 0...8 {
        grid.append(readLine()!.split(separator: " ").map{ Int($0)! })
    }
    
    
    if !grid.allSatisfy({ Set($0).count == 9 }) {
        print("false")
    } else if !((0...8).allSatisfy({ col in Set( (0...8).map{ row in grid[row][col]} ).count == 9 })) {
        print("false")
    } else {
        var subgrids = [Set<Int>](repeating: Set<Int>(), count: 9)
        
        for i in 0...8 {
            for j in 0...8 {
                let sj = j/3
                let si = i/3
                subgrids[(si*3)+sj].insert(grid[j][i])
            }
        }
        print(subgrids, to: &errStream)
        
        if subgrids.allSatisfy({ $0.count == 9}) {
            print("true")
        } else {
            print("false")
        }
    }
}

//sudokuValidator()
