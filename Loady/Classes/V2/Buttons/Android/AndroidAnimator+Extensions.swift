//
//  AndroidAnimator+Extensions.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/11/2022.
//

import Foundation
import class UIKit.UIColor
public extension AndroidAnimator {
    struct Configuration: Equatable {
        public let fillColor: UIColor
        public let indicatorColor: UIColor
        
        public init(
            indicatorColor: UIColor = .black,
            fillColor: UIColor = .black
        ) {
            self.indicatorColor = indicatorColor
            self.fillColor = fillColor
        }
    }
}

public extension AndroidAnimator.Configuration {
    static var `default`: Self {
        return .init()
    }
}
