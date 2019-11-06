//
//  Loady.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//
// NOTE : we have to make this better, there can be many imporvements like maganging options and handle them in one place, new animations and ...

import UIKit

public struct LoadyAnimationType: RawRepresentable {
	public var rawValue: Key
	public init(rawValue: Key) {
		self.rawValue = rawValue
	}
	public struct Key: RawRepresentable, Equatable {
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		public var rawValue: String
	}
}

extension LoadyAnimationType {
	static let none: LoadyAnimationType.Key = .init(rawValue: "none")
	static let all: LoadyAnimationType.Key = .init(rawValue: "all")
	static let downloading: LoadyAnimationType.Key = .init(rawValue: "downloading")
}

public typealias IndicatorViewStyle = Bool
extension IndicatorViewStyle {
	static let light = false
	static let black = true
}

open class Loady : UIButton, Loadiable {
	public func addSublayer(_ layer: CALayer) {
		self.layer.addSublayer(layer)
	}
	public func addSublayer(_ layer: CALayer, at: UInt32) {
		self.layer.insertSublayer(layer, at: at)
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
			}) { finish in
				if finish {
					otherStuff()
				}
			}
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
	
	// MARK: Animation Options
	/// animations options, along with default that we can set from other properties, eeach animation has its own options that can set from here
	open var animationsOptions = LoadyAnimationOptions()
	
	lazy var activiyIndicator : LoadyActivityIndicator = { UIActivityIndicatorView() }()
	
	// these keys are used to mark some layers as temps layer and we will remove them after animation is done
	enum LayerTempKeys: String {
		case tempLayer = "temps"
		case circularLoading = "circularLoading"
		case downloading_percentLabel = "downloading_percentLabel"
		case downloading_downloadLabel = "downloading_downloadLabel"
	}
	
	
	fileprivate var _percentFilled : CGFloat = 0 {
		willSet{
			currentAnimation?.change(from: _percentFilled, to: newValue)
			percentageChanged(newValue,_percentFilled)
		}
		didSet {
			if _percentFilled == 100 {
				percentageCompleted()
			}
		}
	}
	var currentAnimation: LoadyAnimation?
	var _isloadingShowing = false
	var _filledLoadingLayer : CAShapeLayer?
	var _circleStrokeLoadingLayer : CAShapeLayer?
	var templayers : Dictionary<String,CALayer>  = [:]
	// we keep a copy of button properties before animation is begin and will restore them after animation is finished
	var _cacheButtonBeforeAnimation : UIButton?
	
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
		if self.loadingIsShowing(){
			self.endAndDeleteLoading()
		}
	}
	
	open internal(set) var animationType: LoadyAnimationType.Key = LoadyAnimationType.none
	
	open func startLoading(){
		if self.currentAnimation?.isLoading() ?? false {
			return;
		}
		currentAnimation?.run()
	}
	
	private func removeIndicatorView(){
		currentAnimation?.stop()
	}
	
	open func fillTheButton(with percent : CGFloat){
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
	
	
	/// notifies other functions about percent changes
	///
	/// - Parameters:
	///   - new: new value
	///   - old: current value
	private func percentageChanged(_ new: CGFloat,_ old: CGFloat){
		fillTheCircleStrokeLoadingWith(new: new, old: old)
		fillTheButtonBackground(new: new, old: old)
	}
	
	/// notifies all animations about 100%, some animations need to preform some actions
	private func percentageCompleted(){
		currentAnimation?.completed(lastetValue: 100)
	}
	
	/**
	check if loading is showing or there are some loading views left
	
	@return is loading showing?
	*/
	
	open func loadingIsShowing() -> Bool{
		return self.currentAnimation?.isLoading() ?? false
	}
	
	
	
	/**
	remove itemes that related to views
	*/
	private func endAndDeleteLoading(){
		_isloadingShowing = false;
		_percentFilled = 0;
		currentAnimation?.stop()
	}
	
	/**
	create the filling layer
	
	@param percent of the completion something like 10,12,15...100
	*/
	private func fillTheButtonBackground(new : CGFloat,old : CGFloat){
		if self._filledLoadingLayer == nil || !_isloadingShowing{
			return
		}
		//_percentFilled = 0;
		self._filledLoadingLayer?.sublayers?[0].bounds =  CGRect(x : 0,y: (self.frame.size.height / 2),width: (self.frame.size.width * (new  / 100)),height: self.frame.size.height)
		
	}
	
	/// some animations like circleAndTick, android, downloading and ... change the size of the button, scale it or some how resize it, this function will scale the button to identity and also brings it back to the original sizes
	private func removeScalesAndResizes(){
		//		if  _animationType != .circleAndTick && _animationType != .android && _animationType != .downloading{
		//			return
		//		}
		//		self.clearTempLayers()
		//		self.titleLabel?.text  = ""
		//		self._circleStrokeLoadingLayer?.removeAllAnimations()
		//		UIView.animate(withDuration: 0.5, animations: {[weak self] in
		//			guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
		//				return
		//			}
		//			weakSelf.bounds = CGRect(x:0,y: 0,width: cached.frame.size.width,height: cached.frame.size.height);
		//			weakSelf.layer.cornerRadius = cached.layer.cornerRadius;
		//			weakSelf.transform = .identity;
		//			weakSelf.backgroundColor = cached.backgroundColor;
		//			weakSelf.layoutIfNeeded();
		//		}) {[weak self] (finished) in
		//
		//			if (finished){
		//				guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
		//					return
		//				}
		//				UIView.performWithoutAnimation {
		//					weakSelf.setTitle(cached.titleLabel?.text, for: .normal)
		//				}
		//				weakSelf._circleStrokeLoadingLayer?.removeFromSuperlayer()
		//				weakSelf._circleStrokeLoadingLayer = nil;
		//			}
		//		}
	}
	
	
	/// removes all layers which decorated by TempLayer key, some animations adds a temp layer to show animations, we will clear all of them after finishing our work
	private func clearTempLayers(){
		
		self.layer.sublayers?.forEach({ (layer) in
			if let temp = layer.accessibilityHint,temp == LayerTempKeys.tempLayer.rawValue {
				layer.removeFromSuperlayer()
			}
		})
	}
	
	
	/**
	fill the stroke
	
	@param percent of the completion something like 10,12,15...100
	*/
	private func fillTheCircleStrokeLoadingWith(new :CGFloat, old : CGFloat){
		
		if self._circleStrokeLoadingLayer == nil || !_isloadingShowing{
			return;
		}
		
		let animation = LoadyCore.createBasicAnimation(keypath: "strokeEnd", from: NSNumber(floatLiteral: Double(old / 100)), to: NSNumber(floatLiteral: Double( new / 100)),duration : 0.2)
		animation.isRemovedOnCompletion = false;
		animation.fillMode = .forwards;
		self._circleStrokeLoadingLayer?.add(animation, forKey: nil)
	}
}

