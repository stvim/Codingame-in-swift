import XCTest
import CodingameCommon
@testable import Enigma

final class EnigmaPuzzleTests: XCTestCase {
    let dataFilenames = ["", "EnigmaPuzzleData01", "EnigmaPuzzleData02",  "EnigmaPuzzleData03"]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testData01() throws {

        let bundle = Bundle(for: EnigmaPuzzleTests.self)
        let fileUrl = bundle.url(forResource: dataFilenames[1], withExtension: "")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }
    
    func testData02() throws {

        let bundle = Bundle(for: EnigmaPuzzleTests.self)
        let fileUrl = bundle.url(forResource: dataFilenames[2], withExtension: "")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }
    
    func testData03() throws {

        let bundle = Bundle(for: EnigmaPuzzleTests.self)
        let fileUrl = bundle.url(forResource: dataFilenames[3], withExtension: "")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }

}
