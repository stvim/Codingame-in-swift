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
    
    if verboseDebug {
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

func main() {
    let n = Int(readLine()!)!
    if n > 0 {
        for _ in 0...(n-1) {
            let s = readLine()!
            print(s.transformed)
        }
    }
}

extension String {
    var transformed : String {
        var result = ""
        var toTreat = self
        while let end = toTreat.firstIndex(of: "!") {
            let currentPart = toTreat[toTreat.startIndex...end]
            let start = currentPart.lastIndex(where: { $0 == " " || $0 == "!"}) ?? currentPart.startIndex
            
            if start > currentPart.startIndex {
                result += currentPart[currentPart.startIndex..<start]
            }
            result += currentPart[start..<currentPart.endIndex].uppercased()
            
            toTreat = String(toTreat[ toTreat.index(after: end)..<toTreat.endIndex ])
        }
        result += toTreat
        return result
    }
}



// Write an answer using print("message...")
// To debug: print("Debug messages...", to: &errStream)

// print("write A sentence for you passengers.")
