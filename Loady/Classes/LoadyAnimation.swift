//
//  LoadyAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
// each animation needs to conform to this protocol
public protocol LoadyAnimation: LoadyPercentageObserver {
	static var animationTypeKey: LoadyAnimationType.Key { get }
	func inject(loady: Loadiable)
	mutating func run()
	mutating func stop()
	func isLoading()->Bool
}

extension LoadyAnimation {
	mutating public func change(from: CGFloat, to: CGFloat) {}
}

public protocol LoadyPercentageObserver {
	/// notifies other functions about percent changes
	///
	/// - Parameters:
	///   - new: new value
	///   - old: current value
	mutating func change(from: CGFloat, to: CGFloat)
	mutating func completed(lastetValue: CGFloat)
}
extension LoadyPercentageObserver {
	mutating public func completed(lastetValue: CGFloat) {}
}
