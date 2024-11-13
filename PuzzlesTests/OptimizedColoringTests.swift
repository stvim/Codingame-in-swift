//
//  OptimizedColoringTests.swift
//  Codingame-in-Swift
//
//  Created by Steven Morin on 11/11/2024.
//


import XCTest
import CodingameCommon
@testable import Puzzles

final class OptimizedColoringTests: XCTestCase {
    let dataFilenames = ["", "OptimizedColoringData07"]
    
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
        optimizedColoring()
    }
        
}
