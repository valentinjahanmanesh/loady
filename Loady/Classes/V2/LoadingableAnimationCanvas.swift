//
//  LoadingableAnimationCanvas.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
public protocol LoadingableAnimationCanvas: UIView {
    func animationWillStart()
    func animationWillStop()
    func animationDidStop()
    func animationDidStart()
    func addLayer(forLoading: CAShapeLayer)
    func removeAllAnimationLayers()
}
