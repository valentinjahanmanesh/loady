//
//  AndroidLoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/11/2022.
//

import Foundation
import UIKit
open class AndroidLoadingableButton: LoadingableButton {
    private var oldBackgroundColor: UIColor?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        super.set(delegate: AndroidAnimator())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.set(delegate: AndroidAnimator())
    }
    
    public func set(options: AndroidAnimator.Configuration) -> Self {
        super.set(delegate: AndroidAnimator(options: options))
        return self
    }
    
    public override func addLayer(forLoading layer: CALayer) {
        super.addLayer(forLoading: layer)
        animationLayer?.zPosition = 10
    }
    
    public override func animationDidStart() {
        super.animationDidStart()
        self.oldBackgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
    public override func animationDidStop() {
        super.animationDidStop()
        self.backgroundColor = self.oldBackgroundColor
    }
}

