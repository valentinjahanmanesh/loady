//
//  LoadyTopLineAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//
import UIKit

public extension LoadyAnimationType {
	static func topLine()->LoadyTopLineAnimation{
		return LoadyTopLineAnimation()
	}
}

public class LoadyTopLineAnimation {
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "indicator")
	lazy var activiyIndicator : LoadyActivityIndicator = { UIActivityIndicatorView() }()
	private unowned var loady: Loadiable!
	var loadingLayer: CAShapeLayer?
	private var loading: Bool = false

	///line loading
	private func createTopLineLoading(){
		//create our loading layer and line path
		let loadingLayer = CAShapeLayer();
		let path = UIBezierPath();
		
		//height of the line
		let lineHeight : CGFloat = 2.0;
		
		//center the layer in our view and set the bounds
		loadingLayer.position = CGPoint(x:self.loady.frame.size.width / 2,y: -1);
		loadingLayer.bounds = CGRect(x:0,y: 0, width: self.loady.frame.size.width, height: lineHeight);
		
		//draw our line
		path.move(to: CGPoint(x:0,y: -1))
		path.addLine(to: CGPoint(x:loadingLayer.bounds.size.width/2.4,y: -1))
		
		//set the path layer, and costumizing it
		loadingLayer.path = path.cgPath;
		loadingLayer.strokeColor = self.loady.loadingColor.cgColor;
		loadingLayer.strokeEnd = 1;
		loadingLayer.lineWidth = lineHeight;
		loadingLayer.lineCap = CAShapeLayerLineCap(rawValue: "round");
		loadingLayer.contentsScale = UIScreen.main.scale;
		loadingLayer.accessibilityHint = "button_topline_loading";
		loadingLayer.opacity = 0
		//add the new layer
		self.loady.addSublayer(loadingLayer);
		
		//animated path
		let animatedPath = UIBezierPath()
		animatedPath.move(to: CGPoint(x:loadingLayer.bounds.size.width / 1.2,y: -1))
		animatedPath.addLine(to: CGPoint(x:loadingLayer.bounds.size.width,y: -1))
		let animateOpacity = LoadyCore.createBasicAnimation(keypath: "opacity", from: 0, to: 1,duration : 0.6)
		animateOpacity.isRemovedOnCompletion = false
		animateOpacity.fillMode  = .forwards
		
		//create our animation and add it to the layer, animate indictor from left to right
		let animation = LoadyCore.createBasicAnimation(keypath: "path", from: path.cgPath, to: animatedPath.cgPath)
		animation.autoreverses = true;
		animation.repeatCount = 100;
		animation.isRemovedOnCompletion = false
		loadingLayer.add(animation,forKey:nil);
		loadingLayer.add(animateOpacity,forKey:nil);
		self.loadingLayer = loadingLayer
	}
}

extension LoadyTopLineAnimation: LoadyAnimation {
	public func inject(loady: Loadiable) {
		self.loady = loady
	}
	
	public func isLoading() -> Bool {
		return loading
	}
	
	public func run() {
		loading = true
		createTopLineLoading()
	}
	
	public func stop() {
		loading = false
		self.loadingLayer?.removeFromSuperlayer()
	}
}
