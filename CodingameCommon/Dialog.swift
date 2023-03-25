import Foundation
extension FileHandle: TextOutputStream {
  public func write(_ string: String) { self.write(Data(string.utf8)) }
}
public var errStream = FileHandle.standardError

public var defaultTerminator : String = "\n"
public var defaultSeparator : String = " "

public func print(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) -> Void {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print(output,terminator: terminator)
}


public func debug(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print("***",output, terminator: terminator, to: &errStream)
}


public class GameData {
    let dataInputContent:[String]
    var dataOutputContent:[String] = []
    private var currentDataInputLine = 0
    
    public init(inputDataFile:URL) {
        let fileData = try! String(contentsOf: inputDataFile)
        dataInputContent = fileData.split { $0.isNewline } .map( String.init )
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
    public static var mode : DialogMode = .Interactive
}


public func readLine(_ message:String) -> String? {
    print(message, ": ", terminator : "")
    var r : String?
    if case .Scenario(let gameData) = Dialog.mode {
        r = gameData.readLineOfInputData()
    }
    else { // Interactive mode
        r = readLine()
    }
    
    if let ur = r, ur == "" {
        r = nil
    }
    
    if let r = r {
        Dialog.allInputs.append(r)
    }
    
    if case .Scenario(_) = Dialog.mode {
        print(r ?? "\n\t---- end of scenario ----\n")
    }
    return r
}
