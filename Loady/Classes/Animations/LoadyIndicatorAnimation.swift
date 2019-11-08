//
//  IndicatorAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

public extension LoadyAnimationType {
	static func indicator(with options: LoadyIndicatorAnimation.AnimationOption)->LoadyIndicatorAnimation{
		return LoadyIndicatorAnimation(options: options)
	}
}

public typealias IndicatorViewStyle = Bool
public extension IndicatorViewStyle {
	static let light = false
	static let black = true
}

public class LoadyIndicatorAnimation: LoadyAnimation {
	public struct AnimationOption {
		var indicatorViewStyle: IndicatorViewStyle = .light
		public init(indicatorViewStyle: IndicatorViewStyle) {
			self.indicatorViewStyle = indicatorViewStyle
		}
	}
	private let options: AnimationOption
	init(options: AnimationOption) {
		self.options = options
	}
	
	public func inject(loady: Loadiable) {
		self.loady = loady
	}
	private var loading: Bool = false

	public func isLoading() -> Bool {
		return loading
	}
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "indicator")
	lazy var activiyIndicator : LoadyActivityIndicator = { UIActivityIndicatorView() }()
	private unowned var loady: Loadiable!
	public func run() {
		loading = true
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
	
	public func stop() {
		loading = false
		self.activiyIndicator.removeFromSuperview()
		if let button = self.loady as? UIButton {
			UIView.animate(withDuration: 0.3) {
				button.titleEdgeInsets = .zero
				self.loady.layoutIfNeeded()
			}
		}
	}
}
