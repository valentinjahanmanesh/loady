//
//  AnimationHandler.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation
public protocol AnimationHandler {
    var isLoading: Bool {get}
    var canvas: LoadingableAnimationCanvas? {get}
    func start()
    func stop()
    func set(canvas: LoadingableAnimationCanvas)
}

