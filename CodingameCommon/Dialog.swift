import Foundation
extension FileHandle: TextOutputStream {
  public func write(_ string: String) { self.write(Data(string.utf8)) }
}
public var errStream = FileHandle.standardError

extension String {
    public static let eol = "\n"
    public static let empty = ""
    public static let defaultTerminator = eol
    public static let defaultSeparator = " "
}

extension Array {
    public func joinedStrings(separator: String) -> String {
        return self.map{"\($0)"}.joined(separator: separator)
    }
}

public func print(_ args:Any..., separator:String = .defaultSeparator, terminator:String = .defaultTerminator) -> Void {
    let output = args.joinedStrings(separator: separator)

    Dialog.allOutputs.append(output)
    Swift.print(output,terminator: terminator)
}


public func debug(_ args:Any..., separator:String = .defaultSeparator, terminator:String = .defaultTerminator) {
    let output = args.joinedStrings(separator: separator)
    Swift.print("***",output, terminator: terminator, to: &errStream)
    
    if Dialog.verboseDebug {
        Swift.print("-- all inputs ---", Dialog.allInputs.joined(separator: .eol), separator: .eol, to: &errStream)
        Swift.print("-- all outputs --", Dialog.allOutputs.joined(separator: .eol), separator: .eol, to: &errStream)
        Swift.print("-----------------", to: &errStream)
    }
}


public class GameData {
    let dataInputContent:[String]
    var dataOutputContent:[String] = []
    private var currentDataInputLine = 0
    
    public init(inputDataFile:URL) {
        let fileData = try! String(contentsOf: inputDataFile)
        dataInputContent = fileData.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline }).map( String.init )
    }
    
    public init(inputStrings:[String]) {
        dataInputContent = inputStrings
    }
    
    public func readLineOfInputData() -> String? {
        if dataInputContent.count > currentDataInputLine {
            let r = dataInputContent[currentDataInputLine]
            currentDataInputLine += 1
            return r
        }
        else {
            return nil
        }
    }
}

public enum DialogMode {
    case Interactive
    case Scenario(gameData:GameData)
}
public struct Dialog {
    public static var allInputs : [String] = []
    public static var allOutputs : [String] = []
    public static var mode : DialogMode = .Interactive
    public static var verboseDebug = false
}

public func readLine() -> String? {
    return readLine(nil)
}
public func readLine(_ message:String?) -> String? {
    let prompt : String
    if let message {
        prompt = " > \(message) > "
    } else {
        prompt = " > "
    }
    
    Swift.print(prompt, terminator: .empty)
    
    var inputLine : String?
    switch(Dialog.mode) {
    case .Interactive:
        inputLine = Swift.readLine()
    case .Scenario(let gameData):
        inputLine = gameData.readLineOfInputData()
        Swift.print(inputLine ?? "\n\t---- end of scenario ----\n")
    }
    
    Dialog.allInputs.append(prompt + (inputLine ?? "*nil*"))
    
    return inputLine
}
