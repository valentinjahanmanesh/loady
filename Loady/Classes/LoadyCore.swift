//
//  LoadyCore.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
final class LoadyCore {
	/// creates a circle inside or button, some animations like appstore, circleAndTick and ... needs to show a circle
	///
	/// - Parameters:
	///   - radius: radius of the circle
	///   - centerX: x position, (nil) default is the center of the button
	///   - centerY: y position, (nil) default is the ceenter of the button
	/// - Returns: a circle
	class func createCircleInside(bounds: CGRect, strokeColor: UIColor, radius : CGFloat? = nil, centerX : CGFloat? = nil, centerY : CGFloat? = nil, anchorPoint: CGPoint = CGPoint(x:0.5,y: 0.5))-> CAShapeLayer{
		let circle = CAShapeLayer()
		let path = UIBezierPath()
		let squre = min(bounds.height,bounds.width)
		let radius = radius ?? squre / 2
		circle.bounds = CGRect(x:0,y: 0,width: squre,height: squre)
		circle.strokeColor = strokeColor.cgColor
		circle.lineWidth = 3
		circle.fillColor = UIColor.clear.cgColor
		circle.lineCap = .round
		circle.strokeStart = 0.0
		circle.strokeEnd = 0.0
		let center = CGPoint(x: circle.bounds.midX,y: circle.bounds.midY)
		circle.position = CGPoint(x: centerX ?? bounds.midX,y: centerY ?? bounds.midY)
		circle.anchorPoint = anchorPoint
		path.addArc(withCenter: center, radius: radius , startAngle: LoadyCore.degreesToRadian(-90), endAngle: LoadyCore.degreesToRadian(270), clockwise: true)
		
		circle.path = path.cgPath
		return circle
	}
	struct Pose {
		let secondsSincePriorPose: CFTimeInterval
		let start: CGFloat
		let length: CGFloat
		init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
			self.secondsSincePriorPose = secondsSincePriorPose
			self.start = start
			self.length = length
		}
	}
	class var poses: [Pose] {
		get {
			return [
				Pose(0.0, 0.000, 0.7),
				Pose(0.6, 0.500, 0.5),
				Pose(0.6, 1.000, 0.3),
				Pose(0.6, 1.500, 0.1),
				Pose(0.2, 1.875, 0.1),
				Pose(0.2, 2.250, 0.3),
				Pose(0.2, 2.625, 0.5),
				Pose(0.2, 3.000, 0.7),
			]
		}
	}
	class func animateKeyPath(_ layer  : CAShapeLayer,keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
		let animation = CAKeyframeAnimation(keyPath: keyPath)
		animation.keyTimes = times as [NSNumber]?
		animation.values = values
		animation.calculationMode = .linear
		animation.duration = duration
		animation.repeatCount = Float.infinity
		animation.isRemovedOnCompletion = false
		layer.add(animation, forKey: animation.keyPath)
	}
	
	/// creates a copy of specific properties of the layer and makes a new layer with those
	///
	/// - Parameter copy: layer to create a copy of
	/// - Returns: new layer
	class func copy(layer copy : CAShapeLayer)-> CAShapeLayer{
		let newLayer = CAShapeLayer()
		newLayer.bounds = copy.bounds
		newLayer.strokeColor = copy.strokeColor
		newLayer.lineWidth = copy.lineWidth
		newLayer.fillColor = copy.fillColor
		newLayer.lineCap = copy.lineCap
		newLayer.strokeStart = copy.strokeStart
		newLayer.strokeEnd = copy.strokeEnd
		newLayer.position = copy.position
		newLayer.anchorPoint = copy.anchorPoint
		newLayer.path = copy.path
		newLayer.accessibilityHint = copy.accessibilityHint
		
		return newLayer
	}
	
	class func createBasicAnimation(keypath : String, from : Any,to:Any,duration : Double = 1) -> CABasicAnimation{
		let animation = CABasicAnimation()
		animation.keyPath = keypath
		animation.fromValue = from
		animation.toValue = to
		animation.duration = duration;
		
		return animation
	}
	
	class func createTextLayers(layer:CAShapeLayer,string : String,font : UIFont)->CATextLayer{
		let text = CATextLayer()
		text.string = string
		text.bounds = layer.bounds
		text.position = CGPoint(x:text.bounds.midX,y:text.bounds.midY)
		text.alignmentMode = .center
		text.font = font
		text.fontSize = font.pointSize
		text.foregroundColor = UIColor.black.cgColor
		text.contentsScale = UIScreen.main.scale
		return text
	}
	
	class func createTextPushAnimation(type : CATransitionSubtype,duration : Double)->CAAnimation{
		let animation = CATransition()
		animation.isRemovedOnCompletion = true
		animation.duration = duration
		animation.type = CATransitionType.push
		animation.subtype = type
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		return animation
	}
	
	
	class func degreesToRadian(_ value: CGFloat)-> CGFloat { return value * .pi / 180 }
	class func radiansToDegrees(_ value: CGFloat)-> CGFloat { return value * 180 / .pi }
	
	class func calculateTextHeight(string : String,withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	class  func calculateTextWidth(string : String,withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
	
	
	/// Resizes Images to idle size
	///
	/// - Parameters:
	///   - image: the UIImage to resize
	///   - targetSize: target size
	/// - Returns: the image with new size
	class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
		let size = image.size
		
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
