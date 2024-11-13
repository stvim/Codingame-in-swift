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

func temperatures() {
    let _ = Int(readLine()!)! // the number of temperatures to analyse

    let input = (readLine()!).split(separator: " ").compactMap{ Int($0) }

    if input.count == 0 {
        print(0)
    } else {
        var r = input[0]
        var absR = abs(r)

        if input.count > 1 {
            for i in input[1...] {
                let absI = abs(i)
                let absDiff = absR - absI
                if absDiff == 0 {
                    if r < 0 && i > 0 {
                        r = i
                    }
                } else if absDiff > 0 {
                    r = i
                    absR = absI
                }
            }
        }
        print(r)
    }
}

//temperatures()
// Write an answer using print("message...")
// To debug: print("Debug messages...", to: &errStream)

// print("result")
