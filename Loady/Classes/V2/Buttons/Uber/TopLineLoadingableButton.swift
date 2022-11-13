//
//  File.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
import UIKit

open class TopLineLoadingableButton: LoadingableButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        super.set(delegate: UberAnimator())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.set(delegate: UberAnimator())
    }
    
    public func set(options: UberAnimator.Configuration) {
        super.set(delegate: UberAnimator(options: options))
    }
}
