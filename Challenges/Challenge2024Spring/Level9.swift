//
//  Level9.swift
//  Codingame-in-Swift
//
//  Created by Steven Morin on 28/03/2024.
//

import Foundation

typealias Bit = Bool
typealias Depth = Int

class Node : Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.path == rhs.path
    }
    
    init(path: [Bit], endOfCode: Bool, nextFalse: Node? = nil, nextTrue: Node? = nil) {
        self.path = path
        self.depth = path.count
        self.endOfCode = endOfCode
        self.nextFalse = nextFalse
        self.nextTrue = nextTrue
        self.invalidNode = endOfCode && (nextFalse != nil || nextTrue != nil)
    }
    let path : [Bit]
    let depth : Depth
    let endOfCode : Bool
    let nextFalse : Node?
    let nextTrue : Node?
    let invalidNode : Bool

}

func constructBinaryTree(codes : [[Bit]], path:[Bit], invalidNodesByDepth: inout [Depth:[Node]]) -> Node? {

    guard !codes.isEmpty else {
        return nil
    }
    let depth : Depth = path.count
    
    let endOfCode = codes.firstIndex(where: { $0.count == depth }) != nil

    let codesForNextNode = codes.filter{ $0.count > depth }
    let codesForNextFalse = codesForNextNode.filter({ $0[depth] == false })
    let codesForNextTrue = codesForNextNode.filter({ $0[depth] == true })
    
    let node = Node(path: path
                    , endOfCode: endOfCode
                    , nextFalse: constructBinaryTree(codes: codesForNextFalse
                                                     , path: path + [false]
                                                     , invalidNodesByDepth: &invalidNodesByDepth)
                    , nextTrue: constructBinaryTree(codes: codesForNextTrue
                                                    , path: path + [true]
                                                    , invalidNodesByDepth: &invalidNodesByDepth)
    )
    
    if node.invalidNode {
        invalidNodesByDepth[depth, default: []].append(node)
    }
    
    return node
}

struct PathToExplore {
    init(path: [Bit]
         , previousPath: PathToExplore?
         , rootNode:Node
         , node1: Node
         , node2: Node)
    {
        self.path = path
        self.node1 = node1
        self.node2 = node2
        if let previousPath = previousPath {
            // tracking if one of paths is starting from the root, meaning that previous path had reached an end of code
            self.path1EndOfCodes = {
                var value = previousPath.path1EndOfCodes
                if node1.depth == 1 {
                    value.append(previousPath.node1)
                }
                return value
            }()
            self.path2EndOfCodes  = {
                var value = previousPath.path2EndOfCodes
                if node2.depth == 1 {
                    value.append(previousPath.node2)
                }
                return value
            }()
            
        } else {
            self.path1EndOfCodes = []
            self.path2EndOfCodes = []
        }
        self.rootNode = rootNode
    }
    let path:[Bit]
    let node1:Node
    let node2:Node
    let path1EndOfCodes : [Node]
    let path2EndOfCodes : [Node]
    let rootNode : Node
    
    var solutionFound: Bool {
        node1.endOfCode && node2.endOfCode
    }
    
