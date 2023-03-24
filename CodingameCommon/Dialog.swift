
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

extension FileHandle: TextOutputStream {
  public func write(_ string: String) { self.write(Data(string.utf8)) }
}
public var errStream = FileHandle.standardError


public class DialogInteractive : IDialog {
    public init() { }
    
    public func writeArray(_ arg: [Any], separator: String, terminator: String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        print(output, terminator: terminator)
    }
    public func debugArray(_ arg:[Any], separator:String, terminator:String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        print("***",output, terminator: terminator, to: &errStream)
    }
    public func read(_ message:String) -> String? {
        write(message, ": ", terminator : "")
        return read()
    }
    public func read() -> String? {
        return readLine()
    }
}



public class DialogTestFile : IDialog {
//    let testName:String
    let testInputContent:[Substring]
    var testOutputContent:[String] = []
    var currentLine = 0
    
    public init(inputTestFile:URL) {
        let fileData = try! String(contentsOf: inputTestFile)
        testInputContent = fileData.split { $0.isNewline }
    }
    
    public func writeArray(_ arg: [Any], separator: String, terminator: String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        testOutputContent.append(output)
        print(output, terminator: terminator)
    }
    public func debugArray(_ arg:[Any], separator:String, terminator:String) {
        let output = arg.map{"\($0)"}.joined(separator: separator)
        print("***",output, terminator: terminator, to: &errStream)
    }
    public func read(_ message:String) -> String? {
        write(message, ": ", terminator : "")
        return read()
    }
    public func read() -> String? {
        if testInputContent.count > currentLine {
            let r = testInputContent[currentLine]
            currentLine += 1
            write(currentLine)
            return String(r)
        }
        else {
            write("*** end ***")
            return nil
        }
    }
}
