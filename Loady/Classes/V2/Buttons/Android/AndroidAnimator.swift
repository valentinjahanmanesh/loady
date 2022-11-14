//
//  AndroidAnimator.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/11/2022.
//

import Foundation
import UIKit
open class AndroidAnimator: BaseLoadingableAnimator, ProgressableAnimation {
    private unowned var animationLayer: CALayer?
    private unowned var strikeLayer: CALayer?
    private(set) public var progress: Float16 = 0
    public func set(progress: AnimationProgressValue) {
        self.progress = progress.rawValue
    }
    
    public let options: Configuration
    public init(options: Configuration = .default) {
        self.options = options
    }
    
    open override func makeAnimation(){
        guard let canvas else {
            fatalError("Canvas for drawing is needed, you need to set the canvas by using the set(canvas) function.")
        }
        
        let strokeFillerLayer = LoadyCore.createCircleInside(bounds: canvas.bounds.insetBy(dx: 2, dy: 2), strokeColor: self.options.fillColor)
        strokeFillerLayer.opacity = 0
        canvas.addLayer(forLoading: strokeFillerLayer)
        self.strikeLayer = strokeFillerLayer
        let poses = LoadyCore.poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        let animations = createCircluarLoadingAnimation(poses: poses, duration: totalSeconds) + [createAnimateStrokeHue(options: options, duration: totalSeconds)]
        
        let canvasSimulator = CALayer()
        canvasSimulator.frame = canvas.frame
        canvasSimulator.frame.origin = .init(x: 0, y: 0)
        canvasSimulator.backgroundColor = options.fillColor.cgColor
        canvas.addLayer(forLoading: canvasSimulator)
        animationLayer = canvasSimulator
        
        let strikeOpacity = BasicAnimationBuilder.build(for: "opacity", newValue: 1)
            .addAnimation(to: strokeFillerLayer)
        
        roundCanvas(canvasSimulator, options: options)
            .then({
                animations.forEach { (aniamtion, path) in
                    strokeFillerLayer.add(aniamtion, forKey: path)
                }
                strikeOpacity.animate()
            })
            .animate()
    }
    
    open override func stop() {
        BasicAnimationBuilder
            .build(for: "opacity", newValue: 0)
            .addAnimation(to: self.strikeLayer!)
            .then {
                self.retvertAllAnimation(self.animationLayer!, to: self.canvas!.bounds)
                    .then {
                        super.stop()
                    }
                    .animate()
            }
            .animate()
    }
    
    private let animationDuration = 0.4
    private func roundCanvas(_ canvas: CALayer, options: Configuration) -> BasicAnimationBuilder {
        let radius = min(canvas.bounds.width - 12, canvas.bounds.height - 12)
        let center = CGPoint(x: self.canvas!.bounds.origin.x / 2, y: self.canvas!.bounds.origin.y / 2)
        let bounds = CGRect(x:  center.x, y: center.y + 6, width: radius, height: radius)
        
        return BasicAnimationBuilder
            .build(for: "cornerRadius", newValue: radius / 2)
            .append(for: "bounds", newValue: bounds)
            .addAnimation(to: canvas)
    }
    
    private func retvertAllAnimation(_ canvas: CALayer, to bounds: CGRect) -> BasicAnimationBuilder {
        return BasicAnimationBuilder
            .build(for: "cornerRadius", newValue: 0)
            .append(for: "bounds", newValue: bounds)
            .addAnimation(to: canvas)
    }
}

extension AndroidAnimator {
    private typealias KeyPathAnimation = (animation: CAKeyframeAnimation, keyPath: String)
    private func createCircluarLoadingAnimation(poses: [LoadyCore.Pose], duration: TimeInterval) -> [KeyPathAnimation] {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        let totalSeconds = duration
        
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
        
        let rotationKeyPath = "transform.rotation"
        let strokeEndKeyPath = "strokeEnd"
        
        return [(LoadyCore.animateKeyPath(keyPath: strokeEndKeyPath,
                                          duration: totalSeconds,
                                          times: times,
                                          values: strokeEnds), strokeEndKeyPath),
                
                (LoadyCore.animateKeyPath(keyPath: rotationKeyPath,
                                          duration: totalSeconds,
                                          times: times,
                                          values: rotations), rotationKeyPath)]
    }
    
    private func createAnimateStrokeHue(options: AndroidAnimator.Configuration, duration: CFTimeInterval) -> KeyPathAnimation {
        let count = 200
        let strokeColorKeyPath = "strokeColor"
        let animation = CAKeyframeAnimation(keyPath: strokeColorKeyPath)
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        let loadingColor = options.fillColor
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
        return (animation, strokeColorKeyPath)
    }
}

struct BasicAnimationBuilder {
    private let animations: [CABasicAnimation]
    private unowned var ownerLayer: CALayer?
    private var thenCallBack: (()->Void)?
    
    private init(animation: [CABasicAnimation] = [], ownerLayer: CALayer? = nil, thenCB: (() -> Void)? = nil) {
        self.animations = animation
        self.ownerLayer = ownerLayer
        self.thenCallBack = thenCB
    }
    
    static func build(for keyPath: String, newValue: Any, duration: TimeInterval = 0.3) -> BasicAnimationBuilder {
        return Self().append(for: keyPath, newValue: newValue, duration: duration)
    }
    
    func append(for keyPath: String, newValue: Any, duration: TimeInterval = 0.3) -> BasicAnimationBuilder {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = newValue
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return Self.init(animation: self.animations + [animation], ownerLayer: self.ownerLayer, thenCB: self.thenCallBack)
    }
    
    func append(animation: CABasicAnimation) -> Self {
        return Self.init(animation: self.animations + [animation], ownerLayer: self.ownerLayer, thenCB: self.thenCallBack)
    }
    
    func append(animations: [CABasicAnimation]) -> Self {
        return Self.init(animation: self.animations + animations, ownerLayer: self.ownerLayer, thenCB: self.thenCallBack)
    }
    
    func addAnimation(to: CALayer) -> Self {
        return Self.init(animation: self.animations, ownerLayer: to, thenCB: self.thenCallBack)
    }
    
    func then(_ cb: @escaping ()->Void) -> Self {
        let animationDuration = self.animations.max(by: {$0.duration > $1.duration})?.duration ?? 0
        let thenCB = {
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                cb()
            }
        }
        return Self.init(animation: self.animations, ownerLayer: self.ownerLayer, thenCB: thenCB)
    }
    
    func animate() {
        animations.forEach({animation in
            self.ownerLayer?.add(animation, forKey: nil)
        })
        self.thenCallBack?()
    }
}
