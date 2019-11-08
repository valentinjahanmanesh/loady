//
//  LoadyAndroidAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
public extension LoadyAnimationType {
	static func android()->LoadyAndroidAnimation{
		return LoadyAndroidAnimation()
	}
}
public class LoadyAndroidAnimation {
	private var loading: Bool = false
	public func isLoading() -> Bool {
		return loading
	}
	
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "circleAndTick")
	private unowned var loady: Loadiable!
	private var strokeFillerLayer: CAShapeLayer?
	private func startCircluarLoadingAnimation(_ layer : CAShapeLayer) {
		var time: CFTimeInterval = 0
		var times = [CFTimeInterval]()
		var start: CGFloat = 0
		var rotations = [CGFloat]()
		var strokeEnds = [CGFloat]()
		let poses = LoadyCore.poses
		let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
		
		for pose in poses {
			time += pose.secondsSincePriorPose
			times.append(time / totalSeconds)
			start = pose.start
			rotations.append(start * 2 * .pi)
			strokeEnds.append(pose.length)
		}
		
		times.append(times.last!)
		rotations.append(rotations[0])
		strokeEnds.append(strokeEnds[0])
		
		LoadyCore.animateKeyPath(layer,keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
		LoadyCore.animateKeyPath(layer,keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
		
		animateStrokeHueWithDuration(layer ,duration: totalSeconds * 5)
	}
	
	private func animateStrokeHueWithDuration(_ layer  : CAShapeLayer, duration: CFTimeInterval) {
		let count = 200
		let animation = CAKeyframeAnimation(keyPath: "strokeColor")
		animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
		let loadingColor = self.loady.loadingColor
		animation.values = (0 ... count).map {num in
			if num <= 3  && animation.accessibilityHint == nil{
				return loadingColor.withAlphaComponent(CGFloat(num) / 3.0).cgColor
			}else{
				return  loadingColor.cgColor
			}
		}
		animation.duration = duration
		animation.calculationMode = .linear
		animation.autoreverses = true
		
		animation.repeatCount = Float.infinity
		layer.add(animation, forKey: animation.keyPath)
	}
}

extension LoadyAndroidAnimation: LoadyAnimation, LoadyPercentageObserver {
	public func inject(loady: Loadiable) {
		self.loady = loady
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
	
	public func run() {
		loading = true
		let center = self.loady.center
		self.loady.cleanCanvas()
		let radius = min(self.loady.bounds.width, self.loady.bounds.height)
		
			UIView.animate(withDuration: 0.3, animations: {
				self.loady.center = center
				self.loady.layer.bounds = CGRect(x: self.loady.center.x, y: self.loady.center.y, width: radius, height: radius)
				self.loady.layer.cornerRadius = radius / 2
				self.loady.backgroundColor = self.loady.backgroundFillColor
				self.loady.layoutIfNeeded()
			}, completion: { (finished) in
				if(finished){
					self.strokeFillerLayer = LoadyCore.createCircleInside(bounds: self.loady.bounds.insetBy(dx: -4, dy: -4), strokeColor: self.loady.loadingColor)
					self.loady.addSublayer(self.strokeFillerLayer!)
					self.startCircluarLoadingAnimation(self.strokeFillerLayer!)
				}
			})
	}
	
}
