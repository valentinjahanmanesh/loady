//
//  LoadyBackgroundHighlighter.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
public extension LoadyAnimationType {
	static func backgroundHighlighter()->LoadyBackgroundHighlighterAnimation{
		return LoadyBackgroundHighlighterAnimation()
	}
}

public class LoadyBackgroundHighlighterAnimation: LoadyAnimation, LoadyPercentageObserver {
	var fillingLayer: CAShapeLayer?
	var containerLayer: CAShapeLayer?
	private func createFillingLoading(){
		//a shape for filling the button
		let fillingLayer = CAShapeLayer();
		fillingLayer.backgroundColor = self.loady.backgroundFillColor.cgColor
		fillingLayer.bounds = CGRect(x:0,y:0, width: 0,height: self.loady.frame.size.height);
		fillingLayer.anchorPoint = CGPoint(x:0,y:0.5);
		fillingLayer.position = CGPoint(x:0,y: self.loady.frame.size.height / 2);
		fillingLayer.masksToBounds = true
		self.fillingLayer = fillingLayer
		//create aniamtion
		let containerLayer = CAShapeLayer()
		containerLayer.bounds = CGRect(x:0,y:0,width: self.loady.frame.size.width,height: self.loady.frame.size.height)
		containerLayer.position = CGPoint(x:self.loady.frame.size.width / 2, y: self.loady.frame.size.height / 2)
		containerLayer.masksToBounds = true
		containerLayer.cornerRadius = self.loady.layer.cornerRadius
		containerLayer.insertSublayer(fillingLayer,at:0)
		self.containerLayer = containerLayer
		
		self.loady.addSublayer(self.containerLayer!, at: 0);
	}
	
	private var loading: Bool = false
	public func isLoading() -> Bool {
		return loading
	}
	
	public func inject(loady: Loadiable) {
		self.loady = loady
	}
	
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "backgroundHighlighter")
	private unowned var loady: Loadiable!
	private var strokeFillerLayer: CAShapeLayer?
	
	public func change(from: CGFloat, to: CGFloat) {
		
		self.fillingLayer?.bounds =  CGRect(x : 0, y: (self.loady.frame.size.height / 2), width: (self.loady.frame.size.width * (to  / 100)), height: self.loady.frame.size.height)
	}
	
	public func run() {
		loading = true
		createFillingLoading()
		
	}
	
	public func stop() {
		loading = false
		self.containerLayer?.removeFromSuperlayer()
		self.containerLayer = nil
		self.fillingLayer?.removeFromSuperlayer()
		self.fillingLayer = nil
	}
}
