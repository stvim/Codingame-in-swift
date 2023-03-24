/********************* LAUNCHER ***********************/

//let dialogMode = DialogCodingame(showAllInputs:false)
public let MODE = Game.Episode2
//main(dialog: dialogMode)


/*********************** CODE *************************/
import Foundation

#if canImport(CodingameCommon)
import Darwin
import CodingameCommon
#else
import Glibc
public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()


/************************************ IDialog implementation **************************************/

public protocol IDialog {
    func writeArray(_ arg:[Any], separator:String, terminator:String) -> Void
    func debugArray(_ arg:[Any], separator:String, terminator:String) -> Void
    func read() -> String?
    func read(_ :String) -> String?
}

public extension IDialog {
    private var defaultTerminator : String { get { "\n"} }
    private var defaultSeparator : String { get { " "} }
    func write(_ args:Any...) -> Void {
        writeArray(args, separator: defaultSeparator, terminator: defaultTerminator)
    }
    func write(_ args:Any..., terminator:String) -> Void {
        writeArray(args, separator: defaultSeparator, terminator: terminator)
    }
    func write(_ args:Any..., separator:String) -> Void {
        writeArray(args, separator:separator, terminator: defaultTerminator)
    }
    func write(_ args:Any..., separator:String, terminator:String) -> Void {
        writeArray(args, separator:separator, terminator: terminator)
    }
    func debug(_ args:Any...) -> Void {
        debugArray(args, separator: defaultSeparator, terminator: defaultTerminator)
    }
    func debug(_ args:Any..., terminator:String) -> Void {
        debugArray(args, separator: defaultSeparator, terminator: terminator)
    }
    func debug(_ args:Any..., separator:String) -> Void {
        debugArray(args, separator:separator, terminator: defaultTerminator)
    }
    func debug(_ args:Any..., separator:String, terminator:String) {
        debugArray(args, separator:separator, terminator: terminator)
    }
}

public class DialogCodingame : IDialog {
    public var allInputs = ""
    private let showAllInputs:Bool
    public init(showAllInputs:Bool = false) {
        self.showAllInputs = showAllInputs
    }
    
    public func showAllInputsOnDebug() {
        debug("----------- All inputs ------------")
        debug(allInputs,terminator:"")
        debug("-----------------------------------")
    }
    
    public func writeArray(_ arg:[Any], separator: String, terminator: String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        print(output, terminator: terminator)
    }
    public func debugArray(_ arg:[Any], separator:String, terminator:String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        print(output, terminator: terminator, to: &errStream)
    }
    public func read(_ message:String) -> String? {
        return read()
    }
    public func read() -> String? {
        let r = readLine()
        allInputs += r! + "\n"
        if self.showAllInputs {
            showAllInputsOnDebug()
        }
        return r
    }
}

/************************************ IDialog implementation **************************************/

#endif


public enum Game {
    case Episode1, Episode2
}



public class Node : Hashable {
    let index : Int
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.index == rhs.index
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    init(index:Int) {
        self.index = index
    }
    
    var isGateway = false
    var bobnetScore : Int?
    var links = Dictionary<Node,Segment>()

}

public class Segment : Hashable {
    let node1,node2 : Node
    
    var bobnetWinPossibilities = 0
    
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.node1 == rhs.node1 && lhs.node2 == rhs.node2
    }
    public func hash(into hasher: inout Hasher) {
        //hasher.combine(index)
        node1.hash(into: &hasher)
        node2.hash(into: &hasher)
    }
    
    init(nodeLowIndex:Node, nodeHighIndex:Node) {
        assert(nodeLowIndex.index < nodeHighIndex.index, "Bad Nodes for segment")
        self.node1 = nodeLowIndex
        self.node2 = nodeHighIndex
        
    }
    
    var nodesIndexesString : String {
        get { "\(self.node1.index) \(self.node2.index)"}
    }
    
}


public typealias Map = [Int:Node]