    func getNextPathsToExplore() -> [PathToExplore] {
        // if the current self is a solution, we do not provide more paths to explore
        if (node1.endOfCode && node2.endOfCode) {
            return []
        }
        // Idem if the lasts complete codes reached by both paths are the same (to avoid an infinite loop)
        if let lastPath1EndOfCode = path1EndOfCodes.last
            , let lastPath2EndOfCode = path2EndOfCodes.last
            , lastPath1EndOfCode == lastPath2EndOfCode
        {
            return []
        }
        
        
        var nextDepthPathsToExplore = [PathToExplore]()
        
        // if node 1 is endOfCode : we should continue searching with next nodes but also starting from the root node
        // Idem for node 2
        // Lets build a list of couple (node1,node2) to keep exploring
        var nodesToExplore = [(node1:node1, node2:node2)]
        if node1.endOfCode {
            nodesToExplore.append((node1:rootNode, node2:node2))
        } else if node2.endOfCode {
            nodesToExplore.append((node1:node1, node2:rootNode))
        }
        
        // Warning : node1 and node2 could be equal here in certain cases, we must avoid that
        nodesToExplore = nodesToExplore.filter{ $0.node1 != $0.node2 }
        
        // For every couple now, searching for next nodes existing for both elements
        nodesToExplore
            .forEach{
                (node1, node2) in
                
                if let node1NextFalse = node1.nextFalse
                    , let node2NextFalse = node2.nextFalse
                {
                    nextDepthPathsToExplore.append(PathToExplore(path: path + [false]
                                                                 , previousPath: self
                                                                 , rootNode: rootNode
                                                                 , node1: node1NextFalse
                                                                 , node2: node2NextFalse))
                }
                
                if let node1NextTrue = node1.nextTrue
                    , let node2NextTrue = node2.nextTrue
                {
                    nextDepthPathsToExplore.append(PathToExplore(path: path + [true]
                                                                 , previousPath: self
                                                                 , rootNode: rootNode
                                                                 , node1: node1NextTrue
                                                                 , node2: node2NextTrue))
                }
            }
        
        return nextDepthPathsToExplore
    }
}

// will search every possible solution starting from depth 0 and digging every possible path in parallel
func parallelSearch(invalidNodesByDepth: [Depth:[Node]]
                    , rootNode: Node
                    ) -> [Bit]?
{
    var currentDepth = 0
    var pathsToExplore : [PathToExplore] = []
    var solutionFound : [Bit]? = nil
    
    while solutionFound == nil {
        // Looking for invalidNodes to use as paths to explore at current depth
        if let invalidNodesAtCurrentDepth = invalidNodesByDepth[currentDepth] {
            pathsToExplore.append(contentsOf: invalidNodesAtCurrentDepth.map{
                invalidNode in
                PathToExplore(path: invalidNode.path
                              , previousPath: nil
                              , rootNode: rootNode
                              , node1: invalidNode
                              , node2: rootNode)
            })
        }
        
        // Special case if current paths to explore is empty :
        // either we have some more invalid nodes waiting at deeper depth
        // , either we don't and we must stop now with no solutions
        if pathsToExplore.isEmpty {
            let nextDepthToSearch = invalidNodesByDepth
                .keys
                .filter{ $0 > currentDepth }
                .min()
            
            if let nextDepthToSearch = nextDepthToSearch {
                currentDepth = nextDepthToSearch
                pathsToExplore = []
            } else {
                break
            }
        } else {
            
            // Looking for every path to explore now, finding a solution or preparing the job for the next depth
            var nextDepthPathsToExplore = [PathToExplore]()
            
            for pathToExplore in pathsToExplore {
                if pathToExplore.solutionFound {
                    solutionFound = pathToExplore.path
                    break
                } else {
                    nextDepthPathsToExplore.append(contentsOf: pathToExplore.getNextPathsToExplore())
                }
            }
            
            currentDepth += 1
            pathsToExplore = nextDepthPathsToExplore
        }
    }
    
    return solutionFound
}


func crashDecode(codes input: [String]) -> String? {
    // Write your code here
    let codes : [[Bit]] = input.map{ word in word.map{ $0 == "1" }}
    var invalidNodesByDepth = [Depth:[Node]]()
    
    let rootNode = constructBinaryTree(codes: codes, path: [], invalidNodesByDepth: &invalidNodesByDepth)!

    var solutionFound : [Bit]? = nil
    
    if let startingSearchDepth = invalidNodesByDepth.keys.min() {
        solutionFound = parallelSearch(invalidNodesByDepth: invalidNodesByDepth
                                       , rootNode: rootNode)
    }

    return solutionFound?.map{ $0 ? "1" : "0"}.joined() ?? "X"
}

