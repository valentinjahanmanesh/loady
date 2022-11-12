//
//  AnimationProgressValueTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import XCTest
@testable import Loady
final class AnimationProgressValueTests: XCTestCase {
    func testShouldNormalizeTheNumberBetweenZeroAndOne() {
        let asserts: (_ value: Float16) -> Void = {value in
            let progress = AnimationProgressValue(rawValue: value)
            XCTAssertLessThanOrEqual(progress.rawValue, 1)
            XCTAssertGreaterThanOrEqual(progress.rawValue, 0)
            
            if progress.rawValue >= 1 {
                XCTAssertEqual(progress.rawValue, 1)
            } else if progress.rawValue <= 0 {
                XCTAssertEqual(progress.rawValue, 0)
            } else {
                XCTAssertEqual(progress.rawValue, abs(value))
            }
        }
        
        asserts(1)
        asserts(5)
        asserts(0.3)
        asserts(-0.3)
        asserts(-0.6)
        asserts(0.7)
    }
}
