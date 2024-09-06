//
//  SwiftCertificationTests.swift
//  SwiftCertificationTests
//
//  Created by Steven Morin on 31/05/2024.
//

import XCTest
import CodingameCommon
@testable import SwiftCertification

final class Certification01Tests: XCTestCase {

    func testScenario() throws {
        let fileName = "Certification01Data01"
        

        let bundle = Bundle(for: Certification01Tests.self)
        let fileUrl = bundle.url(forResource: fileName, withExtension: "txt")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
    }


}
