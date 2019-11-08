//
//  LoadyDownloadingAnimation.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

public extension LoadyAnimationType {
	static func downloading(with options: LoadyDownloadingAnimation.AnimationOption)->LoadyDownloadingAnimation{
		return LoadyDownloadingAnimation(options: options)
	}
}

public class LoadyDownloadingAnimation {
	public struct AnimationOption {
		public typealias Label = (title:String,font : UIFont, textColor : UIColor)
		var downloadingLabel : Label?
		var percentageLabel: (font : UIFont, textColor : UIColor)?
		var downloadedLabel : Label?
		public init(downloadingLabel : Label?,percentageLabel: (font : UIFont, textColor : UIColor)?,downloadedLabel : Label?) {
			self.downloadingLabel = downloadingLabel
			self.percentageLabel = percentageLabel
			self.downloadedLabel = downloadedLabel
		}
	}
	private let options: AnimationOption
	init(options: AnimationOption) {
		self.options = options
	}
	public static var animationTypeKey: LoadyAnimationType.Key = .init(rawValue: "indicator")
	lazy var activiyIndicator : LoadyActivityIndicator = { UIActivityIndicatorView() }()
	private unowned var loady: (Loadiable & UIButton)!
	private var loading: Bool = false
	var fillingLayer: CAShapeLayer?
	var containerLayer: CAShapeLayer?
	private func createFillingLoading(){
		//a shape for filling the button
		let fillingLayer = CAShapeLayer();
		fillingLayer.backgroundColor = self.loady.backgroundFillColor.cgColor
		fillingLayer.bounds = CGRect(x:0,y:0, width: 0,height: 4);
		fillingLayer.anchorPoint = CGPoint(x:0,y:0.5);
		fillingLayer.position = CGPoint(x:0,y: self.loady.frame.size.height / 2);
		fillingLayer.masksToBounds = true
		self.fillingLayer = fillingLayer
		//create aniamtion
		let containerLayer = CAShapeLayer()
		containerLayer.bounds = CGRect(x:0,y:0,width: self.loady.frame.size.width,height: 4)
		containerLayer.position = CGPoint(x:self.loady.frame.size.width / 2, y: self.loady.frame.size.height / 2)
		containerLayer.masksToBounds = true
		containerLayer.cornerRadius = self.loady.layer.cornerRadius
		containerLayer.insertSublayer(fillingLayer,at:0)
		self.containerLayer = containerLayer
		self.loady.addSublayer(self.containerLayer!, at: 0);
	}
	private func createDownloadingLayer(){
		let center = self.loady.center
		self.loady.cleanCanvas()
		UIView.animate(withDuration: 0.25, animations: {
			self.loady.center = center;
			self.loady.layer.bounds.size.height = 5
			self.loady.layer.cornerRadius = 5 / 2;
			self.loady.layoutIfNeeded()
		}, completion: { (finished) in
			if(finished){
				//filling animation
				self.createFillingLoading()
				if let _ = self.options.downloadingLabel {
					self.createDownloadingLabelLayer()
				}
				if let _ = self.options.percentageLabel {
					self.createPercentageLabelLayer()
				}
			}
		})
		
	}
	var labelLayer: CATextLayer?
	var percentageLayer: CATextLayer?
	
	
	private func createDownloadingLabelLayer(){
		// create a temp layer to hide animation behide it
		let containerLayer = CAShapeLayer()
		let size = CGSize(width: self.loady.bounds.width, height: 30)
		containerLayer.bounds = CGRect(x: 0, y:  0, width: size.width, height: size.height)
		containerLayer.position.x = containerLayer.bounds.midX
		containerLayer.position.y = size.height / -2
		let text = LoadyCore.createTextLayers(layer:containerLayer,string: options.downloadingLabel!.title, font: options.downloadingLabel!.font)
		text.foregroundColor = options.downloadingLabel!.textColor.cgColor
		containerLayer.addSublayer(text)
		labelLayer = text
		
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		let animation = LoadyCore.createTextPushAnimation(type: .fromTop, duration: 0.3)
		text.add(animation, forKey:"changeTextTransition")
		containerLayer.masksToBounds = true
		self.loady.addSublayer(containerLayer, at: 0)
		UIView.commitAnimations()
	}
	
	private func finishDownloading(){
		guard let downloadLabel = labelLayer, let downloadedOption = options.downloadedLabel else {
			return
		}
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		downloadLabel.string = downloadedOption.title
		downloadLabel.foregroundColor = downloadedOption.textColor.cgColor
		downloadLabel.font = downloadedOption.font
		downloadLabel.position.x = self.loady.layer.position.x
		downloadLabel.fontSize = downloadedOption.font.pointSize
		let animation = LoadyCore.createTextPushAnimation(type: .fromTop, duration: 0.3)
		downloadLabel.add(animation, forKey:"changeTextTransition")
		UIView.commitAnimations()
	}
	
	private func createPercentageLabelLayer(){
		// create a temp layer to hide animation behide it
		let containerLayer = CAShapeLayer()
		let size = CGSize(width: self.loady.bounds.width, height: 30)
		containerLayer.bounds = CGRect(x: 0, y:  0, width: size.width, height: size.height)
		containerLayer.position.x = containerLayer.bounds.midX
		containerLayer.position.y = (self.loady.bounds.height + size.height / 2) + 8
		//layer.backgroundColor = UIColor.green.cgColor
		let text = LoadyCore.createTextLayers(layer:containerLayer,string: "0%", font: options.percentageLabel!.font)
		text.foregroundColor = options.percentageLabel!.textColor.cgColor
		containerLayer.addSublayer(text)
		percentageLayer = text
		
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		let animation = LoadyCore.createTextPushAnimation(type: .fromBottom, duration: 0.3)
		text.add(animation, forKey:"changeTextTransitionPercent")
		containerLayer.masksToBounds = true
		self.loady.addSublayer(containerLayer, at: 1)
		UIView.commitAnimations()
	}
}

extension LoadyDownloadingAnimation: LoadyAnimation, LoadyPercentageObserver  {
	public func inject(loady: Loadiable) {
		guard let loady = loady as? Loadiable & UIButton else {
			assertionFailure("this animation will apply only on UIbutton")
			return
		}
		self.loady = loady
	}
	public func completed(lastetValue: CGFloat) {
		finishDownloading()
	}
	public func change(from: CGFloat, to: CGFloat) {
		self.fillingLayer?.bounds =  CGRect(x : 0, y: (self.loady.frame.size.height / 2), width: (self.loady.frame.size.width * (to  / 100)), height: self.loady.frame.size.height)
		percentageLayer?.string = String(format:"%.1f%%", to)
	}
	public func isLoading() -> Bool {
		return loading
	}
	
	public func run() {
		loading = true
		createDownloadingLayer()
	}
	
	public func stop() {
		loading = false
		self.containerLayer?.removeFromSuperlayer()
		labelLayer?.removeFromSuperlayer()
		percentageLayer?.removeFromSuperlayer()
		loady.reloadDefaultState(duration: 0.5, done: nil)
	}
}

