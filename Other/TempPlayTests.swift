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

    func testScenario() throws {
        let fileName = "TempPlayTest1"
        

        let bundle = Bundle(for: TempPlayTests.self)
        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }


}
