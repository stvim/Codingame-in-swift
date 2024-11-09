//
//  RubiksCubeReassemblyTests.swift
//  CheatSolvingTests
//
//  Created by Steven Morin on 07/11/2024.
//

import XCTest
import CodingameCommon
@testable import CheatSolving

final class RubiksCubeReassemblyTests: XCTestCase {
    let dataFilenames = ["", "RubiksCubeReassemblyData01", "RubiksCubeReassemblyData02"]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        Dialog.verboseDebug = true
        //debug("COMPLETE LOG", String(repeating: "*", count: 50))
    }
    
    func testData01() throws {
        
        let bundle = Bundle(for: Self.self)
        let fileUrl = bundle.url(forResource: dataFilenames[1], withExtension: "")!
        
        Dialog.mode = .Scenario(gameData: GameData(inputDataFile: fileUrl))
        RubiksCubeReassembly()
    }
    
    func testData02() throws {
        
        let bundle = Bundle(for: Self.self)
        let fileUrl = bundle.url(forResource: dataFilenames[2], withExtension: "")!
        
        Dialog.mode = .Scenario(gameData: GameData(inputDataFile: fileUrl))
        RubiksCubeReassembly()
    }
    
}
