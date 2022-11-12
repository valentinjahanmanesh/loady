//
//  AnimationProgressValue.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
public struct AnimationProgressValue: RawRepresentable {
    public typealias RawValue = Float16
    private (set) public var rawValue: Float16 = 0
    public init(rawValue: Float16) {
        self.rawValue = min(abs(rawValue), 1)
    }
}
