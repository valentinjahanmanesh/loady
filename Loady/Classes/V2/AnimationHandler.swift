//
//  AnimationHandler.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation

/// Acts as a manager and connector, if you want to create a new animation, you need to adopt the protocol, this protocol consists of all the functionalitly for the start and stop the animation.
public protocol AnimationHandler {
    var isLoading: Bool {get}
    var canvas: LoadingableAnimationCanvas? {get}
    func start()
    func stop()
    func set(canvas: LoadingableAnimationCanvas)
}

