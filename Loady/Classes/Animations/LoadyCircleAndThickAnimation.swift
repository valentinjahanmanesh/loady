//
//  LoadyCircleAndThickAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
public extension LoadyAnimationType {
	static func circleAndTick()->LoadyCircleAndTickAnimation{
		return LoadyCircleAndTickAnimation()
	}
}
public class LoadyCircleAndTickAnimation: LoadyAnimation, LoadyPercentageObserver {
	private var loading: Bool = false
	public func isLoading() -> Bool {
		return loading
	}
	
	public func inject(loady: Loadiable) {
		self.loady = loady
	}
	
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "circleAndTick")
	private unowned var loady: Loadiable!
	private var strokeFillerLayer: CAShapeLayer?
	
	public func change(from: CGFloat, to: CGFloat) {
		let animation = LoadyCore.createBasicAnimation(keypath: "strokeEnd", from: NSNumber(floatLiteral: Double(from / 100)), to: NSNumber(floatLiteral: Double(to / 100)),duration : 0.2)
		animation.isRemovedOnCompletion = false;
		animation.fillMode = .forwards;
		self.strokeFillerLayer?.add(animation, forKey: nil)
	}
	
	public func run() {
		loading = true
		let center = self.loady.center
		self.loady.cleanCanvas()
		let radius = min(self.loady.bounds.width, self.loady.bounds.height)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			UIView.animate(withDuration: 0.5, animations: {
				self.loady.center = center
				self.loady.transform = CGAffineTransform(scaleX: -1,y: 1)
				self.loady.bounds = CGRect(x:self.loady.center.x,y: self.loady.center.y,width: radius,height: radius)
				self.loady.layer.cornerRadius = radius / 2
				self.loady.backgroundColor = self.loady.backgroundFillColor
				self.loady.layoutIfNeeded()
			}, completion: { (finished) in
				if(finished){
					self.strokeFillerLayer = LoadyCore.createCircleInside(bounds: self.loady.bounds, strokeColor: self.loady.loadingColor)
					self.loady.addSublayer(self.strokeFillerLayer!)
				}
			})
		}
	}
	
	public func stop() {
		loading = false
		strokeFillerLayer?.removeAllAnimations()
		strokeFillerLayer?.removeFromSuperlayer()
		loady.reloadDefaultState(duration: 0.5) { [weak strokeFillerLayer] in
			strokeFillerLayer?.removeFromSuperlayer()
			strokeFillerLayer = nil;
		}
	}
}
