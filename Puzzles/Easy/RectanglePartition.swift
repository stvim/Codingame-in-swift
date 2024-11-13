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

func rectanglePartition () {
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    
    // var horzSegmentSizes = [Int]()
    // var vertSegmentSizes = [Int]()
    
    var horzSegmentSizeOccurences = [Int:Int]()
    var vertSegmentSizeOccurences = [Int:Int]()
    
    var horzBounds = [Int]()
    var vertBounds = [Int]()
    
    let w = Int(inputs[0])!
    let h = Int(inputs[1])!
    let _ = Int(inputs[2])!    // countX§
    let _ = Int(inputs[3])!    // countY
    
    errStream.write("\(w) \(h)\n")
    
    func newSegmentSizes(newBound: Int, previousBounds: [Int] ) -> [Int] {
        
        var newSegmentSizes = [Int]()
        
        var currentSegmentSizeToAdd = newBound
        newSegmentSizes.append(currentSegmentSizeToAdd)
        for previousBound in previousBounds {
            currentSegmentSizeToAdd = newBound - previousBound
            newSegmentSizes.append(currentSegmentSizeToAdd)
        }
        
        return newSegmentSizes
    }
    
    
    for i in ((readLine()!).split(separator: " ").map(String.init)) {
        let x = Int(i)!
        errStream.write("\(x)\n")
        
        // horzSegmentSizes.append(contentsOf: newSegmentSizes(newBound: x, previousBounds: horzBounds))
        for newSegmentSize in newSegmentSizes(newBound: x, previousBounds: horzBounds) {
            horzSegmentSizeOccurences[newSegmentSize, default: 0] += 1
        }
        horzBounds.append(x)
    }
    // horzSegmentSizes.append(contentsOf: newSegmentSizes(newBound: w, previousBounds: horzBounds))
    for newSegmentSize in newSegmentSizes(newBound: w, previousBounds: horzBounds) {
        horzSegmentSizeOccurences[newSegmentSize, default: 0] += 1
    }
    
    for i in ((readLine()!).split(separator: " ").map(String.init)) {
        let y = Int(i)!
        errStream.write("\(y)\n")
        // vertSegmentSizes.append(contentsOf: newSegmentSizes(newBound: y, previousBounds: vertBounds))
        for newSegmentSize in newSegmentSizes(newBound: y, previousBounds: vertBounds) {
            vertSegmentSizeOccurences[newSegmentSize, default: 0] += 1
        }
        vertBounds.append(y)
    }
    // vertSegmentSizes.append(contentsOf: newSegmentSizes(newBound: h, previousBounds: vertBounds))
    for newSegmentSize in newSegmentSizes(newBound: h, previousBounds: vertBounds) {
        vertSegmentSizeOccurences[newSegmentSize, default: 0] += 1
    }
    
    // errStream.write("\(horzSegmentSizes)")
    
    var result = 0
    for segmentSize in horzSegmentSizeOccurences.keys {
        result += horzSegmentSizeOccurences[segmentSize]! * vertSegmentSizeOccurences[segmentSize, default: 0]
    }
    
    // Write an answer using print("message...")
    // To debug: print("Debug messages...", to: &errStream)
    
    print(result)
}
