//
//  LoadingableButton+Extensions.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
private var animationLayerUnsafePointer: UInt8 = 0
extension LoadingableButton: LoadingableAnimationCanvas {
    private var animationLayer: CALayer? {
        get {
            return objc_getAssociatedObject(self, &animationLayerUnsafePointer) as? CALayer
        }
        
        set {
            objc_setAssociatedObject(self, &animationLayerUnsafePointer, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func removeAllAnimationLayers() {
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }
    
    public func addLayer(forLoading layer: CAShapeLayer) {
        if animationLayer == nil{
            animationLayer = CALayer()
            self.layer.addSublayer(animationLayer!)
        }
        
        animationLayer?.addSublayer(layer)
    }
    
    public func animationWillStart() {
        
    }
    
    public func animationWillStop() {
        
    }
    
    public func animationDidStop() {
        
    }
    
    public func animationDidStart() {
        
    }
}
