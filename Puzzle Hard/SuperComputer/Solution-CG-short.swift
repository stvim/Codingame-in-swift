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

class scientist{ //Classe de scientifiques
    let start:Int
    let time:Int
    init(s:Int, t:Int){
        self.start = s
        self.time = t
    }
}

public func main_solution_CG_short() {
    var scientists:[scientist]=[]
    var horaires:[Int] = [Int](repeating: 0, count: 1001003)
    let N = Int(readLine()!)!
    var s1 = 0 //Solution 1
    var s2 = 0 //Solution 2
    if N > 0 {
        for _ in 0...(N-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let J = Int(inputs[0])!
            let D = Int(inputs[1])!
            scientists.append(scientist(s: J, t: D))
        }
    }
    scientists.sort{$0.start > $1.start}
    for exp in scientists{
        if horaires[exp.start..<(exp.start+exp.time)].allSatisfy{$0==0}{
            s1+=1
            horaires.replaceSubrange(exp.start..<(exp.start+exp.time), with: repeatElement(1, count: exp.time))
        }
    }
    scientists.sort{$0.time < $1.time}
    for exp in scientists{
        if horaires[exp.start..<(exp.start+exp.time)].allSatisfy{$0==0}{
            s2+=1
            horaires.replaceSubrange(exp.start..<(exp.start+exp.time), with: repeatElement(1, count: exp.time))
        }
    }
    debug(s1,s2)
    print(max(s1, s2))
    
}

//main_solution_CG_short()
