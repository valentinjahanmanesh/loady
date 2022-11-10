//
//  LoadingableButtonAnimator+Extensions.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import Foundation
public extension LoadingableButtonAnimator {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
