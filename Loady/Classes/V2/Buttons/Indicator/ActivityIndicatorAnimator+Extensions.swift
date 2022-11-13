//
//  IndicatorAnimator+Extensions.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
import class UIKit.UIColor
public extension ActivityIndicatorAnimator {
    struct Configuration: Equatable {
        public enum Postion {
            case leading, trailing
        }
        
        public enum ButtonLabelPosition {
            case hidden, move
        }
        // if nil, the size of the indicator will be calculated automatically
        public let size: CGSize
        public let buttonLabelPosition: ButtonLabelPosition
        public let indicatorPosition: Postion
        public init(
            indicatorPosition: Postion = .trailing,
            size: CGSize = .init(width: 20, height: 20),
            buttonLabelPosition: ButtonLabelPosition = .move
        ) {
            self.indicatorPosition = indicatorPosition
            self.size = size
            self.buttonLabelPosition = buttonLabelPosition
        }
    }
}

public extension ActivityIndicatorAnimator.Configuration {
    static var `default`: Self {
        return .init()
    }
}
