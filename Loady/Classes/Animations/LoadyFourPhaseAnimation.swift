//
//  LoadyFourPhaseAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

public extension LoadyAnimationType.Key {
	static func phasy(phases: LoadyAnimationOptions.FourPhases)->LoadyFourPhaseAnimation{
		return LoadyFourPhaseAnimation(phases: phases)
	}
}

// MARK: - Creates the Four Phases
public class LoadyFourPhaseAnimation {
	private var loading: Bool = false
	public static let animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "phasy")
	private unowned var loady: (Loadiable & UIButton)!
	init(phases: LoadyAnimationOptions.FourPhases) {
		self.phases = phases
		currentPhase = .normal(phases.normalPhase)
	}
	
	private var phases: LoadyAnimationOptions.FourPhases
	open private(set) var currentPhase : LoadyAnimationOptions.FourPhases.Phases
	// these keys are used to mark some layers as temps layer and we will remove them after animation is done
	private enum LayerTempKeys: String {
		case tempLayer = "temps"
		case circularLoading = "circularLoading"
		case downloading_percentLabel = "downloading_percentLabel"
		case downloading_downloadLabel = "downloading_downloadLabel"
	}
	
	private func createFourPhaseButton(){
		UIView.animate(withDuration: 0.3) {
			self.loady.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0);
			self.loady.layoutIfNeeded()
		}
		UIView.beginAnimations("changeTextTransition", context: nil)
		let animation = CATransition()
		animation.isRemovedOnCompletion = true
		animation.duration = 0.2
		animation.type = CATransitionType.push
		animation.subtype = CATransitionSubtype.fromTop
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		self.loady.titleLabel!.layer.add(animation, forKey:"changeTextTransition")
		
		switch currentPhase {
		case .normal(let name, let image , let background):
			self.loady.setTitle(name , for: .normal)
			self.loady.backgroundColor = background
			setupImagesInFourPhases(image)
			
			break
		case .loading(let name, let image, let background):
			self.loady.setTitle(name , for: .normal)
			self.loady.backgroundColor = background
			let circle = setupImagesInFourPhases(image,shrinkContainerLayer: true)
			createCircularLoading(bounds: circle.bounds, center : circle.position)
			break
		case .success(let name, let image, let background):
			self.loady.setTitle(name , for: .normal)
			self.loady.backgroundColor = background
			setupImagesInFourPhases(image)
			cleanCircularLoading()
			break
		case .error(let name, let image, let background):
			self.loady.setTitle(name , for: .normal)
			self.loady.backgroundColor = background
			setupImagesInFourPhases(image)
			cleanCircularLoading()
			break
		}
		UIView.commitAnimations()
		
	}
	open func normalPhase(){
		self.currentPhase = .normal(phases.normalPhase)
		createFourPhaseButton()
		cleanCircularLoading()
	}
	open func successPhase(){
		self.currentPhase = .success(phases.successPhase)
		createFourPhaseButton()
	}
	open func errorPhase(){
		self.currentPhase = .error(phases.errorPhase)
		createFourPhaseButton()
	}
	
	open func loadingPhase(){
		self.currentPhase = .loading(phases.loadingPhase)
		createFourPhaseButton()
	}
	@discardableResult private func setupImagesInFourPhases(_ image : UIImage? , shrinkContainerLayer : Bool = false)->CAShapeLayer{
		if let imageLayer = self.loady.layer.sublayers?.first(where: { $0.accessibilityHint == LayerTempKeys.tempLayer.rawValue}) {
			let animation = CATransition()
			animation.isRemovedOnCompletion = true
			animation.duration = 0.2
			animation.type = CATransitionType.push
			animation.subtype = CATransitionSubtype.fromTop
			animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			imageLayer.sublayers?[0].add(animation, forKey:"changeImageTransition")
			imageLayer.sublayers?[0].contents = image?.cgImage
			imageLayer.sublayers?[0].contentsScale = UIScreen.main.scale
			if shrinkContainerLayer {
				imageLayer.transform =  CATransform3DMakeScale(0.7, 0.7, 1);
			}else{
				imageLayer.transform =  CATransform3DMakeScale(1, 1, 1);
			}
			return imageLayer as! CAShapeLayer
		}else{
			let radius = self.loady.bounds.height / 3
			let circleContainer = LoadyCore.createCircleInside(bounds: self.loady.bounds, strokeColor: self.loady.loadingColor, radius: radius)
			circleContainer.fillColor = UIColor.white.cgColor
			circleContainer.position.x = (radius * 2) - 4
			let imageLayer = CAShapeLayer()
			imageLayer.bounds = CGRect(x:0,y: 0,width: radius,height: radius);
			imageLayer.position = CGPoint(x:circleContainer.bounds.midY,y: circleContainer.bounds.midY);
			imageLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
			imageLayer.contents = image?.cgImage
			imageLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
			circleContainer.addSublayer(imageLayer)
			circleContainer.accessibilityHint = LayerTempKeys.tempLayer.rawValue
			
			self.loady.addSublayer(circleContainer)
			
			return circleContainer
		}
	}
	
	private func cleanCircularLoading(){
		guard let loading = self.loady.layer.sublayers?.first(where: { $0.accessibilityHint == LayerTempKeys.circularLoading.rawValue}) else { return }
			let animation = LoadyCore.createBasicAnimation(keypath: "opacity", from: 1.0, to: 0.0,duration: 0.5)
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			loading.add(animation, forKey: "fade")
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				loading.removeFromSuperlayer()
			}
	}
	
	private func createCircularLoading(bounds : CGRect, center : CGPoint){
		cleanCircularLoading()
		let circularLoadingLayer = CAShapeLayer()
		circularLoadingLayer.fillColor = UIColor.clear.cgColor
		circularLoadingLayer.strokeColor = UIColor.black.cgColor
		circularLoadingLayer.lineWidth = 3
		circularLoadingLayer.bounds = bounds.insetBy(dx: 9, dy: 9)
		circularLoadingLayer.path = UIBezierPath(ovalIn: circularLoadingLayer.bounds).cgPath
		circularLoadingLayer.position = center
		circularLoadingLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
		circularLoadingLayer.accessibilityHint = LayerTempKeys.circularLoading.rawValue
		self.loady.addSublayer(circularLoadingLayer)
		startCircluarLoadingAnimation(circularLoadingLayer)
	}
	
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


extension LoadyFourPhaseAnimation: LoadyAnimation {
	public func isLoading() -> Bool {
		return loading
	}
	
	public func inject(loady: Loadiable) {
		guard let loady = loady as? Loadiable & UIButton else {
			assertionFailure("this animation will apply only on UIbutton")
			return
		}
		self.loady = loady
	}
	public func run() {
		loading = true
		createFourPhaseButton()
	}
	
	public func stop() {
		loading = false
		cleanCircularLoading()
	}
	
}
