//
//  CodingameTemplateTests.swift
//  CodingameTemplateTests
//
//  Created by Steven Morin on 06/09/2024.
//

import XCTest
@testable import CodingameTemplate

final class Exercice1Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScenario() throws {
        let fileName = "Certification01Data01"
        

        let bundle = Bundle(for: Exercice1Tests.self)
        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }

}
