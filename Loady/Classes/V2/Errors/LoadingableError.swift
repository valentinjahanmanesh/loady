//
//  LoadingableError.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
public struct LoadingableError: LocalizedError, Equatable {
    /// A localized message describing what error occurred.
    public let errorDescription: String?

    /// A localized message describing the reason for the failure.
    public let failureReason: String?

    /// A localized message describing how one might recover from the failure.
    public let recoverySuggestion: String?
}



public extension LoadingableError {
    static let animatorTypeMismatched = LoadingableError(errorDescription: "You are doing it wrong, the type of the animation that you have chosen is not progressive", failureReason: "The type of the animator is mismatched.", recoverySuggestion: "Replace the animator with a progressive one or remove the calling please")
    
    static let noCanvas = LoadingableError(errorDescription: "It seems that the canvas is not alive or you don't set the canvas yet, because for the rest of the function, Existance of the canvas is a most", failureReason: "No canvas is found.", recoverySuggestion: "Make sure you have set the canvas or you've had strong reference to it so it can be alive and living in memory.")
}
