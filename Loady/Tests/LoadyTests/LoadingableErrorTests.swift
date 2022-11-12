//
//  LoadingableButtonTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/11/2022.
//

import Foundation
import XCTest
@testable import Loady
final class LoadingableButtonTests: XCTestCase {
    func testShouldAllTheErrorsHaveDescriptions() {
        let error: LoadingableButtonError = .typeOfAnimationIsNotProgressive(error: .animatorTypeMismatched)
        switch error {
        case .typeOfAnimationIsNotProgressive(let error):
            XCTAssertEqual(error, .animatorTypeMismatched)
        case .missingObjects(error: let error):
            break
        }
    }
}
