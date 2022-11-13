//
//  BackgroundFillingAnimator.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/11/2022.
//

import UIKit
open class BackgroundFillingAnimator: BaseLoadingableAnimator, ProgressableAnimation {
    private unowned var animationLayer: CAShapeLayer?
    private(set) public var progress: Float16 = 0
    public func set(progress: AnimationProgressValue) {
        self.progress = progress.rawValue
        try! updateProgress(progress.rawValue)
    }
    
    public let options: Configuration
    public init(options: Configuration = .default) {
        self.options = options
    }
    
    open override func makeAnimation(){
        guard let canvas else {
            fatalError("Canvas for drawing is needed, you need to set the canvas by using the set(canvas) function.")
        }
        
        let fillingLayer = createFillingLayer(with: canvas.frame.size, color: options.fillColor)
        canvas.addLayer(forLoading: fillingLayer);
        
        animationLayer = fillingLayer
        if progress > 0 {
            try! updateProgress(progress)
        }
    }
    
    private func calculateStep(canvasWidth: CGFloat, currentSize: CGFloat, progress: Float16) -> (current: CGFloat, new: CGFloat) {
        let currentProgres = (currentSize * 100) / canvasWidth
        let newProgress = CGFloat(Float16(canvasWidth) * progress)
        return (currentProgres, newProgress)
    }
    
    private func updateProgress(_ progress: Float16) throws  {
        guard self.isLoading, let canvas, let animationLayer else {
            throw LoadingableButtonError.missingObjects(error: .noCanvas)
        }
        
        let calculateProgress = calculateStep(canvasWidth: canvas.frame.width, currentSize: animationLayer.bounds.width, progress: progress)
        createAnimation(from: calculateProgress.current, to: calculateProgress.new)
    }
}

extension BackgroundFillingAnimator {
    fileprivate func createFillingLayer(with size: CGSize, color: UIColor) -> CAShapeLayer {
        let fillingLayer = CAShapeLayer();
        fillingLayer.backgroundColor = color.cgColor
        fillingLayer.bounds = CGRect(x:0, y:0, width: 0, height: size.height);
        fillingLayer.anchorPoint = CGPoint(x:0, y:0.5);
        fillingLayer.position = CGPoint(x:0, y: size.height / 2);
        fillingLayer.masksToBounds = true
        return fillingLayer
    }
    
    fileprivate func createAnimation(from: CGFloat, to: CGFloat) {
        animationLayer?.bounds.size.width = to
    }
}
