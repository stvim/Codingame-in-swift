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


    func testScenario() throws {
//        let fileName = "test1"
//
//
//        let bundle = Bundle(for: The_ResistanceTests.self)
//        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
//        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        solve(n: 6, targetImage: [".#.#..", ".#.#..", "...#..", ".#.#..", ".#.#..", ".#.#.."])
    }

}
