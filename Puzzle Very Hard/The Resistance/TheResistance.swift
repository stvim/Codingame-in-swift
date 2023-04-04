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

let morseAlphabet = [
    "A": [false, true],
    "B": [true, false, false, false],
    "C": [true, false, true, false],
    "D": [true, false, false],
    "E": [false],
    "F": [false, false, true, false],
    "G": [true, true, false],
    "H": [false, false, false, false],
    "I": [false, false],
    "J": [false, true, true, true],
    "K": [true, false, true],
    "L": [false, true, false, false],
    "M": [true, true],
    "N": [true, false],
    "O": [true, true, true],
    "P": [false, true, true, false],
    "Q": [true, true, false, true],
    "R": [false, true, false],
    "S": [false, false, false],
    "T": [true],
    "U": [false, false, true],
    "V": [false, false, false, true],
    "W": [false, true, true],
    "X": [true, false, false, true],
    "Y": [true, false, true, true],
    "Z": [true, true, false, false]
]

enum gameError: Error {
    case incorrectInputValue(String)
}

func convertToMorse(_ word: String) throws -> [Bool] {

    var morseWord: [MorseValue] = []
    
    for letter in word {
        guard let morseLetter = morseAlphabet[String(letter)] else {
            throw gameError.incorrectInputValue("Unknown character : \(letter)")
        }
        morseWord += morseLetter
    }
    
    return morseWord
}

func convertToMorseArray(morse: String) throws -> [MorseValue] {
    var booleanArray: [MorseValue] = []
    for character in morse {
        if character == "-" {
            booleanArray.append(true)
        } else if character == "." {
            booleanArray.append(false)
        }
        else {
            throw gameError.incorrectInputValue("Invalid morse value : \(character)")
        }
    }
    return booleanArray
}

struct DicNode {
    let startIndex : Int
    let subDic: [[MorseValue]]
    var subWord : [MorseValue]
    var numWordsEndingHere : Int = 0
    var subNodes : [DicNode] = []
}


public typealias MorseValue = Bool
public typealias WordIndex = Int
public typealias DicIndex = Int

func constructDicNode(startIndex:Int, subWord:[MorseValue], subDic:[[MorseValue]] ) -> DicNode {

    var node = DicNode(startIndex: startIndex, subDic: subDic, subWord: subWord, numWordsEndingHere: 0, subNodes: [])
    
    var currentIndex = startIndex + subWord.count

    while true {
        let subDicWithoutEndingWords = subDic.filter { $0.count > currentIndex }
        if subDicWithoutEndingWords.count < subDic.count {
            node.numWordsEndingHere = subDic.filter { $0.count == currentIndex }.count
            
            if subDicWithoutEndingWords.count > 0 {
                let subNodeCandidate = constructDicNode(startIndex: currentIndex, subWord: [], subDic: subDicWithoutEndingWords)
                if subNodeCandidate.subWord == [] {
                    node.subNodes = subNodeCandidate.subNodes
                }
                else {
                    node.subNodes.append(subNodeCandidate)
                }
            }
            break
        }
        else {
            let V = subDic.first![currentIndex]
            let subDicStartingWithValueNotV = subDic.filter { $0[currentIndex] != V }
            if subDicStartingWithValueNotV.count == 0 {
                node.subWord.append(V)
                currentIndex += 1
            }
            else {
                let subDicStartingWithValueV = subDic.filter { $0[currentIndex] == V }
                node.subNodes.append(constructDicNode(startIndex: currentIndex, subWord: [V], subDic: subDicStartingWithValueV))
                node.subNodes.append(constructDicNode(startIndex: currentIndex, subWord: [!V], subDic: subDicStartingWithValueNotV))
                break
            }
        }
    }
    return node
}


func countSolutions(_ game:Game, startingIndex:Int, solutionCountCacheFromIndex: inout [Int:Int]) -> Int {
    if let r = solutionCountCacheFromIndex[startingIndex] {
        return r
    }
    else {
        var numSolutionsFound = 0
        
        var nextDicNodes : [DicNode]? = [game.rootDicNode]
        var nextIndex = startingIndex
        
        while nextDicNodes != nil {
            let currentDicNodes = nextDicNodes!
            let currentIndex = nextIndex
            nextDicNodes = nil
            
            for currentDicNode in currentDicNodes {
                let currentSubWord = currentDicNode.subWord
                if currentSubWord.count <= (game.sequence.count - currentIndex) {
                    let subsequence = game.sequence[currentIndex ..< (currentIndex + currentSubWord.count)]
                    if subsequence.elementsEqual(currentSubWord) {
                        nextIndex += currentSubWord.count
                        
                        if subsequence.endIndex == game.sequence.endIndex {
                            if currentDicNode.numWordsEndingHere != 0 {
                                numSolutionsFound += currentDicNode.numWordsEndingHere
                            }
                            nextDicNodes = nil
                        }
                        else {
                            if currentDicNode.numWordsEndingHere != 0 {
                                numSolutionsFound += countSolutions(game, startingIndex: nextIndex, solutionCountCacheFromIndex: &solutionCountCacheFromIndex) * currentDicNode.numWordsEndingHere
                                nextDicNodes = currentDicNode.subNodes
                            }
                            else {
                                nextDicNodes = currentDicNode.subNodes
                            }
                        }
                        break
                    }
                }
            }
        }
        
        solutionCountCacheFromIndex[startingIndex] = numSolutionsFound
        return numSolutionsFound
    }
}


struct Game {
    let N:Int
    let dic : [[MorseValue]]
    let sequence : [MorseValue]
    let rootDicNode : DicNode
}

public func main() {
    let L = readLine("L")!
    let N = Int(readLine()!)!
    var dic : [[MorseValue]] = []
    
    let sequence = try! convertToMorseArray(morse: L)
    var dicWordSizes : [DicIndex:[Int]] = [:]

    if N > 0 {
        for i in 0...(N-1) {
            let word = try! convertToMorse(readLine()!)
            if word.count > 0 {
                dic.append(word)
            }
            for j in 1...word.count {
                if dicWordSizes[j] == nil {
                    dicWordSizes[j] = []
                }
                dicWordSizes[j]!.append(i)
            }
            
        }
    }
    let rootDicNode = constructDicNode(startIndex: 0, subWord: [], subDic: dic)
    let game = Game(N: N, dic: dic, sequence:sequence, rootDicNode: rootDicNode)
    var solutionsFound : [Int:Int] = [:]

    let s = countSolutions(game, startingIndex: 0, solutionCountCacheFromIndex: &solutionsFound)

    print(s)
}

//main()
