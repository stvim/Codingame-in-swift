//
//  SuperComputerTests.swift
//  SuperComputerTests
//
//  Created by Steven Morin on 15/05/2023.
//

import XCTest
import CodingameCommon
@testable import SuperComputer

final class SuperComputerTests: XCTestCase {


    func testScenario() throws {
        let fileName = "test_piege"
        

        let bundle = Bundle(for: SuperComputerTests.self)
        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
//        main()
        main_solution_CG_short()
    }

}
