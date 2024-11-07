//
//  OtherTests.swift
//  OtherTests
//
//  Created by Steven Morin on 04/04/2023.
//

import XCTest
import CodingameCommon
@testable import Other

final class TempPlayTests: XCTestCase {

//    func testScenario() throws {
//        let fileName = "TempPlayTest1"
//        
//
//        let bundle = Bundle(for: TempPlayTests.self)
//        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
//        
//        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
//        main()
//    }
//
//    func testInteractive() throws {
//        Dialog.mode = DialogMode.Interactive
//        main()
//    }
    override func tearDown() {
        Dialog.verboseDebug = true
        debug("COMPLETE LOG", (0...50).map{_ in "*"}.reduce(.empty, +))
    }

    func testFromString() throws {
        let inputs = [
            "1"
            ,"xxx!xx xxx!! Xxxx!!xxx"
        ]
        Dialog.mode = .Scenario(gameData: GameData(inputStrings: inputs))
        main()
    }

}
