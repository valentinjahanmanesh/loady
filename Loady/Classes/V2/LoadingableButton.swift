//
//  LoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
open class LoadingableButton: UIButton {
    public private (set) var animatorDelegate: any LoadingableButtonAnimator = UberAnimator()
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
    
    public func set(delegate: any LoadingableButtonAnimator) {
        self.animatorDelegate = delegate
        delegate.set(canvas: self)
    }
}