public func searchSegmentToCut(map:Map, bobnetNode:Node) -> Segment? {
    for node in map.values {
        node.bobnetScore = nil
    }
    
    
    func deepSearch(currentNode:Node, currentScore:Int, previousNode:Node?, visitedNodes:Set<Node>, depth:Int) -> Segment? {
        let reachableGateways = currentNode.links.keys.filter{$0.isGateway}
        let newScore = currentScore + reachableGateways.count

        if currentNode.bobnetScore != nil && currentNode.bobnetScore! > newScore {
            return nil
        }
        else {
            currentNode.bobnetScore = newScore

            if newScore > 0 {
                if MODE == .Episode1 {
                    if let previousNode = previousNode {
                        return currentNode.links[previousNode]!
                    }
                }
                return currentNode.links[reachableGateways.first!]!
            }
            else {
                var nextVisitedNodes = visitedNodes
                nextVisitedNodes.insert(currentNode)
                for nextNode in currentNode.links.keys
                                    .filter({visitedNodes.contains($0) == false})
                                    .filter({$0.isGateway==false}) {
                    let r = deepSearch(currentNode: nextNode
                                       ,currentScore: newScore-1
                                       ,previousNode: currentNode
                                       ,visitedNodes: nextVisitedNodes
                                       ,depth: depth+1)
                    if r != nil {
                        return r
                    }
                }
                return nil
            }
        }
    }
    
    return deepSearch(currentNode: bobnetNode, currentScore:0, previousNode:nil, visitedNodes: [], depth:1)
}


public func main(dialog:IDialog) {
    let inputs = (dialog.read("N (num nodes) L (num links) E (num gateways)")!).split(separator: " ").map(String.init)
    let N = Int(inputs[0])! // the total number of nodes in the level, including the gateways
    let L = Int(inputs[1])! // the number of links
    let E = Int(inputs[2])! // the number of exit gateways
    
    var mainMap = Map()
    for i in 0...(N-1) {
        mainMap[i] = Node(index:i)
    }
    
    if L > 0 {
        for _ in 0...(L-1) {
            let inputs = (dialog.read("Link (N1 N2)")!).split(separator: " ").map(String.init)
            let N1 = Int(inputs[0])! // N1 and N2 defines a link between these nodes
            let N2 = Int(inputs[1])!
            let nodeLow = N1 < N2 ? mainMap[N1]! : mainMap[N2]!
            let nodeHigh = N2 < N1 ? mainMap[N1]! : mainMap[N2]!
            let segment = Segment(nodeLowIndex:nodeLow, nodeHighIndex:nodeHigh)
            nodeLow.links[nodeHigh] = segment
            nodeHigh.links[nodeLow] = segment
        }
    }
    
    var gateways = Set<Node>()
    var gatewaySegments = Set<Segment>()
    if E > 0 {
        for _ in 0...(E-1) {
            let EI = Int(dialog.read("Gateway (Node)")!)! // the index of a gateway node
            let node = mainMap[EI]!
            node.isGateway = true
            gateways.insert(node)
            for segment in node.links.values {
                gatewaySegments.insert(segment)
            }
        }
    }
    
    
    // game loop
    while true {
        guard let r = dialog.read("Bobnet position (Node)") else {
            return
        }
        let SI = Int(r)! // The index of the node on which the Bobnet agent is positioned this turn
        let bobnetNode = mainMap[SI]!
        
        var segmentToCut = searchSegmentToCut(map: mainMap, bobnetNode: bobnetNode)
        if segmentToCut == nil {
            if MODE == .Episode1 {
                segmentToCut = bobnetNode.links.values.first
            }
            else {
                segmentToCut = gatewaySegments.first
            }
        }
        
        if let segmentToCut = segmentToCut {
            segmentToCut.node1.links.removeValue(forKey:segmentToCut.node2)
            segmentToCut.node2.links.removeValue(forKey:segmentToCut.node1)
            gatewaySegments.remove(segmentToCut)
            dialog.write(segmentToCut.nodesIndexesString)
        }
        else {
            dialog.write("")
        }
    }
    
}

