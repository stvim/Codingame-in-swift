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

public func main() {
    let N = Int(readLine()!)!
    var m : [[Int]] = []
    let t = Array(1...N).map{_ in readLine()!.map{$0=="o" ? 1:0}}
    func f(_ i:Int, _ j:Int) -> Int {
        if i == N-1 { return t[N-1][j..<N].reduce(0,+) }
        if j == N-1 { return t[i..<N].map{$0.last!}.reduce(0,+) }
        return max( f(i+1,j), f(i,j+1)) + t[i][j] 
    }
    
    print(f(0,0))
    // Write an answer using print("message...")
    // To debug: print("Debug messages...", to: &errStream)
    
    // print("number of visited friends")
    
    
    print(m)
    
    //
    //I=input
    //n=int(I())
    //t=[I()for _ in range(n)]
    //def l(i,j):
    // if i>n-2:return t[i][j:].count("o")
    // if j>n-2:return [t[k][-1] for k in range(i,n)].count("o")
    // return max(l(i+1,j),l(i,j+1))+(t[i][j]>".")
    //I(l(0,0))
}
