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


// a node is a movie / a cast
// a node content is an actor

func sixDegreesOfKevinBacon() -> Int {

    typealias NodeID = Int
    typealias NodeContent = String


    let startNodeContent = "Kevin Bacon"
    let endNodeContent = readLine()!
    print("Looking for : \(endNodeContent)", to: &errStream)
    let n = Int(readLine()!)!

    if startNodeContent == endNodeContent {
        return 0
    }

    var startNodes = Set<NodeID>()
    var endNodes = Set<NodeID>()
    var nodeNeighbors : [NodeID:Set<NodeID>] = [:]
    var nodeContents  : [NodeID:Set<NodeContent>] = [:]

    if n > 0 {
        for i in 0...(n-1) {
            let movieDescription = readLine()!.components(separatedBy: ": ")
            let movieCast = movieDescription[1].components(separatedBy: ", ")

            nodeNeighbors[i] = []

            for actorName in movieCast {
                for previousNodeKeyValue in nodeContents {
                    if previousNodeKeyValue.value.contains(actorName) {
                        nodeNeighbors[i]!.insert(previousNodeKeyValue.key)
                        nodeNeighbors[previousNodeKeyValue.key]!.insert(i)
                        print(i, previousNodeKeyValue.key, to: &errStream)
                    }
                }

                if actorName == startNodeContent {
                    startNodes.insert(i)
                }
                if actorName == endNodeContent {
                    endNodes.insert(i)
                }
            }

            nodeContents[i] = Set(movieCast)
            print(nodeContents[i]!, to: &errStream)

        }
    }

    print(startNodes, endNodes, to: &errStream)

    var distToAStartNode = Array<Int?>(repeating: nil, count: n)

    startNodes.forEach{ distToAStartNode[$0] = 0 }

    var nodesToVisit = startNodes
    var nextToVisit = Set<NodeID>()

    for length in 1...n {
        for node in nodesToVisit {
            if endNodes.contains(node) {
                print(node, nodeContents[node]!, to: &errStream)
                

                return length
            }

            for neighbor in nodeNeighbors[node]! {
                if distToAStartNode[neighbor] == nil || distToAStartNode[neighbor]! > (length+1) {
                    distToAStartNode[neighbor] = length+1
                    nextToVisit.insert(neighbor)
                }
            }
        }
        nodesToVisit = nextToVisit
        nextToVisit = []
    }
    return -1
}
// Write an answer using print("message...")
// To debug: print("Debug messages...", to: &errStream)

//print(sixDegreesOfKevinBacon())
