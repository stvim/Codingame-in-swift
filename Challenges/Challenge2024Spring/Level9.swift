//
//  Level9.swift
//  Codingame-in-Swift
//
//  Created by Steven Morin on 28/03/2024.
//

import Foundation

func crashDecode(codes input: [String]) -> String? {
    // Write your code here
    let codes : [[Bit]] = input.map{ word in word.map{ $0 == "1" }}
//    let huffmanTree = constructDicNode(startIndex: 0, subWord: [], subDic: codes)
//    
//    huffmanTree.description.forEach{ debugPrint($0) }
    return nil
}

typealias Bit = Bool

class DicNode {
    init(depth: Int, endOfCode: Bool, nextFalse: DicNode? = nil, nextTrue: DicNode? = nil) {
        self.depth = depth
        self.endOfCode = endOfCode
        self.nextFalse = nextFalse
        self.nextTrue = nextTrue
    }
    var depth : Int = 0
    
    var endOfCode : Bool = false
    
    var nextFalse : DicNode?
    var nextTrue : DicNode?
    
    

//    var description: [String] {
//        var str = [String](repeating: " ", count: startIndex).joined() + "-"
//        str += subWord.map{ $0 ? "1" : "0" }
//        str += numWordsEndingHere == 0 ? "" : " (\(numWordsEndingHere))"
//        var result = [str]
//        result.append(contentsOf: [str])
//        result.append(contentsOf: subNodes.map { $0.description }.flatMap({ $0 }))
//        return result
//    }
}

public typealias CodeIndex = Int
public typealias DicIndex = Int

func constructDicNode(codes : [[Bit]], depth:Int) -> DicNode? {

    guard !codes.isEmpty else {
        return nil
    }
    
    let endOfCode = codes.firstIndex(where: { $0.count == depth }) != nil
    

    let codesForNextNode = codes.filter{ $0.count > depth }
    let codesForNextFalse = codesForNextNode.filter({ $0[depth+1] == false })
    let codesForNextTrue = codesForNextNode.filter({ $0[depth+1] == true })
    
    let node = DicNode(depth: depth
                       , endOfCode: endOfCode
                       , nextFalse: constructDicNode(codes: codesForNextFalse, depth: depth+1)
                       , nextTrue: constructDicNode(codes: codesForNextTrue, depth: depth+1)
    )
    
    return node
}
