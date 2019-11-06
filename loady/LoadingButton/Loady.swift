//
//  Loady.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//
// NOTE : we have to make this better, there can be many imporvements like maganging options and handle them in one place, new animations and ...

import UIKit

// yes i know i can emit that number, i've specfied them to find the number quickly.
public enum LoadyAnimationType {
	case none
	case topLine
	case indicator
	case backgroundHighlighter
	case circleAndTick
	case all
	case appstore
	case android
	case downloading
}
public typealias IndicatorViewStyle = Bool
extension IndicatorViewStyle {
	static let light = false
	static let black = true
}

open class Loady : UIButton, Loadiable {
	func addSublayer(_ layer: CALayer) {
		self.layer.addSublayer(layer)
	}
	
	func cleanCanvas() {
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
	
	func reloadDefaultState(duration: TimeInterval = 0, done: (() -> Void)?) {
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
		//		didSet {
		//			if let textlayer = self.templayers[LayerTempKeys.downloading_percentLabel] as? CATextLayer {
		//				textlayer.string = String(format:"%.2f%%", self._percentFilled)
		//			}
		//
		//			if _percentFilled == 100 {
		//				percentageCompleted()
		//			}
		//		}
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
		self.animationType = .none;
		_percentFilled = 0;
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_percentFilled = 0;
		self.animationType = .none;
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
	
	open internal(set) var animationType: LoadyAnimationType = .none
	// MARK: - Starting Point (everything starts here)
	/**
	start loading,this is our public api to start loading
	
	@param animationType the loading style
	*/
	private func startLoading(animationType: LoadyAnimationType){
		if self.loadingIsShowing(){
			//self.stopLoading()
			return;
		}
		self.animationType = animationType

		switch animationType {
		case .topLine:
			self.createTopLineLoading()
			break;
		case .indicator :
			currentAnimation = LoadyIndicatorAnimation(loady: self)
			break;
		case .backgroundHighlighter :
			self.createFillingLoading()
			break;
		case .circleAndTick :
			currentAnimation = LoadyCircleAndTickAnimation(loady: self)
			break;
		case .android :
//			self.createCircleAndTick(withAndroidAnimation: true)
			break;
		case .appstore :
			currentAnimation = LoadyAppStoreAnimation(loady: self)
			break;
		case .all:
			//top line animation
			self.createTopLineLoading()
			
			//indicator view animation
			//            self.createIndicatorLoading()
			
			//filling animation
			self.createFillingLoading()
			break;
		case .downloading :
			self.createDownloadingLayer()
			break
		case .none:
			break
		}
		currentAnimation?.run()
		//indicates that loading is showing
		_isloadingShowing = true;
	}
	open func startLoading(){
		self.startLoading(animationType: self.animationType)
	}
	func createBasicAnimation(keypath : String, from : Any,to:Any,duration : Double = 1) -> CABasicAnimation{
		let animation = CABasicAnimation()
		animation.keyPath = keypath
		animation.fromValue = from
		animation.toValue = to
		animation.duration = duration;
		
		return animation
	}
	
	
	private func removeIndicatorView(){
		currentAnimation?.stop()
		currentAnimation = nil
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
		finishDownloading()
	}
	
	///line loading
	private func createTopLineLoading(){
		//create our loading layer and line path
		let loadingLayer = CAShapeLayer();
		let path = UIBezierPath();
		
		//height of the line
		let lineHeight : CGFloat = 2.0;
		
		//center the layer in our view and set the bounds
		loadingLayer.position = CGPoint(x:self.frame.size.width / 2,y: -1);
		loadingLayer.bounds = CGRect(x:0,y: 0, width: self.frame.size.width, height: lineHeight);
		
		//draw our line
		path.move(to: CGPoint(x:0,y: -1))
		path.addLine(to: CGPoint(x:loadingLayer.bounds.size.width/2.4,y: -1))
		
		//set the path layer, and costumizing it
		loadingLayer.path = path.cgPath;
		loadingLayer.strokeColor = self.loadingColor.cgColor;
		loadingLayer.strokeEnd = 1;
		loadingLayer.lineWidth = lineHeight;
		loadingLayer.lineCap = CAShapeLayerLineCap(rawValue: "round");
		loadingLayer.contentsScale = UIScreen.main.scale;
		loadingLayer.accessibilityHint = "button_topline_loading";
		loadingLayer.opacity = 0
		//add the new layer
		self.layer.addSublayer(loadingLayer);
		
		//animated path
		let animatedPath = UIBezierPath()
		animatedPath.move(to: CGPoint(x:loadingLayer.bounds.size.width / 1.2,y: -1))
		animatedPath.addLine(to: CGPoint(x:loadingLayer.bounds.size.width,y: -1))
		let animateOpacity = createBasicAnimation(keypath: "opacity", from: 0, to: 1,duration : 0.6)
		animateOpacity.isRemovedOnCompletion = false
		animateOpacity.fillMode  = .forwards
		
		//create our animation and add it to the layer, animate indictor from left to right
		let animation = createBasicAnimation(keypath: "path", from: path.cgPath, to: animatedPath.cgPath)
		animation.autoreverses = true;
		animation.repeatCount = 100;
		animation.isRemovedOnCompletion = false
		loadingLayer.add(animation,forKey:nil);
		loadingLayer.add(animateOpacity,forKey:nil);
	}
	
	private func removeTopLineLayer(){
		
		//Reset button
		self.layer.sublayers?.forEach({layer in
			if layer.accessibilityHint == "button_topline_loading" {
				let animateOpacity = createBasicAnimation(keypath: "opacity", from: 1, to: 0,duration : 0.2)
				layer.add(animateOpacity, forKey: nil)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 , execute: {
					layer.removeAllAnimations()
					layer.removeFromSuperlayer()
				})
			}
		})
		
		//move the label view to center
		UIView.animate(withDuration: 0.3) {
			self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
			self.layoutIfNeeded()
		}
	}
	/**
	check if loading is showing or there are some loading views left
	
	@return is loading showing?
	*/
	
	open func loadingIsShowing() -> Bool{
		if self.currentAnimation != nil{
			return true;
		}
		
		if self._filledLoadingLayer != nil || self._circleStrokeLoadingLayer != nil{
			return true;
		}
		
		if let subs = self.layer.sublayers {
			for layer in subs {
				if layer.accessibilityHint == "button_topline_loading" {
					return true
				}
			}
		}
		return false;
	}
	
	
	
	/**
	remove itemes that related to views
	*/
	private func endAndDeleteLoading(){
		_isloadingShowing = false;
		_percentFilled = 0;
		currentAnimation?.stop()
		currentAnimation = nil
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
		
		let animation = createBasicAnimation(keypath: "strokeEnd", from: NSNumber(floatLiteral: Double(old / 100)), to: NSNumber(floatLiteral: Double( new / 100)),duration : 0.2)
		animation.isRemovedOnCompletion = false;
		animation.fillMode = .forwards;
		self._circleStrokeLoadingLayer?.add(animation, forKey: nil)
	}
}

// MARK: - Some Handy functions
extension Loady {
	private func calculateTextHeight(string : String,withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	
	private  func calculateTextWidth(string : String,withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
	
	/// convert degree to radian
	///
	/// - Parameter degree: degree
	/// - Returns: calculated radian
	private func degreeToRadian(degree : CGFloat)->CGFloat{
		return degree * .pi / 180;
	}
	
	/// Resizes Images to idle size
	///
	/// - Parameters:
	///   - image: the UIImage to resize
	///   - targetSize: target size
	/// - Returns: the image with new size
	private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
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

// MARK: - Creates the Downloading Layer
extension Loady {
	private func createDownloadingLayer(){
		let center = self.center
		self.copyBeforeAnyChanges()
		self.setTitle("", for: .normal);
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			UIView.animate(withDuration: 0.25, animations: {
				self.center = center;
				self.bounds.size.height = 5 // = CGRect(x:self.center.x,y: self.center.y,width: radius,height: radius);
				self.layer.cornerRadius = 5 / 2;
				self.layoutIfNeeded()
			}, completion: { (finished) in
				if(finished){
					self.titleLabel?.text  = ""
					//filling animation
					self.createFillingLoading()
					guard let options = self.animationsOptions.downloading else {
						return
					}
					if let _ = options.downloadingLabel {
						self.createDownloadingLabelLayer(labelOption: options)
					}
					if let _ = options.percentageLabel {
						self.createPercentageLabelLayer(labelOption: options)
					}
				}
			})
		}
	}
	
	
	
	private func createDownloadingLabelLayer(labelOption : LoadyAnimationOptions.Downloading){
		// create a temp layer to hide animation behide it
		let containerLayer = CAShapeLayer()
		let size = CGSize(width: self.bounds.width, height: 30)
		containerLayer.bounds = CGRect(x: 0, y:  0, width: size.width, height: size.height)
		containerLayer.position.x = containerLayer.bounds.midX
		containerLayer.position.y = size.height / -2
		//layer.backgroundColor = UIColor.green.cgColor
		let text = LoadyCore.createTextLayers(layer:containerLayer,string: labelOption.downloadingLabel!.title, font: labelOption.downloadingLabel!.font)
		text.foregroundColor = labelOption.downloadingLabel!.textColor.cgColor
		containerLayer.addSublayer(text)
		containerLayer.accessibilityHint = LayerTempKeys.tempLayer.rawValue
		
		// keep a reference to change this text after animation finished
		templayers.updateValue(text, forKey: LayerTempKeys.downloading_downloadLabel.rawValue)
		
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		let animation = LoadyCore.createTextPushAnimation(type: .fromTop, duration: 0.3)
		text.add(animation, forKey:"changeTextTransition")
		containerLayer.masksToBounds = true
		self.layer.insertSublayer(containerLayer, at: 0)
		UIView.commitAnimations()
	}
	
	private func finishDownloading(){
		guard let downloadLabel = templayers[LayerTempKeys.downloading_downloadLabel.rawValue] as? CATextLayer, let downloadedOption = self.animationsOptions.downloading?.downloadedLabel else {
			return
		}
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		downloadLabel.string = downloadedOption.title
		downloadLabel.foregroundColor = downloadedOption.textColor.cgColor
		downloadLabel.font = downloadedOption.font
		downloadLabel.position.x = self.layer.position.x
		downloadLabel.fontSize = downloadedOption.font.pointSize
		let animation = LoadyCore.createTextPushAnimation(type: .fromTop, duration: 0.3)
		downloadLabel.add(animation, forKey:"changeTextTransition")
		UIView.commitAnimations()
	}
	
	private func createPercentageLabelLayer(labelOption : LoadyAnimationOptions.Downloading){
		// create a temp layer to hide animation behide it
		let containerLayer = CAShapeLayer()
		let size = CGSize(width: self.bounds.width, height: 30)
		containerLayer.bounds = CGRect(x: 0, y:  0, width: size.width, height: size.height)
		containerLayer.position.x = containerLayer.bounds.midX
		containerLayer.position.y = (self.bounds.height + size.height / 2) + 8
		//layer.backgroundColor = UIColor.green.cgColor
		let text = LoadyCore.createTextLayers(layer:containerLayer,string: "\(_percentFilled)%", font: labelOption.percentageLabel!.font)
		text.foregroundColor = labelOption.percentageLabel!.textColor.cgColor
		containerLayer.addSublayer(text)
		containerLayer.accessibilityHint = LayerTempKeys.tempLayer.rawValue
		
		// keep a reference to change its percentage text
		templayers.updateValue(text, forKey: LayerTempKeys.downloading_percentLabel.rawValue)
		
		// add animation
		UIView.beginAnimations("changeTextTransition", context: nil)
		let animation = LoadyCore.createTextPushAnimation(type: .fromBottom, duration: 0.3)
		text.add(animation, forKey:"changeTextTransitionPercent")
		containerLayer.masksToBounds = true
		self.layer.insertSublayer(containerLayer, at: 1)
		UIView.commitAnimations()
	}
}

// MARK: - Creates the Filling Loading
extension Loady {
	/**
	create loading animation and layer
	*/
	private func createFillingLoading(){
		_percentFilled = 0;
		//a shape for filling the button
		let layer = CAShapeLayer();
		layer.backgroundColor = self.backgroundFillColor.cgColor
		layer.bounds = CGRect(x:0,y:0, width: 0,height: self.frame.size.height);
		layer.anchorPoint = CGPoint(x:0,y:0.5);
		layer.position = CGPoint(x:0,y: self.frame.size.height / 2);
		layer.accessibilityHint = "button_filled_loading";
		layer.masksToBounds = true
		
		//create aniamtion
		_filledLoadingLayer = CAShapeLayer()
		self._filledLoadingLayer?.bounds = CGRect(x:0,y:0,width: self.frame.size.width,height: self.frame.size.height)
		self._filledLoadingLayer?.position = CGPoint(x:self.frame.size.width / 2,y: self.frame.size.height / 2)
		self._filledLoadingLayer?.accessibilityHint = "button_filled_loading_parent"
		self._filledLoadingLayer?.masksToBounds = true
		self._filledLoadingLayer?.cornerRadius = self.layer.cornerRadius
		self._filledLoadingLayer?.insertSublayer(layer,at:0)
		self.layer.insertSublayer(self._filledLoadingLayer!,at:0);
	}
	
	private func removeFillingLayer(){
		self._filledLoadingLayer?.removeFromSuperlayer();
		_filledLoadingLayer = nil;
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

protocol Loadiable where Self: UIView {
	/// some animations has a indicator like a line, this is that line color
	var loadingColor : UIColor {set get}
	/// some animations shows an image inside of the button, this is that image
	var pauseImage : UIImage? {set get}
	var backgroundFillColor : UIColor {set get}
	var backgroundColor : UIColor? {set get}
	func addSublayer(_ layer: CALayer)
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
