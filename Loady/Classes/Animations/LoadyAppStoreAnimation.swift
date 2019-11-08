//
//  LoadyAppStoreAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

public extension LoadyAnimationType {
	static func appstore(with options: LoadyAppStoreAnimation.AnimationOption)->LoadyAppStoreAnimation{
		return LoadyAppStoreAnimation(options: options)
	}
}

// MARK: - Creates the AppStore
public class LoadyAppStoreAnimation {
	private var loading: Bool = false
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "appstore")
	public struct AnimationOption {
		public enum ShrinkStyle {
			case fromLeft
			case fromRight
		}
		public var shrinkFrom: ShrinkStyle = .fromLeft
		public init(shrinkFrom: ShrinkStyle) {
			self.shrinkFrom = shrinkFrom
		}
	}
	init(options: AnimationOption) {
		self.options = options
	}
	
	init(loady: Loadiable, options: AnimationOption) {
		self.loady = loady
		self.options = options
	}
	private unowned var loady: Loadiable!
	private let options: AnimationOption
	private var circleContainer: CAShapeLayer?
	private var strokeFillerLayer: CAShapeLayer?
	
	public func change(from: CGFloat, to: CGFloat) {
		let animation = LoadyCore.createBasicAnimation(keypath: "strokeEnd", from: NSNumber(floatLiteral: Double(from / 100)), to: NSNumber(floatLiteral: Double(to / 100)),duration : 0.2)
		animation.isRemovedOnCompletion = false;
		animation.fillMode = .forwards;
		self.strokeFillerLayer?.add(animation, forKey: nil)
	}
	
	private func createAppstoreLoadingLayer(){
		guard let loady = self.loady else {
			assertionFailure("loady is not passed, please use init(loady, options)")
			return
		}
		let strokeFillerLayer = LoadyCore.createCircleInside(bounds: self.loady.bounds.insetBy(dx: -4, dy: -4), strokeColor: self.loady.loadingColor, centerX: self.loady.bounds.height / 2)
		loady.addSublayer(strokeFillerLayer)
		self.strokeFillerLayer = strokeFillerLayer
		let circleContainer = LoadyCore.copy(layer: strokeFillerLayer)
		circleContainer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		circleContainer.strokeStart = 0
		circleContainer.strokeEnd = 1
		circleContainer.opacity = 1
		// check if user specifies an image for pause
		if let image = self.loady.pauseImage {
			let imageLayer = CAShapeLayer()
			imageLayer.bounds = CGRect(x:0,y: 0,width: 15,height: 15);
			imageLayer.position = CGPoint(x: circleContainer.bounds.midX,y: circleContainer.bounds.midY);
			imageLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
			imageLayer.contents = image.cgImage
			circleContainer.addSublayer(imageLayer)
		}
		self.circleContainer = circleContainer
		loady.addSublayer(circleContainer)
		
		circleContainer.add(LoadyCore.createBasicAnimation(keypath: "opacity", from: 0.0, to: 1.0, duration: 0.2), forKey: "fade")
		
	}
}

extension LoadyAppStoreAnimation: LoadyAnimation, LoadyPercentageObserver {
	public func isLoading() -> Bool {
		return loading
	}
	public func inject(loady: Loadiable) {
		self.loady = loady
	}
	
	public func run() {
		loading = true
		let radius = min(self.loady.frame.size.width, self.loady.frame.size.height)  * 0.7
		let xPosition = self.options.shrinkFrom == .fromRight ? 0 : self.loady.bounds.width - radius
		self.loady.cleanCanvas()
		UIView.animate(withDuration: 0.3, animations: {
			self.loady.layer.cornerRadius = radius / 2
			self.loady.layer.bounds = CGRect(x: 0,y: self.loady.center.y,width: radius,height: radius)
			self.loady.frame.origin.x = xPosition
			self.loady.alpha = 1
			self.loady.backgroundColor = self.loady.backgroundFillColor
			self.loady.layoutIfNeeded()
		}) {done in
			self.createAppstoreLoadingLayer()
		}
	}
	
	public func stop() {
		loading = false
		circleContainer?.removeFromSuperlayer()
		strokeFillerLayer?.removeAllAnimations()
		strokeFillerLayer?.removeFromSuperlayer()
		loady.reloadDefaultState(duration: 0.5) { [weak strokeFillerLayer] in
			strokeFillerLayer?.removeFromSuperlayer()
			strokeFillerLayer = nil;
		}
	}
}
