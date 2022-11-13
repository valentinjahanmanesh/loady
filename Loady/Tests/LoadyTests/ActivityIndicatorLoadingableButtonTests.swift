//
//  ActivityIndicatorLoadingableButtonTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/11/2022.
//

import XCTest
@testable import Loady
import UIKit
let nanoSecondInSecond: UInt64 = 1_000_000_000
final class ActivityIndicatorLoadingableButtonTests: XCTestCase {
    
    var button: ActivityIndicatorLoadingableButton!
    override func setUp() {
        button = ActivityIndicatorLoadingableButton(frame: .init(x: 0, y: 0, width: 300, height: 70))
        button.setTitle("Loading", for: .normal)
    }
    
    override func tearDown() {
        button = nil
    }
    func defualtConfiguration(
        titleFrame: CGRect? = nil,
        edges:UIEdgeInsets? = nil,
        currentIndicatorCenterX: CGFloat = 0,
        spaceBetweenLabelAndIndicator: CGFloat = 2,
        configuration: ActivityIndicatorAnimator.Configuration = .init(
            indicatorPosition: .leading,
            size: .init(width: 20, height: 20),
            buttonLabelPosition: .move
        )
    ) -> (
        configuration: ActivityIndicatorAnimator.Configuration,
        titleFrame: CGRect,
        edges: UIEdgeInsets,
        currentIndicatorCenterX: CGFloat,
        spaceBetweenLabelAndIndicator: CGFloat
    ){
        return (
            configuration,
            titleFrame ?? button.titleLabel!.frame,
            edges ?? button.titleEdgeInsets,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator
        )
    }
    // MARK: - On Loading Started
    func testShouldCalcullateLoadingPosition_WhenNoTitleEdgeSetLeadingIndicator_OnLoadingStarted() {
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration()
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        
        XCTAssertEqual(indicatorViewNewCenterX, titleFrame.origin.x)
    }
    
    func testShouldCalcullateLoadingPosition_WhenNotTitleEdgeSetTrailingIndicator_OnLoadingStarted() {
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        
        XCTAssertEqual(indicatorViewNewCenterX, titleFrame.width + titleFrame.origin.x)
    }
    
    func testShouldCalcullateLoadingPosition_WhenHasTitleEdgeSetTrailingIndicator_OnLoadingStarted() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        
        XCTAssertEqual(indicatorViewNewCenterX, titleFrame.width + titleFrame.origin.x)
    }
    
    func testShouldCalcullateLoadingPosition_WhenHasTitleEdgeSetLeadingIndicator_OnLoadingStarted() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .leading))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        
        XCTAssertEqual(indicatorViewNewCenterX, titleFrame.origin.x)
    }
    
    func testShouldCalcullateTitlePosition_WhenNoTitleEdgeSetLeadingIndicator_OnLoadingStarted() {
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration()
        let newTitleEdges = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        
        XCTAssertEqual(newTitleEdges.left, configuration.size.width + spaceBetweenLabelAndIndicator)
    }
    
    func testShouldCalcullateTitlePosition_WhenNotTitleEdgeSetTrailingIndicator_OnLoadingStarted() {
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let newTitleEdges = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        XCTAssertEqual(newTitleEdges.left,  -(configuration.size.width + spaceBetweenLabelAndIndicator))
    }
    
    func testShouldCalcullateTitlePosition_WhenHasTitleEdgeSetTrailingIndicator_OnLoadingStarted() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let newTitleEdges = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        XCTAssertEqual(newTitleEdges.left,  edges.left - (configuration.size.width + spaceBetweenLabelAndIndicator))
    }
    
    func testShouldCalcullateTitlePosition_WhenHasTitleEdgeSetLeadingIndicator_OnLoadingStarted() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .leading))
        let newTitleEdges = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        XCTAssertEqual(newTitleEdges.left, edges.left + configuration.size.width + spaceBetweenLabelAndIndicator)
    }
    
    // MARK: - On Loading Stopped
    func testShouldCalcullateLoadingPosition_WhenNoTitleEdgeSetLeadingIndicator_OnLoadingStopped() {
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration()
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        
        XCTAssertEqual(indicatorViewNewCenterX, currentIndicatorCenterX)
    }
    
    func testShouldCalcullateLoadingPosition_WhenNotTitleEdgeSetTrailingIndicator_OnLoadingStopped() {
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        
        XCTAssertEqual(indicatorViewNewCenterX, currentIndicatorCenterX)
    }
    
    func testShouldCalcullateLoadingPosition_WhenHasTitleEdgeSetTrailingIndicator_OnLoadingStopped() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        
        XCTAssertEqual(indicatorViewNewCenterX, currentIndicatorCenterX)
    }
    
    func testShouldCalcullateLoadingPosition_WhenHasTitleEdgeSetLeadingIndicator_OnLoadingStopped() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            _,
            currentIndicatorCenterX,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .leading))
        let indicatorViewNewCenterX = button.calculateIndicatorPosition(options: configuration, titleFrame: titleFrame, currentIndicatorCenterX: currentIndicatorCenterX, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        
        XCTAssertEqual(indicatorViewNewCenterX, currentIndicatorCenterX)
    }
    
    func testShouldCalcullateTitlePosition_WhenNoTitleEdgeSetLeadingIndicator_OnLoadingStopped() {
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration()
        let onStarted = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        let onStopped = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        XCTAssertEqual(onStarted.left, -onStopped.left)
    }
    
    func testShouldCalcullateTitlePosition_WhenNotTitleEdgeSetTrailingIndicator_OnLoadingStopped() {
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let onStarted = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        let onStopped = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        XCTAssertEqual(onStarted.left, -onStopped.left)
    }
    
    func testShouldCalcullateTitlePosition_WhenHasTitleEdgeSetTrailingIndicator_OnLoadingStopped() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .trailing))
        let onStarted = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        let onStopped = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: onStarted, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        XCTAssertEqual(edges.left, onStopped.left)
    }
    
    func testShouldCalcullateTitlePosition_WhenHasTitleEdgeSetLeadingIndicator_OnLoadingStopped() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let (
            configuration,
            titleFrame,
            edges,
            _,
            spaceBetweenLabelAndIndicator) = defualtConfiguration(configuration: .init(indicatorPosition: .leading))
        let onStarted = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: edges, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: true)
        let onStopped = button.calculateTitleEdge(options: configuration, titleFrame: titleFrame, currentTitleEdgeInsets: onStarted, spaceBetweenLabelAndIndicator: spaceBetweenLabelAndIndicator, isLoading: false)
        XCTAssertEqual(edges.left, onStopped.left)
    }
    
    // MARK: - Title hidden
    func testShouldHiddenTitle_OnStart() {
        button.titleEdgeInsets = .init(top: 0, left: -100, bottom: 0, right: -10)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        let configuration = ActivityIndicatorAnimator.Configuration(indicatorPosition: .leading, buttonLabelPosition: .hidden)
        button
            .set(options: configuration)
            .startLoading()
        
        XCTAssertEqual(button.titleLabel!.layer.opacity, 0)
    }
    
    // MARK: - On Loading Stopped
    func testShouldShowTitle_OnStart() {
        let configuration = ActivityIndicatorAnimator.Configuration(indicatorPosition: .leading, buttonLabelPosition: .hidden)
        button
            .set(options: configuration)
            .startLoading()
        
        button.stopLoading()
        XCTAssertEqual(button.titleLabel!.layer.opacity, 1)
    }
}
