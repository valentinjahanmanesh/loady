//
//  LoadingableAnimationCanvas.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
/// All the views that want to be able to show the loadys animations need to conform to this protocol, the main functionality is add layer which the view recevies all the anaimaiton layers through this function and needs to add those animations into a layer and manages it.
public protocol LoadingableAnimationCanvas: UIView {
    func animationWillStart()
    func animationWillStop()
    func animationDidStop()
    func animationDidStart()
    func addLayer(forLoading: CALayer)
    func addSubview(forLoading: UIView)
    func removeAllAnimationLayers()
}
