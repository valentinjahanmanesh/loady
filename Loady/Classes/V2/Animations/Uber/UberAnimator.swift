//
//  UberAnimator.swift
//  
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import UIKit

open class UberAnimator: BaseLoadingableAnimator {
    public let options: Options
    public init(options: Options = .default) {
        self.options = options
    }
    /// it would be a number in rage of `0 <= 1` and it indicates how big would be the indicator in compare to the canvas, 1 means indicator would have the same length as the canvas width
    private var indicatorSize: Float16 {
        self.options.indicatorLength
    }
    
    open override func makeAnimation(){
        guard let canvas else {
            fatalError("Canvas for drawing is needed, you need to set the canvas by using the set(canvas) function.")
        }
        //create our loading layer and line path
        let topLine = createIndicatorLayer(with: canvas.frame.size);
        let originalPath: UIBezierPath
        let destinationPath: UIBezierPath
        
        if options.indicatorDirection == .ltr {
             originalPath = drawLine(on: topLine)
             destinationPath = createDestinationPath(canvasSize: topLine.bounds.size)
        } else {
            destinationPath = drawLine(on: topLine)
            originalPath = createDestinationPath(canvasSize: topLine.bounds.size)
        }
        
        topLine.path = originalPath.cgPath
        canvas.addLayer(forLoading: topLine);
        //animated path
        let opacityAnimation = createOpacityAnimation()
        let pathAnimation = createPathAnimation(from: originalPath, to: destinationPath)
        
        topLine.add(pathAnimation, forKey:nil);
        topLine.add(opacityAnimation, forKey:nil);
    }
}

extension UberAnimator {
    fileprivate func createPathAnimation(from origin: UIBezierPath, to destination: UIBezierPath) -> CABasicAnimation {
        let animation = LoadyCore.createBasicAnimation(keypath: "path", from: origin.cgPath, to: destination.cgPath)
        animation.autoreverses = true;
        animation.repeatCount = 100;
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    fileprivate func createDestinationPath(canvasSize: CGSize) -> UIBezierPath {
        let animatedPath = UIBezierPath()
        animatedPath.move(to: CGPoint(x: canvasSize.width - self.calculateIndicatorSize(canvasWidth: canvasSize.width),y: -1))
        animatedPath.addLine(to: CGPoint(x: canvasSize.width,y: -1))
        return animatedPath
    }
    
    fileprivate func createOpacityAnimation() -> CABasicAnimation {
        let animateOpacity = LoadyCore.createBasicAnimation(keypath: "opacity", from: 0, to: 1,duration : 0.6)
        animateOpacity.isRemovedOnCompletion = false
        animateOpacity.fillMode  = .forwards
        return animateOpacity
    }
    
    fileprivate func createIndicatorLayer(with size: CGSize) -> CAShapeLayer {
        let lineHeight : CGFloat = CGFloat(self.options.indicatorTickness);
        let line = CAShapeLayer();
        line.strokeEnd = 1;
        line.lineCap = CAShapeLayerLineCap.round;
        line.contentsScale = UIScreen.main.scale;
        line.accessibilityHint = "button_topline_loading";
        line.opacity = 1
        line.position = CGPoint(x: size.width / 2, y: -1);
        line.bounds = CGRect(x:0,y: 0, width: size.width, height: lineHeight);
        line.lineWidth = lineHeight
        line.strokeColor = self.options.indicatorColor.cgColor
        return line
    }
    
    fileprivate func drawLine(on layer: CAShapeLayer) -> UIBezierPath {
        let path = UIBezierPath();
        path.move(to: CGPoint(x:0,y: -1))
        path.addLine(to: CGPoint(x: self.calculateIndicatorSize(canvasWidth: layer.bounds.size.width) , y: -1))
        
        return path
    }
    
    fileprivate func calculateIndicatorSize(canvasWidth: CGFloat) -> CGFloat {
        return  CGFloat(indicatorSize) * canvasWidth
    }
}
