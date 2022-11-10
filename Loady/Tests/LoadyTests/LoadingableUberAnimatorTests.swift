//
//  LoadingableUberAnimatorTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation
@testable import Loady
import XCTest
import UIKit

final class LoadingableUberAnimator: XCTestCase {
    var animator: UberAnimator!
    var button: LoadingableButton!
    override func setUp() {
        animator = UberAnimator()
        button = LoadingableButton()
        button.set(delegate: animator)
    }
    
    override func tearDown() {
        animator = nil
        button = nil
    }
    
    func testStartLoading() {
        animator.start()
        XCTAssertTrue(animator.isLoading)
    }
    
    func testStopLoading() {
        animator.stop()
        XCTAssertTrue(!animator.isLoading)
    }
    
    func testSettingCanvas() {
        XCTAssertNotNil(animator.canvas)
    }
    
    func testShouldDefaultOption_OnStart() {
        let options = UberAnimator.Options.default
        XCTAssertEqual(options, animator.options)
    }
    
    func testShouldChangeOptions_OnNewOptionPass() {
        let options = UberAnimator.Options(indicatorLength: 0.9, indicatorTickness: 10, indicatorDirection: .rtl, indicatorColor: .red)
        animator = UberAnimator(options: options)
        XCTAssertEqual(options, animator.options)
    }
    
    func testShouldValidateLength_WouldBeLessThanOrEqualToCanvas() {
        let options = UberAnimator.Options(indicatorLength: 1.9, indicatorTickness: 10, indicatorDirection: .rtl, indicatorColor: .red)
        animator = UberAnimator(options: options)
        XCTAssertEqual(min(options.indicatorLength, 1), animator.options.indicatorLength)
    }
}

