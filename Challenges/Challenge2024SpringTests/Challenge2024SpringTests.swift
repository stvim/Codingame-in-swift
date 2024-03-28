//
//  Challenge2024SpringTests.swift
//  Challenge2024SpringTests
//
//  Created by Steven Morin on 27/03/2024.
//

import XCTest
@testable import Challenge2024Spring

final class Challenge2024SpringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


//    func testScenario() throws {
//        let fileName = "test1"
//
//
//        let bundle = Bundle(for: The_ResistanceTests.self)
//        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
//        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
//        solve(n: 6, targetImage: [".#.#..", ".#.#..", "...#..", ".#.#..", ".#.#..", ".#.#.."])
//    }

    func test_level4() {
        let input0 = 8
        let input1 = 12
        let input2 = ["bbCCCCC3cC3c","1CAABBBC3c3c","aCAAbbbC312A","aCCBbabCB111","3CBBbbbC2C12","CCBAca3C2a1C","2ACCCCCaaaaa","b33ccccccccc"]
        
        debugPrint(String(describing: findLargestCircle(nRows: input0, nCols: input1, image: input2)))
    }
    
    func test_level9() {
        let input0 = [
            "01", "101", "011"
        ]
        let input3 = [
            "1", "10", "00"
            ]
        let result0 = "01101"
        let result3 = "X"
        debugPrint(crashDecode(codes: input3)!)
    }
}
