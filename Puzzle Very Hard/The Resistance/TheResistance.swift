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

/*
let morseAlphabet = [
    "A": "01", "B": "1000", "C": "1010", "D": "100", "E": "0",
    "F": "0010", "G": "110", "H": "0000", "I": "00", "J": "0111",
    "K": "101", "L": "0100", "M": "11", "N": "10", "O": "111",
    "P": "0110", "Q": "1101", "R": "010", "S": "000", "T": "1",
    "U": "001", "V": "0001", "W": "011", "X": "1001", "Y": "1011", "Z": "1100"
]
*/
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

//struct DicNode {
//    let sequence : [Bool]
//    let numberOfWordsEndingHere : Int
//    var childs:[DicNode] = []
//}


public typealias MorseValue = Bool
//public struct MorseValue : Bool {}
public typealias WordIndex = Int
public typealias DicIndex = Int

//func constructDicTree () -> DicNode {
//    var i = 0
//    var rootNode = DicNode(sequence: [], endOfWord: false)
//
//    func digInTree(startPosInWords:Int, startValue:Bool, dicToExplore:[[MorseValue]]) -> DicNode? {
//        var i = startPosInWords
//        var currentValue = startValue
//        var currentSequence : [MorseValue] = [startValue]
//        let wordsToExplore : [DicIndex] = []
//
//        for wordNum in dicToExplore where wordNum.count > startPosInWords {
//            if dicToExplore[wordNum][startPosInWords] == startValue {
//                wordsToExplore.append(wordNum)
//            }
//        }
//
//        if wordsToExplore.isEmpty {
//            return nil
//        }
//
//        i += 1
//        let wordsTooShort = { dicToExplore[$0].count <= i }
//        let wordsEndingHere = wordsToExplore.filter(wordsTooShort)
//        if !wordsEndingHere.isEmpty {
//            // stop digging
//            var currentNode = DicNode(sequence: currentSequence, numberOfWordsEndingHere: wordsEndingHere.count)
//            let nextWordsToExplore = wordsToExplore.removeAll(wordsTooShort)
//            currentNode.childs.append(digInTree(startPosInWords: i, startValue: true, dicToExplore: nextWordsToExplore ))
//            currentNode.childs.append(digInTree(startPosInWords: i, startValue: false, dicToExplore: nextWordsToExplore ))
//        }
//        else {
//            currentValue = dicToExplore[wordsToExplore.first!][i]
//
//
//        }
//
//
//        wordsToExplore.contains{dic[$0][i]}
//        var allWordsMatches = false
//    diggingPositions: repeat {
//            allWordsMatches = false
//
//            for wordNum in wordsToExplore {
//                if dic[wordNum][i]
//            }
//        } while allWordsMatches
//
//    }
//
//    while i<longuestWord {
//        for wordNum in dicWordSizes[i] {
//
//
//        }
//    }
//}

func exploreSequence(_ game:Game, fromIndexInSequence:Int, solutionsFoundFromIndex: inout [Int:Int]) -> Int {
    if let r = solutionsFoundFromIndex[fromIndexInSequence] {
        return r
    }
    else {
        var numSolutionsFound = 0
        for word in game.dic {
            if word.count <= (game.sequence.count - fromIndexInSequence) {
                let subsequence = game.sequence[fromIndexInSequence ..< (fromIndexInSequence + word.count)]
                if subsequence.elementsEqual(word) {
                    if subsequence.endIndex == game.sequence.endIndex {
                        numSolutionsFound += 1
                    }
                    else {
                        numSolutionsFound += exploreSequence(game, fromIndexInSequence: fromIndexInSequence + word.count, solutionsFoundFromIndex: &solutionsFoundFromIndex)
                    }
                }
            }
        }
        solutionsFoundFromIndex[fromIndexInSequence] = numSolutionsFound
        return numSolutionsFound
    }
}


struct Game {
    let N:Int
    let dic : [[MorseValue]]
    let sequence : [MorseValue]
}

public func main() {
    let L = readLine("L")!
    let N = Int(readLine()!)!
    var dic : [[MorseValue]] = []
    
    let sequence = try! convertToMorseArray(morse: L)
    var dicWordSizes : [DicIndex:[Int]] = [:]
//    var longuestWord = 0

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
    let game = Game(N: N, dic: dic, sequence:sequence)
    var solutionsFound : [Int:Int] = [:]
    let s = exploreSequence(game, fromIndexInSequence: 0, solutionsFoundFromIndex: &solutionsFound)

//    debug(solutionsFound)
    print(s)
}

//main()
