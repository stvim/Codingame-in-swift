import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()



enum Morse {
    case dot
    case dash
}

func morse(from string: String) -> [Morse] {
    var morseResult: [Morse] = []
    for ch in string {
        switch ch {
        case ".": morseResult.append(.dot)
        case "-": morseResult.append(.dash)
        default: return []
        }
    }
    return morseResult
}

func morse(_ word: String) -> [Morse] {
    var morseResult: [Morse] = []
    for char in word {
        morseResult += morseAlphabet[char]!
    }
    return morseResult
}

let morseAlphabet: [Character:[Morse]] = [
    "A": morse(from: ".-"),
    "B": morse(from: "-..."),
    "C": morse(from: "-.-."),
    "D": morse(from: "-.."),
    "E": morse(from: "."),
    "F": morse(from: "..-."),
    "G": morse(from: "--."),
    "H": morse(from: "...."),
    "I": morse(from: ".."),
    "J": morse(from: ".---"),
    "K": morse(from: "-.-"),
    "L": morse(from: ".-.."),
    "M": morse(from: "--"),
    "N": morse(from: "-."),
    "O": morse(from: "---"),
    "P": morse(from: ".--."),
    "Q": morse(from: "--.-"),
    "R": morse(from: ".-."),
    "S": morse(from: "..."),
    "T": morse(from: "-"),
    "U": morse(from: "..-"),
    "V": morse(from: "...-"),
    "W": morse(from: ".--"),
    "X": morse(from: "-..-"),
    "Y": morse(from: "-.--"),
    "Z": morse(from: "--..") ]



 class MorseWords {
    var dot: MorseWords?
    var dash: MorseWords?
    public var count: Int = 0

    public func add(_ morse: [Morse], at index: Int = 0) {
        if morse.count == index { self.count += 1 }
        else {
            let next = index + 1
            switch morse[index] {
            case .dot:
                if dot == nil { dot = MorseWords() }
                dot?.add(morse, at: next)
            case .dash:
                if dash == nil { dash = MorseWords() }
                dash?.add(morse, at: next)
            }
        }
    }
    
    public func next(from morse: Morse) -> MorseWords? {
        switch morse {
        case .dot: return dot
        case .dash: return dash
        }
    }
}

struct LookAhead {
    let nextIndex: Int
    let count: Int
    let answer: Int?
}

struct CountMorseCombinations {
    let code: [Morse]
    var answers: [Int?]
    let words: MorseWords

    public mutating func total() -> Int { return doCount(at: 0) }

    public init(from words: MorseWords, in code: [Morse]) {
        self.words = words
        self.code = code
        self.answers = [Int?](repeating: nil, count: code.count)
    }

    mutating func doCount(at index: Int = 0) -> Int {

        let lookAheadSolutions = lookAhead(in: words, at: index).reversed()
        if lookAheadSolutions.count == 0 {
            return index >= code.count ? 1 : 0
        }
        
        var countedAnswers = 0
        for solution in lookAheadSolutions {
            let remainder = solution.answer ?? doCount(at: solution.nextIndex)
            countedAnswers += solution.count * remainder
        }
        
        answers[index] = countedAnswers
        return countedAnswers
    }

    func lookAhead(in words: MorseWords, at index: Int) -> [LookAhead] {
        if index >= code.count { return [] }

        if let nextNode = words.next(from: code[index]) {
            var collectedAnswer: [LookAhead] = []
            
            let lookAheadAnswer = (index + 1 >= code.count) ? nil : answers[index + 1]
            if nextNode.count != 0  {
                collectedAnswer.append(LookAhead(nextIndex: index + 1, count: nextNode.count, answer: lookAheadAnswer))
            }
            return collectedAnswer + lookAhead(in: nextNode, at: index + 1)
        }
        
        return []
    }
}


/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

var mWords = MorseWords()

let L = readLine()!
let code = morse(from: L)

let N = Int(readLine()!)!
if N > 0 {
    for i in 0...(N-1) {
        let W = readLine()!
        mWords.add(morse(W))
    }
}

// Write an action using print("message...")
// To debug: print("Debug messages...", to: &errStream)

var theResistance = CountMorseCombinations(from: mWords, in: code)

let total = theResistance.total()
print(total)
