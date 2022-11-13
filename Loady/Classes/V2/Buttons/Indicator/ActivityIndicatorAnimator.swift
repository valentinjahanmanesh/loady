//
//  ActivityIndicatorAnimator.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
import UIKit
open class ActivityIndicatorAnimator: BaseLoadingableAnimator {
    public let options: Configuration
    public init(options: Configuration = .default) {
        self.options = options
    }
    
    private let activityIndicator = UIActivityIndicatorView()
    open override func makeAnimation(){
        guard let canvas else {
            fatalError("Canvas for drawing is needed, you need to set the canvas by using the set(canvas) function.")
        }
        
        activityIndicator.center.y = canvas.bounds.height / 2
        activityIndicator.center.x = canvas.bounds.width / 2
        canvas.addSubview(forLoading: activityIndicator)
        activityIndicator.startAnimating()
    }
}
