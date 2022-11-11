//
//  BaseLoadingableAnimator.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/11/2022.
//

import Foundation
open class BaseLoadingableAnimator: LoadingableAnimator {
    open private(set) unowned var canvas: LoadingableAnimationCanvas?
    open var id: UUID = .init()
    
    /// indicates if the button is in loading state
    open var isLoading: Bool = false
 
    /// changes the state of the button to loading state
    open func start() {
        self.isLoading = true
        makeAnimation()
    }
    
    /// changes the state of the button to normal state
    open func stop() {
        self.isLoading = false
        self.canvas?.removeAllAnimationLayers()
    }
    
    open func set(canvas: LoadingableAnimationCanvas) {
        self.canvas = canvas
    }
    
    open func makeAnimation(){
       fatalError("NEEDS TO BE IMPLEMENTED.")
    }
}
