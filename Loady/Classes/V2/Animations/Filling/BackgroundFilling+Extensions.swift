//
//  File.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/11/2022.
//

import Foundation
import class UIKit.UIColor
public extension BackgroundFillingAnimator {
    struct Options: Equatable {
        public enum Direction {
            case rtl, ltr
        }
        public let fillColor: UIColor
        public let indicatorDirection: Direction
        public init(
            indicatorDirection: Direction = .ltr,
            fillColor: UIColor = .black
        ) {
            self.indicatorDirection = indicatorDirection
            self.fillColor = fillColor
        }
    }
}

public extension BackgroundFillingAnimator.Options {
    static var `default`: Self {
        return .init()
    }
}
