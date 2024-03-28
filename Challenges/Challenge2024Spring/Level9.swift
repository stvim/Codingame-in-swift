//
//  Level9.swift
//  Codingame-in-Swift
//
//  Created by Steven Morin on 28/03/2024.
//

import Foundation

typealias Bit = Bool
typealias Depth = Int

class Node {
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
    
    var description: [String] {
        var str = [String](repeating: " ", count: depth).joined() + "-"
        str += path.map{ $0 ? "1" : "0" }
        str += endOfCode ? " (*)" : ""
        var result = [str]
        result.append(contentsOf: nextFalse?.description ?? [])
        result.append(contentsOf: nextTrue?.description ?? [])
        return result
    }
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
    let path:[Bit]
    let node1:Node
    let node2:Node
}

func parallelSearch(currentDepth:Int
                    , pathsToExplore inputPathsToExplore: [PathToExplore]
                    , invalidNodesByDepth: [Depth:[Node]]
                    , rootNode: Node
                    ) -> [Bit]?
{
    
    // Looking for invalidNodes to use as paths to explore at current depth
    var pathsToExplore = inputPathsToExplore
    if let invalidNodesAtCurrentDepth = invalidNodesByDepth[currentDepth] {
        pathsToExplore.append(contentsOf: invalidNodesAtCurrentDepth.map{
            invalidNode in
            PathToExplore(path: invalidNode.path
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
            return parallelSearch(currentDepth: nextDepthToSearch
                                  , pathsToExplore: []
                                  , invalidNodesByDepth: invalidNodesByDepth
                                  , rootNode: rootNode)
        } else {
            return nil
        }
    }
    
    // Looking for every path to explore now, finding a solution or preparing the job for the next depth
    var nextDepthPathsToExplore = [PathToExplore]()
    
    for pathToExplore in pathsToExplore {
        if pathToExplore.node1.endOfCode && pathToExplore.node2.endOfCode {
            return pathToExplore.path
        } else {
            // if node 1 is endOfCode : we should continue searching with next nodes but also starting from the root node
            // Idem for node 2
            // Lets build a list of couple (node1,node2) to keep exploring
            var nodesToExplore = [(node1:pathToExplore.node1, node2:pathToExplore.node2)]
            if pathToExplore.node1.endOfCode {
                nodesToExplore.append((node1:rootNode, node2:pathToExplore.node2))
            } else if pathToExplore.node2.endOfCode {
                nodesToExplore.append((node1:pathToExplore.node1, node2:rootNode))
            }
            
            // Warning : node1 and node2 could be equal here in certain cases, we must avoid that
            nodesToExplore = nodesToExplore.filter{ $0.node1.path != $0.node2.path }
            
            // For every couple now, searching for next nodes existing for both elements
            nodesToExplore
                .forEach{
                    (node1, node2) in
                    
                    if let node1NextFalse = node1.nextFalse
                        , let node2NextFalse = node2.nextFalse
                    {
                        nextDepthPathsToExplore.append(PathToExplore(path: pathToExplore.path + [false]
                                                                     , node1: node1NextFalse
                                                                     , node2: node2NextFalse))
                    }
                    
                    if let node1NextTrue = node1.nextTrue
                        , let node2NextTrue = node2.nextTrue
                    {
                        nextDepthPathsToExplore.append(PathToExplore(path: pathToExplore.path + [true]
                                                                     , node1: node1NextTrue
                                                                     , node2: node2NextTrue))
                    }
                }
        }
    }
    
    return parallelSearch(currentDepth: currentDepth + 1
                          , pathsToExplore: nextDepthPathsToExplore
                          , invalidNodesByDepth: invalidNodesByDepth
                          , rootNode: rootNode)
}

func crashDecode(codes input: [String]) -> String? {
    // Write your code here
    let codes : [[Bit]] = input.map{ word in word.map{ $0 == "1" }}
    var invalidNodesByDepth = [Depth:[Node]]()
    
    let rootNode = constructBinaryTree(codes: codes, path: [], invalidNodesByDepth: &invalidNodesByDepth)!

    rootNode.description.forEach({ debugPrint($0)})
    var firstFoundWord : [Bit]? = nil
    if let startingSearchDepth = invalidNodesByDepth.keys.min() {
        firstFoundWord = parallelSearch(currentDepth: startingSearchDepth
                                        , pathsToExplore: []
                                        , invalidNodesByDepth: invalidNodesByDepth
                                        , rootNode: rootNode)
    }

    return firstFoundWord?.map{ $0 ? "1" : "0"}.joined() ?? "X"
}

