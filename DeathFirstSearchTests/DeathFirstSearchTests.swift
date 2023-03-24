//
//  DeathFirstSearchTests.swift
//  DeathFirstSearchTests
//
//  Created by Steven Morin on 23/03/2023.
//

import XCTest
import CodingameCommon
@testable import DeathFirstSearch

final class DeathFirstSearchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInteractive() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let dialogMode = DialogInteractive()

//        main(dialog: dialogMode)
    }

    func test() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let fileName = "test1"
        
//        print("--------------------")
//        listDirectoryContents(at: Bundle.main.bundleURL)
//        print("--------------------")
//        findTextFile(filename: "test1", fileExtension: "txt")
//        print("--------------------")
//
//        let testFilePath = fileName + ".txt"
        let bundle = Bundle(for: DeathFirstSearchTests.self)
        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
        let dialogTest = DialogTestFile(inputTestFile: fileUrl)
        main(dialog: dialogTest)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
