//
//  BackgroundFillingLoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
import UIKit
open class BackgroundFillingLoadingableButton: LoadingableButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        super.set(delegate: BackgroundFillingAnimator())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.set(delegate: BackgroundFillingAnimator())
    }
    
    public func set(options: BackgroundFillingAnimator.Configuration) {
        super.set(delegate: BackgroundFillingAnimator(options: options))
    }
}

