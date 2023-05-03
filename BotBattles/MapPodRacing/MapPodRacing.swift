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

protocol Coordinates : Equatable, Hashable {
    var x:Int { get }
    var y:Int { get }
}

extension Coordinates {
    func distanceTo(_ other:Self) -> Double {
        sqrt(pow(Double(self.x - other.x),2.0)+pow(Double(self.y - other.y),2.0))
    }
}

struct Position : Coordinates {
    let x,y:Int
}

struct Checkpoint : Coordinates {
    let x,y:Int
    let position:Int
}

struct Map {
    var checkpoints:[Coordinates] = []
    var completed = false
    var lap = 0
    var nextCheckpoint:Coordinates?
    
    mutating func update(nextCheckpoint:Coordinates) {
        guard let mapNextCheckpoint = self.nextCheckpoint else {
            checkpoints.append(nextCheckpoint)
            self.nextCheckpoint = nextCheckpoint
        }
        if mapNextCheckpoint != nextCheckpoint
        if checkpoints.contains(nextCheckpoint)
    }
    
    func nextCheckpointForward(offset:Int = 0) -> Coordinates? {
        if !completed {
            return nil
        }
        else {
            
        }
    }
}

struct GameFrame {
    static var map = Map()
    
    let myPosition:Position
    let mySpeed:Double = 0.0
    let nextCheckpoint:Checkpoint
    let oppPosition:Position
    let nextCheckpointDist:Int
    let nextCheckpointAngle:Int
    let nextCheckpointAngleAbs:Int
    
//    init(_ input1:[String], _ input2:[String], last:GameFrame?) {
//        myPosition = Position(x:Int(input1[0])!, y:Int(input1[1])!)
//        nextCheckpoint = Checkpoint(x:Int(input1[2])!, y:Int(input1[3])!)
//        nextCheckpointDist = Int(input1[4])!
//        nextCheckpointAngle = Int(input1[5])!
//
//        oppPosition = Position(x:Int(input2[0])!, y:Int(input2[1])!)
//        nextCheckpointAngleAbs = abs(nextCheckpointAngle)
//
//        if let lastTurn = last {
//            mySpeed = myPosition.distanceTo(lastTurn.myPosition)
//        }
//
//        if !map.checkpoints.contains(nextCheckpoint) {
//            map.checkpoints.append(nextCheckpoint)
//        }
//        if map.checkpoints.last! != nextCheckpoint {
//
//        }
//    }
}

public func main() {
    var boostAvailable = true
    
    var lastFrame:GameFrame?
    
    while true {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        let inputs2 = (readLine()!).split(separator: " ").map(String.init)
        let currentFrame = GameFrame(inputs, inputs2, last:lastFrame)

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
        lastFrame = currentFrame
    }
}

//main()
