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

struct Coordinates {
    public let x,y:Int
    init(_ x:Int, _ y:Int) {
        self.x = x
        self.y = y
    }
    func distanceTo(_ c:Coordinates) -> Double {
        sqrt(pow(Double(self.x - c.x),2.0)+pow(Double(self.y - c.y),2.0))
    }
}

struct GameTurn {
    let x:Int
    let y:Int
    let myPosition:Coordinates
    let nextCheckpoint:Coordinates
    let oppPosition:Coordinates
    
    let nextCheckpointDist:Int
    let nextCheckpointAngle:Int
    let opponentX:Int
    let opponentY:Int
    let nextCheckpointAngleAbs:Int
    
    init(_ input1:String, _ input2:Strin, last:GameTurn?) {
        x = Int(input1[0])!
        y = Int(input1[1])!
        nextCheckpointX = Int(input1[2])!
        nextCheckpointY = Int(input1[3])!
        nextCheckpointDist = Int(input1[4])!
        nextCheckpointAngle = Int(input1[5])!
        
        opponentX = Int(input2[0])!
        opponentY = Int(input2[1])!
        nextCheckpointAngleAbs = abs(nextCheckpointAngle)
        
        if let lastTurn = last {
            
        }
    }
}

public func main() {
    var boostAvailable = true
    
    while true {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        let inputs2 = (readLine()!).split(separator: " ").map(String.init)
        let game = Game(inputs, inputs2)

        // Write an action using print("message...")
        // To debug: print("Debug messages...", to: &errStream)
        var boost = false
        var power = 100
        
        let d = sqrt(pow(Double(nextCheckpointX-x),2)+pow(Double(nextCheckpointY-y),2))
        if boostAvailable && d > 8000 && nextCheckpointAngleAbs < 35 {
            boost = true
            boostAvailable = false
        }
        // You have to output the target position
        // followed by the power (0 <= thrust <= 100)
        // i.e.: "x y thrust"
        if nextCheckpointAngle > 90 || nextCheckpointAngle < -90 {
            power = 0
        }
        else {
            power = 100
        }
        print("\(nextCheckpointX) \(nextCheckpointY)",boost ? "BOOST":power)
    }
}

//main()
