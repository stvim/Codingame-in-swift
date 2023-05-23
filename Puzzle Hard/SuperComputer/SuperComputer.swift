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


 struct Task {
    let starts:Int
    let ends:Int
 }



struct CalcRange {
    var lowerBound,upperBound,value:Int
}
var calculations : [CalcRange] = [CalcRange(lowerBound: 0, upperBound: 1000000+1000, value: 0)]

var bestValue = 0

func quickSearchIndex(of:Int, lowerIndex:Int = 0, upperIndex:Int = calculations.count) -> Int {
    let i = (lowerIndex + upperIndex) / 2
    if calculations[i].lowerBound > of {
        return quickSearchIndex(of: of, lowerIndex: lowerIndex, upperIndex: i)
    }
    else if  calculations[i].upperBound < of {
        return quickSearchIndex(of: of, lowerIndex: i, upperIndex: upperIndex)
    }
    else {
        return i
    }
}


public func main() {
    var tasks = [Task]()
    
    let N = Int(readLine()!)!
    if N > 0 {
        for _ in 0...(N-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let J = Int(inputs[0])!
            let D = Int(inputs[1])!
            tasks.append(Task(starts: J, ends: J+D-1))
            print("\(J) \(J+D-1)", to: &errStream)
        }
    }
    tasks.sort{$0.ends < $1.ends}
    
    for task in tasks {
        let currRangeIndex = quickSearchIndex(of: task.starts)
        // let currRangeIndex = calculations.firstIndex(where: { $0.lowerBound <= task.starts && $0.upperBound >= task.starts })!
        
        let nextValue = calculations[currRangeIndex].value + 1
        if nextValue > bestValue { bestValue = nextValue }

        let nextRangeIndex = quickSearchIndex(of: task.ends+1)
        // let nextRangeIndex = calculations.firstIndex(where: { $0.lowerBound <= task.ends+1 && $0.upperBound >= task.ends+1 })!

        if calculations[nextRangeIndex].value < nextValue {
            if calculations[nextRangeIndex].lowerBound == task.ends+1 {
                calculations[nextRangeIndex].value = nextValue
            }
            else {
                // let nextRangeCopy = calculations[nextRangeIndex]
                let newRange = CalcRange(   lowerBound: task.ends+1,
                                            upperBound: calculations[nextRangeIndex].upperBound,
                                            value: nextValue)
                calculations[nextRangeIndex].upperBound = task.ends
                calculations.insert(newRange, at: nextRangeIndex+1)
            }
        }
    }
    
    
    print(calculations, to:&errStream)
    // Write an answer using print("message...")
    // To debug: print("Debug messages...", to: &errStream)
    print(bestValue)
    // print("answer")
    
}

//main()
