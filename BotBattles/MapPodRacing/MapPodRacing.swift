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
    func toPrint() -> String {
        return "\(x) \(y)"
    }
    func distanceTo(_ other:Self) -> Double {
        sqrt(pow(Double(self.x - other.x),2.0)+pow(Double(self.y - other.y),2.0))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct Position : Coordinates  {
    let x,y:Int
}

struct Checkpoint : Coordinates {
    let x,y:Int

    var index:Int?
    var distToMe:Int?
    var angleToMe:Int?
    var angleToMeAbs:Int? {
        if case let x? = angleToMe, x<0 { return -x }
        else { return x }
    }
    
    mutating func reset() {
        self.distToMe = nil
        self.angleToMe = nil
    }
    
}

extension Array<Checkpoint> {
//    private var currentCheckpointIndex:Int?
    // test
    func loopIndex(_ i:Int, offset:Int = 0) -> Int {
        return  (i+offset)%self.count
    }
}

struct Map {
    private(set) var checkpoints:[Checkpoint] = []
    private(set) var completed = false
    private(set) var lap = 0
    
    private(set) var currentCheckpointIndex:Int = -1
//    func
    //    var currentCheckpoint:Checkpoint? {
//        return currentCheckpointIndex.map{ checkpoints[$0] }
////        return currentCheckpointIndex == nil ? nil : self.checkpoints[self.currentCheckpointIndex!]
//    }
    init(currentCheckpoint:Checkpoint) {
        update(currentCheckpoint: currentCheckpoint)
    }

    mutating func update(currentCheckpoint:Checkpoint) {
        checkpoints.indices.forEach{ checkpoints[$0].reset() }
        
        if let matchingIndex = self.checkpoints.firstIndex(of: currentCheckpoint) {
            checkpoints[matchingIndex] = currentCheckpoint
            
            if currentCheckpointIndex != matchingIndex {
                currentCheckpointIndex = matchingIndex
                
                if matchingIndex == 0 {
                    completed = true
                    lap += 1
                }
            }
        }
        else {
            checkpoints.append(currentCheckpoint)
            currentCheckpointIndex = checkpoints.count-1
        }
    }
}

struct GameFrame {
    var map : Map
    
    let myPosition:Position
    let mySpeed:Double
    let currentCheckpoint:Checkpoint
    let oppPosition:Position
    
    init(_ input1:[String], _ input2:[String], last:GameFrame?) {
        myPosition = Position(x:Int(input1[0])!, y:Int(input1[1])!)
        currentCheckpoint = Checkpoint(x:Int(input1[2])!,
                                    y:Int(input1[3])!,
                                    distToMe: Int(input1[4])!,
                                    angleToMe: Int(input1[5])!)
        if let lastFrame = last {
            map = lastFrame.map
            map.update(currentCheckpoint: currentCheckpoint)
        }
        else {
            map = Map(currentCheckpoint: currentCheckpoint)
        }

        oppPosition = Position(x:Int(input2[0])!, y:Int(input2[1])!)

        if let lastTurn = last {
            mySpeed = myPosition.distanceTo(lastTurn.myPosition)
        }
        else { mySpeed = 0 }

    }
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
        
//        let d = sqrt(pow(Double(currentCheckpointX-x),2)+pow(Double(currentCheckpointY-y),2))
        let currentCheckpoint = currentFrame.map.checkpoints[currentFrame.map.currentCheckpointIndex]
        let d = currentCheckpoint.distToMe!
        if boostAvailable && d > 8000 && currentCheckpoint.angleToMeAbs! < 35 {
            boost = true
            boostAvailable = false
        }
        // You have to output the target position
        // followed by the power (0 <= thrust <= 100)
        // i.e.: "x y thrust"
        if currentCheckpoint.angleToMeAbs! > 90 {
            power = 0
        }
        else {
            power = 100
        }
        print("\(currentCheckpoint.toPrint())",boost ? "BOOST":power)
        lastFrame = currentFrame
    }
}

//main()
