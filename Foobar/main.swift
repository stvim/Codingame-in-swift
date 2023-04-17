#if canImport(CodingameCommon)
import CodingameCommon
//import Darwin
#elseif canImport(DeathFirstSearchTests)
#else
//import Glibc
//public struct StderrOutputStream: TextOutputStream {
//    public mutating func write(_ string: String) { fputs(string, stderr) }
//}
//public var errStream = StderrOutputStream()
//
//public func debug(_ args:Any..., separator:String = " ", terminator:String = "\n") {
//    let output = arg.map{"\($0)"}.joined(separator: separator)
//    Swift.print("***", output, terminator: terminator, to: &errStream)
//}
//
//struct Dialog {
//    static var allInputs : [String] = []
//}
//public func readLine(_ message:String) -> String? {
//    let r = readLine()
//    if let r = r {
//        Dialog.allInputs.append(r)
//    }
//    return r
//}
#endif
import Foundation

internal func main() -> Void {
    let bundle = Bundle(for: DeathFirstSearchTests.self)
    let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
    Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: <#T##URL#>))
    var greeting = "Hello, playground"
    greeting = readLine("Please tell me")!
    debug("yes it s working")
    print(greeting, "!")
    
    greeting = readLine("Please tell me again")!
    print(greeting)

    print(Dialog.allInputs)
}


main()
