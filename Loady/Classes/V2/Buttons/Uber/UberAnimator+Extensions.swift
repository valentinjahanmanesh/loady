//
//  UberAnimator+Extensions.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation
import class UIKit.UIColor
public extension UberAnimator {
    struct Configuration: Equatable {
        public enum Direction {
            case rtl, ltr
        }
        public let indicatorColor: UIColor
        
        /// it would be a number in rage of `0 <= 1` and it indicates how big would be the indicator in compare to the canvas, 1 means indicator would have the same length as the canvas width
        public let indicatorLength: Float16
        public let indicatorTickness: Float
        public let indicatorDirection: Direction
        public init(
            indicatorLength: Float16 = 0.55,
            indicatorTickness: Float = 2,
            indicatorDirection: Direction = .ltr,
            indicatorColor: UIColor = .black
        ) {
            self.indicatorLength = min(indicatorLength, 1)
            self.indicatorTickness = indicatorTickness
            self.indicatorDirection = indicatorDirection
            self.indicatorColor = indicatorColor
        }
    }
}

public extension UberAnimator.Configuration {
    static var `default`: Self {
        return .init()
    }
}
