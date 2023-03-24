#if canImport(CodingameCommon_v2)
import CodingameCommon_v2
import Darwin
#else
import Glibc
public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

public func debug(_ args:Any..., separator:String = " ", terminator:String = "\n") {
    let output = arg.map{"\($0)"}.joined(separator: separator)
    Swift.print("***", output, terminator: terminator, to: &errStream)
}

struct Dialog {
    static var allInputs : [String] = []
}
public func readLine(_ message:String) -> String? {
    if let r = readLine() {
        Dialog.allInputs.append(r)
        return r
    }
    else {
        return nil
    }
}
#endif
import Foundation

internal func main() -> Void {
    var greeting = "Hello, playground"
    greeting = readLine("Please tell me")!
    debug("yes it s working")
    print(greeting, "!")
    
    greeting = readLine("Please tell me again")!
    print(greeting)

    print(Dialog.allInputs)
}


main()
