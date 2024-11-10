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


func asteroids() {
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let W = Int(inputs[0])!
    let H = Int(inputs[1])!
    let t0 = Int(inputs[2])!
    let t1 = Int(inputs[3])!
    let t2 = Int(inputs[4])!
    
    
    var asteroids : [[[Int]]] = [[[Int]]](  repeating: [[Int]](repeating: [Int](), count: 3)
                                            , count: 26)
    
    typealias AsteroidResultCandidate = (asteroidNum: Int, finalPosition: [Float], coordinatesOffset: Float)?
    var result = [[AsteroidResultCandidate]](repeating: [AsteroidResultCandidate](repeating: nil, count: W), count: H)
    
    var asteroidNums = Set<Int>()
    
    if H > 0 {
        for y in 0...(H-1) {
            let read = readLine()!
            print("> \(read)", to: &errStream)
            let inputs = read.split(separator: " ").map{ $0.map(String.init) }
            
            
            for t in 0...1 {
                for x in 0 ..< W {
                    let char = inputs[t][x]
                    if CharacterSet.uppercaseLetters.contains(char.unicodeScalars.first!) {
                        let asteroidNum = Int(char.first!.asciiValue! - Character("A").asciiValue!)
                        asteroidNums.insert(asteroidNum)
                        
                        asteroids[asteroidNum][t] = [x,y]
                        
                        
                    }
                }
            }
        }
    }
    
    for asteroidNum in asteroidNums.sorted() {
        var finalPosition : [Float] = [0,0]
        var finalPositionRounded : [Int] = [0,0]
        
        for axis in 0...1 {
            asteroids[asteroidNum][2] = [99,99]
            
            let coordAtT = [asteroids[asteroidNum][0][axis], asteroids[asteroidNum][1][axis]]
            
            let velocity = Float(coordAtT[1]-coordAtT[0]) / Float(t1-t0)
            
            finalPosition[axis] = Float(coordAtT[1]) + (velocity * Float(t2-t1))
            finalPositionRounded[axis] = Int(floor(finalPosition[axis]))
        }
        
        let coordinatesOffset = pow( pow(finalPosition[1]-Float(finalPositionRounded[1]), 2) + pow(finalPosition[0]-Float(finalPositionRounded[0]), 2) , 1/2)
        
        if result.indices ~= finalPositionRounded[1], result[0].indices ~= finalPositionRounded[0] {
            if let previousCandidate = result[finalPositionRounded[1]][finalPositionRounded[0]]
                , previousCandidate.coordinatesOffset <= coordinatesOffset
            {
            } else {
                result[finalPositionRounded[1]][finalPositionRounded[0]] = (asteroidNum, finalPosition, coordinatesOffset )
            }
        }
    }

    
    for y in 0...(H-1) {
        let resultLine = result[y]
        
        print(resultLine.map
              {
            if let candidate = $0 {
                return String(UnicodeScalar(UInt8(candidate.asteroidNum) + Character("A").asciiValue!))
            } else {
                return "."
            }
        }.joined(separator: "")
        )
    }
}

//asteroids()
