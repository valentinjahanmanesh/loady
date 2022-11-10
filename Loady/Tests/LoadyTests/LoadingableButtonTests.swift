//
//  File.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation
@testable import Loady
import XCTest
import UIKit

final class LoadyTests: XCTestCase {
    var button: LoadingableButton!
    
    override func setUp() {
        button = LoadingableButton()
    }
    
    override func tearDown() {
        button = nil
    }
    
    func testStartLoading() {
        let loadingAnimator = UberAnimator()
        button.set(delegate: loadingAnimator)
        button.startLoading()
        XCTAssertTrue(button.isLoading)
    }
    
    func testStopLoading() {
        let loadingAnimator = UberAnimator()
        button.set(delegate: loadingAnimator)
        button.stopLoading()
        XCTAssertTrue(!button.isLoading)
    }
    
    func testSettingAnimatorDelegate() {
        let loadingAnimator = UberAnimator()
        button.set(delegate: loadingAnimator)
        XCTAssertEqual(loadingAnimator, button.animatorDelegate as! UberAnimator)
    }
    
    func testShouldAddLayer_OnStartOfAnimation() {
        let loadingAnimator = UberAnimator()
        button.set(delegate: loadingAnimator)
        let sublayersCount = button.layer.sublayers?.count ?? 0
        button.startLoading()

        XCTAssertGreaterThan(button.layer.sublayers?.count ?? 0, sublayersCount)
    }
    
    func testShouldRemoveAnimationLayer_OnStopOfAnimation() {
        let loadingAnimator = UberAnimator()
        button.set(delegate: loadingAnimator)
        let sublayersCount = button.layer.sublayers?.count ?? 0
        button.startLoading()
        button.stopLoading()
        XCTAssertLessThanOrEqual(button.layer.sublayers?.count ?? 0, sublayersCount)
    }
}
