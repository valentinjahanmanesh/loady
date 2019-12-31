//
//  Loady.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//
// NOTE : we have to make this better, there can be many imporvements like maganging options and handle them in one place, new animations and ...

import UIKit
extension LoadyAnimationType {
	static let none: LoadyAnimationType.Key = .init(rawValue: "none")
}

open class LoadyButton : UIButton, Loadiable {
	public func addSublayer(_ layer: CALayer) {
		self.layer.addSublayer(layer)
		// some shit swift bug
		if let imageview = self.imageView {
			self.bringSubviewToFront(imageview)
		}
	}
	public func addSublayer(_ layer: CALayer, at: UInt32) {
		self.layer.insertSublayer(layer, at: at)
		
		// some shit swift bug
		if let imageview = self.imageView {
			self.bringSubviewToFront(imageview)
		}
	}
	
	public func cleanCanvas() {
		copyBeforeAnyChanges()
		self.setTitle("", for: .normal);
	}
	
	private func reloadDefaultState() {
		guard  let cached = self._cacheButtonBeforeAnimation else{
			return
		}
		
		self.bounds = CGRect(x:0,y: 0,width: cached.frame.size.width,height: cached.frame.size.height)
		self.layer.cornerRadius = cached.layer.cornerRadius
		self.frame.origin.x = 0
		self.backgroundColor = cached.backgroundColor
		self.transform = .identity
		self.layoutIfNeeded()
	}
	
	public func reloadDefaultState(duration: TimeInterval = 0, done: (() -> Void)?) {
		let otherStuff = {
			UIView.performWithoutAnimation {
				self.setTitle(self._cacheButtonBeforeAnimation?.titleLabel?.text, for: .normal)
				self.layoutIfNeeded()
			}
			done?()
		}
		if duration == 0 {
			reloadDefaultState()
			otherStuff()
		} else {
			UIView.animate(withDuration: duration, animations: {
				self.reloadDefaultState()
			}) { finish in if finish {otherStuff()}}
		}
	}
	
	/// some animations has a indicator like a line, this is that line color
	@IBInspectable open  var loadingColor : UIColor = UIColor.black
	
	/// some animations fills the button with a color, this is that color
	@IBInspectable open var backgroundFillColor : UIColor = UIColor.black
	
	/// some animations shows a indiccatorView, this is the style of that indicator view
	@IBInspectable open var indicatorViewStyle: IndicatorViewStyle = .light
	
	/// some animations shows an image inside of the button, this is that image
	open var pauseImage : UIImage?
	open internal(set) var animationType: LoadyAnimationType.Key = LoadyAnimationType.none

	fileprivate var _percentFilled : CGFloat = 0 {
		willSet{
			currentAnimation?.change(from: _percentFilled, to: newValue)
		}
		didSet {
			if _percentFilled == 100 {
				percentageCompleted()
			}
		}
	}
	open func setAnimation(_ animation: LoadyAnimation) {
		self.animationType = type(of: animation).animationTypeKey
		animation.inject(loady: self)
		self.currentAnimation = animation
	}
	internal var currentAnimation: LoadyAnimation?
	// we keep a copy of button properties before animation is begin and will restore them after animation is finished
	private var _cacheButtonBeforeAnimation : UIButton?
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		_percentFilled = 0;
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_percentFilled = 0;
		self.backgroundFillColor = .black;
		self.loadingColor = .black
	}
	
	/**
	cache the button before any animation,we keep a reference to data so we can restore everything to the first place
	*/
	func copyBeforeAnyChanges(){
		_cacheButtonBeforeAnimation = UIButton();
		if #available(iOS 11.0, *) {
			guard  let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false),  let btn = ((try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? UIButton) as UIButton??) else {
				return
			}
			
			_cacheButtonBeforeAnimation = btn
		} else {
			let archivedData = NSKeyedArchiver.archivedData(withRootObject:  self)
			guard  let btn = ((try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? UIButton) as UIButton??) else {
				return
			}
			
			_cacheButtonBeforeAnimation = btn
		}
		
		_cacheButtonBeforeAnimation?.layer.cornerRadius = self.layer.cornerRadius
		
	}
	
	/// stop loading and remove all animations and temporary layers
	open func stopLoading(){
		guard self.loadingIsShowing() else { return }
			_percentFilled = 0;
			currentAnimation?.stop()
	}
		
	open func startLoading(){
		if self.currentAnimation?.isLoading() ?? false {
			return;
		}
		currentAnimation?.run()
	}
	
	open func update(percent: CGFloat){
		if ( percent > 100){
			if _percentFilled != 100 {
				_percentFilled = 100
			}else{
				return
			}
		}else{
			_percentFilled = percent;
		}
	}
	
	/// notifies all animations about 100%, some animations need to preform some actions
	private func percentageCompleted(){
		currentAnimation?.completed(lastetValue: 100)
	}

	open func loadingIsShowing() -> Bool{
		return self.currentAnimation?.isLoading() ?? false
	}

}
