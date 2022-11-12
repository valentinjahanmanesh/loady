//
//  LoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit
open class LoadingableButton: UIButton {
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
}

public struct LoadingableError: LocalizedError, Equatable {
    /// A localized message describing what error occurred.
    public let errorDescription: String?

    /// A localized message describing the reason for the failure.
    public let failureReason: String?

    /// A localized message describing how one might recover from the failure.
    public let recoverySuggestion: String?
}

public enum LoadingableButtonError: Error{
    case typeOfAnimationIsNotProgressive(error: LoadingableError)
    case missingObjects(error: LoadingableError)
}

public extension LoadingableError {
    static let animatorTypeMismatched = LoadingableError(errorDescription: "You are doing it wrong, the type of the animation that you have chosen is not progressive", failureReason: "The type of the animator is mismatched.", recoverySuggestion: "Replace the animator with a progressive one or remove the calling please")
    
    static let noCanvas = LoadingableError(errorDescription: "It seems that the canvas is not alive or you don't set the canvas yet, because for the rest of the function, Existance of the canvas is a most", failureReason: "No canvas is found.", recoverySuggestion: "Make sure you have set the canvas or you've had strong reference to it so it can be alive and living in memory.")
}

extension LoadingableButton {
    public func update(progress: AnimationProgressValue) throws {
        guard let animator = animatorDelegate as? ProgressableAnimation else {
            throw LoadingableButtonError.typeOfAnimationIsNotProgressive(error: .animatorTypeMismatched)
        }
        
        animator.set(progress: progress)
    }
}
