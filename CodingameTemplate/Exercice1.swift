/********************* HEADER ****************/
#if canImport(CodingameCommon)
import CodingameCommon
import Darwin
#else
import Glibc
let VERBOSEDEBUG = false

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

extension String { static var EOL = "\n" }
public let defaultTerminator = String.EOL, defaultSeparator = " "

public func print(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) -> Void {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Dialog.allOutputs.append(output)
    Swift.print(output,terminator: terminator)
    if VERBOSEDEBUG {
        debug("-- all inputs ---", Dialog.allInputs.joined(separator: String.EOL), separator: String.EOL)
        debug("-- all outputs --", Dialog.allOutputs.joined(separator: String.EOL), separator: String.EOL)
    }
}

public func debug(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print(output, terminator: terminator, to: &errStream)
}

struct Dialog {
    static var allInputs : [String] = []
    static var allOutputs : [String] = []
}
public func readLine() -> String? {
    return readLine(nil)
}
public func readLine(_ message:String?) -> String? {
    let r = Swift.readLine()
    if let r = r {
        if let message = message {
            Dialog.allInputs.append(" > \(message) > \(r)")
        } else {
            Dialog.allInputs.append(r)
        }
    }
    return r
}
#endif
import Foundation
/********************* END of HEADER ****************/

enum Mode {
    case encode, decode
}

public func main() {
    let operation = readLine()! == "ENCODE" ? Mode.encode : Mode.decode
    let pseudoRandomNumber = Int(readLine()!)!
    var rotor = [[Int]]()
    for _ in 0...2 {
        rotor.append(readLine()!.compactMap(charToAlphabetPosition))
    }

    let input = readLine()!.compactMap(charToAlphabetPosition)
    let output : [Int]
    
    switch(operation) {
    case .encode:
        output = encode(input, startKey: pseudoRandomNumber, rotor: rotor)
    case .decode:
        output = decode(input, startKey: pseudoRandomNumber, rotor: rotor)
    }
    
    print(output.stringFromAlphabetPositions)
    // Write an answer using print("message...")
    // To debug: print("Debug messages...", to: &errStream)

//    print("message")
}

func charToAlphabetPosition(_ char: Character) -> Int? {
    guard let asciiValue = char.asciiValue else { return nil }
    let position = Int(asciiValue) - Int(Character("A").asciiValue!)
    return position >= 0 && position < 26 ? position : nil
}

func alphabetPositionToChar(_ position: Int) -> Character? {
    guard position >= 0 && position < 26 else { return nil }
    let asciiValue = Int(Character("A").asciiValue!) + position
    return Character(UnicodeScalar(asciiValue)!)
}

extension Array where Element == Int {
    var stringFromAlphabetPositions : String {
        return self.compactMap( alphabetPositionToChar ).map( String.init ).reduce("", +)
    }
}

func encode(_ message: [Int], startKey: Int, rotor:[[Int]]) -> [Int] {
    var key = startKey
    var result = [Int]()
    for c in message {
        result.append(rotor[2][rotor[1][rotor[0][(c + key).positiveModulo(26)]]])
        key += 1
    }
    return result
}
func decode(_ cryptedMessage: [Int], startKey: Int, rotor:[[Int]]) -> [Int] {
    var key = startKey
    var result = [Int]()
    for c in cryptedMessage {
        let positionInFirstRotor = rotor[0].firstIndex(of: rotor[1].firstIndex(of: rotor[2].firstIndex(of: c)!)!)!
        result.append((positionInFirstRotor - key).positiveModulo(26))
        key += 1
    }
    debug(result)
    return result
}

extension Int {
    func positiveModulo(_ divisor: Int) -> Int {
        let result = self % divisor
        return result >= 0 ? result : result + divisor
    }
}



//main()
