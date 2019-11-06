//
//  IndicatorAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

extension LoadyAnimationType {
	static func indicator(with options: LoadyIndicatorAnimation.AnimationOption)->LoadyIndicatorAnimation{
		return LoadyIndicatorAnimation(options: options)
	}
}

class LoadyIndicatorAnimation: LoadyAnimation {
	public struct AnimationOption {
		var indicatorViewStyle: IndicatorViewStyle = .light
	}
	private let options: AnimationOption
	init(options: AnimationOption) {
		self.options = options
	}
	
	func inject(loady: Loadiable) {
		self.loady = loady
	}
	
	func isLoading() -> Bool {
		return false
	}
	static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "indicator")
	lazy var activiyIndicator : LoadyActivityIndicator = { UIActivityIndicatorView() }()
	private unowned var loady: Loadiable!
	func run() {
		let indicator = self.activiyIndicator
		indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		if let button = self.loady as? UIButton, let titleLabel = button.titleLabel {
			UIView.animate(withDuration: 0.3) {
				button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30);
				self.loady.layoutIfNeeded()
			}
			indicator.center = CGPoint(x: titleLabel.frame.maxX + 15,y: self.loady.bounds.midY)
		} else {
			indicator.center = CGPoint(x: self.loady.bounds.midX,y: self.loady.bounds.midY)
		}
		
		// bounce animation
		indicator.transform = CGAffineTransform(scaleX: 0, y: 0)
		indicator.isUserInteractionEnabled = false
		
		if let indicator = indicator as? UIActivityIndicatorView{
			indicator.style = self.options.indicatorViewStyle ? .gray : .white
		}
		
		indicator.startAnimating()
		self.loady.insertSubview(indicator, at: 0)
		UIView.animate(withDuration: 0.05, delay: 0.3, options: .curveLinear, animations: {
			indicator.transform  = .identity
			self.loady.layoutIfNeeded()
		}, completion: nil)
		
	}
	
	func stop() {
		self.activiyIndicator.removeFromSuperview()
	}
}