// MARK: - Creates the Circle Loading
extension Loady {
	private func createCircleLoadingLayer(radius : CGFloat? = nil,centerX : CGFloat? = nil,centerY : CGFloat? = nil){
		self._circleStrokeLoadingLayer = LoadyCore.createCircleInside(bounds: self.bounds, strokeColor: self.loadingColor, radius: radius ,centerX: centerX ,centerY: centerY)
		self._circleStrokeLoadingLayer?.accessibilityHint = "button_circle_loading_stroke_parent"
		
		self.layer.addSublayer(self._circleStrokeLoadingLayer!)
	}
}

public protocol Loadiable where Self: UIView {
	/// some animations has a indicator like a line, this is that line color
	var loadingColor : UIColor {set get}
	/// some animations shows an image inside of the button, this is that image
	var pauseImage : UIImage? {set get}
	var backgroundFillColor : UIColor {set get}
	var backgroundColor : UIColor? {set get}
	func addSublayer(_ layer: CALayer)
	func addSublayer(_ layer: CALayer, at: UInt32)
	func cleanCanvas()
	func reloadDefaultState(duration: TimeInterval, done: (()->Void)?)
}

extension Loadiable where Self: UIButton {
	var titleLabel: UILabel? {get {
		self.titleLabel
		}
	}
	func setTitle(_ title: String?, for state: UIControl.State) {
		
	}
}
