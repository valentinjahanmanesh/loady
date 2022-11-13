//
//  LoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
open class LoadingableButton: UIButton, LoadingableAnimationCanvas  {
    public typealias DoAction = (LoadingableButton)->Void
    private var animationLayer: CALayer? 
    public private (set) var animatorDelegate: any LoadingableAnimator = UberAnimator()
    /// indicates if the button is in loading state
    public var isLoading: Bool {
        return animatorDelegate.isLoading
    }
    
    /// changes the state of the button to loading state
    public func startLoading() {
        self.animatorDelegate.start()
    }
    
    /// changes the state of the button to normal state
    public func stopLoading() {
        self.animatorDelegate.stop()
    }
    
    public func set(delegate: any LoadingableAnimator) {
        self.animatorDelegate = delegate
        delegate.set(canvas: self)
    }
    
    var beforeLoading:  DoAction? = nil
    var loadingStarted: DoAction? = nil
    var beforeFinishing:  DoAction? = nil
    var loadingFinished: DoAction? = nil
    
    
    public func addSubview(forLoading view: UIView) {
        fatalError("Needs to be implemented where ever needed.")
    }
    
    public func removeAllAnimationLayers() {
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }
    
    public func addLayer(forLoading layer: CALayer) {
        if animationLayer == nil{
            animationLayer = CALayer()
            self.layer.insertSublayer(animationLayer!, at: 0)
        }
        
        animationLayer?.addSublayer(layer)
    }
    
    public func animationWillStart() {
        self.beforeLoading?(self)
    }
    
    public func animationWillStop() {
        self.beforeFinishing?(self)
    }
    
    public func animationDidStop() {
        self.loadingFinished?(self)
    }
    
    public func animationDidStart() {
        self.loadingStarted?(self)
    }
}

public extension LoadingableButton {
    func `do`(beforeLoading: DoAction? = nil,
              loadingStarted:  DoAction? = nil,
              beforeFinishing:  DoAction? = nil,
              loadingFinished:  DoAction? = nil
    ) -> Self {
        self.beforeLoading = beforeLoading
        self.loadingStarted = loadingStarted
        self.beforeFinishing = beforeFinishing
        self.loadingFinished = loadingFinished
        
        return self
    }
}


extension LoadingableButton {
    public func update(progress: AnimationProgressValue) throws {
        guard let animator = animatorDelegate as? ProgressableAnimation else {
            throw LoadingableButtonError.typeOfAnimationIsNotProgressive(error: .animatorTypeMismatched)
        }
        
        animator.set(progress: progress)
    }
}
