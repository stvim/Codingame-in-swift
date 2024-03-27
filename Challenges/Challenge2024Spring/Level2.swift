/********************* HEADER ****************/
#if canImport(CodingameCommon)
import CodingameCommon
import Darwin
#else
import Glibc
public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

public let defaultTerminator = "\n",defaultSeparator = " "

//public func print(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) -> Void {
//    let output = args.map{"\($0)"}.joined(separator: separator)
//    Dialog.allOutputs.append(output)
//    Swift.print(output,terminator: terminator)
//    debug("-- all inputs --\n", Dialog.allInputs.joined(separator: "\n"), "\n------------")
//    debug("-- all outputs --\n", Dialog.allOutputs.joined(separator: "\n"), "\n------------")
//}

public func debug(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print(output, terminator: terminator, to: &errStream)
}

struct Dialog {
    static var allInputs : [String] = []
    static var allOutputs : [String] = []
}
public func readLine() -> String? {
    return readLine("")
}
public func readLine(_ message:String) -> String? {
    let r = Swift.readLine()
    if let r = r { Dialog.allInputs.append(r) }
    return r
}
#endif
import Foundation
/********************* END of HEADER ****************/


import Foundation

// Ignore and do not change the code below
//let encoder = JSONEncoder()
//encoder.outputFormatting = .withoutEscapingSlashes

/**
 * Try a solution
 */
//func trySolution(commands: [String]) {
//    print("" + String(String(data: try! encoder.encode([commands]), encoding: .utf8)!.dropLast().dropFirst()))
//}
// Ignore and do not change the code above

/**
 * - parameter n: The size of the image
 * - parameter targetImage: The rows of the desired image, from top to bottom
 */


//func level2(n:Int) {
//
//
//
//    // game loop
//    while true {
//        let commands = readLine()!.split(separator: " ")
//        guard n > 0 else { continue }
//
//        switch(commands[0]) {
//            case "C":
//                let columnToFill = Int(commands[1])!
//                canvas.indices.forEach{
//                    row in
//                    canvas[row][columnToFill] = true
//                }
//
//            case "R":
//                let rowToDelete = Int(commands[1])!
//                canvas[rowToDelete] = [Bool](repeating: false, count:n)
//            default: break
//        }
//                // Write an action using print("message...")
//                // To debug: print("Debug messages...", to: &errStream)
//
//
//                printCanvas(canvas)
//
//    }
//}

func printCanvas(_ input:[[Bool]]) {
    input.forEach {
        line in
        debug(line.map{ $0 ? "#" : "." }.joined() )
    }
}



// Ignore and do not change the code below
//let decoder = JSONDecoder()
//trySolution(commands: solve(
//    n: try! decoder.decode([Int].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
//    targetImage: try! decoder.decode([[String]].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0]
//)!)

// Ignore and do not change the code above



