//
//  Loady.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
struct LoadyAnimationOptions {
    struct FourPhase {
        enum Phases {
            case normal(title:String,image : UIImage?,background:UIColor)
            case loading(title:String,image : UIImage?,background:UIColor)
            case success(title:String,image : UIImage?,background:UIColor)
            case error(title:String,image : UIImage?,background:UIColor)
        }
    }
}
enum LoadingType: Int {
    case none
    case topLine
    case indicator
    case backgroundHighlighter
    case circleAndTick
    case all
    case appstore
    case fourPhases
    case android
}
typealias IndicatorViewStyle = Bool
extension IndicatorViewStyle {
    static let light = false
    static let black = true
}

class Loady : UIButton {
    // public settings
    @IBInspectable var animationType : Int = 0 {
        didSet{
            self._animationType = LoadingType(rawValue: self.animationType) ?? .none
        }
    }
    @IBInspectable var loadingColor : UIColor = UIColor.black
    @IBInspectable var backgroundFillColor : UIColor = UIColor.black
    @IBInspectable var indicatorViewStyle: IndicatorViewStyle = .light
    open var pauseImage : UIImage?
    var fourPhases : (normal:LoadyAnimationOptions.FourPhase.Phases,loading:LoadyAnimationOptions.FourPhase.Phases,success:LoadyAnimationOptions.FourPhase.Phases,error:LoadyAnimationOptions.FourPhase.Phases)? {
        didSet{
            guard let normal =  fourPhases?.normal else {
                return
            }
            self._fourPhasesNextPhase = normal
            self.createFourPhaseButton()
        }
    }
    // private settings
    private(set) var _animationType = LoadingType.none
    
    // this key is used to mark some layers as temps layer and we will remove them after animation is done
    private struct LayerTempKeys {
        static let tempLayer = "temps"
        static let circularLoading = "circularLoading"
    }
    
    fileprivate var _percentFilled : CGFloat = 0
    fileprivate var _isloadingShowing = false
    fileprivate var _filledLoadingLayer : CAShapeLayer?
    fileprivate var _circleStrokeLoadingLayer : CAShapeLayer?
    
    private(set) var _fourPhasesNextPhase : LoadyAnimationOptions.FourPhase.Phases?
    
    // we keep a copy of before animation button properties and will restore them after animation is finished
    fileprivate var _cacheButtonBeforeAnimation : UIButton?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.animationType != 0 {
            self._animationType = LoadingType(rawValue: self.animationType) ?? .none
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._animationType = .none;
        _percentFilled = 0;
        if self.animationType != 0 {
            self._animationType = LoadingType(rawValue: self.animationType) ?? .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _percentFilled = 0;
        self._animationType = .none;
        self.backgroundFillColor = .black;
        self.loadingColor = .black
        if(self.animationType != 0){
            self._animationType = LoadingType(rawValue: self.animationType) ?? .none
        }
    }
    
    /**
     cache the button before any animation,we keep a reference to data so we can restore everything to the first place
     */
    private func copyBeforeAnyChanges(){
        _cacheButtonBeforeAnimation = UIButton();
        
        if #available(iOS 11.0, *) {
            guard  let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false),  let btn = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? UIButton else {
                return
            }
            
            _cacheButtonBeforeAnimation = btn
        } else {
            let archivedData = NSKeyedArchiver.archivedData(withRootObject:  self)
            guard  let btn = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? UIButton else {
                return
            }
            
            _cacheButtonBeforeAnimation = btn
        }
        
        _cacheButtonBeforeAnimation?.layer.cornerRadius = self.layer.cornerRadius
        
    }
    
    
    /**
     start loading,this is our public api to start loading
     
     @param loadingType the loading style
     */
    func startLoading(loadingType:LoadingType? = nil){
        let loading = loadingType ?? self._animationType
        if let loadingType = loadingType {
            self.animationType = loadingType.rawValue
        }
        if self.loadingIsShowing(){
            self.endAndDeleteLoading()
            return;
        }
        switch (loading) {
        case .topLine:
            self.createTopLineLoading()
            break;
        case .indicator :
            self.createIndicatorLoading()
            break;
        case .backgroundHighlighter :
            self.createFillingLoading()
            break;
        case .circleAndTick :
            self.createCircleAndTick()
            break;
        case .android :
            self.createCircleAndTick(withAndroidAnimation: true)
            break;
        case .appstore :
            self.createAppstore()
            break;
        case .all:
            //top line animation
            self.createTopLineLoading()
            
            //indicator view animation
            self.createIndicatorLoading()
            
            //filling animation
            self.createFillingLoading()
            break;
        case .fourPhases:
            self.createFourPhaseButton()
        default:
            break;
        }
        
        //indicates that loading is showing
        _isloadingShowing = true;
    }
    
    /**
     move the text a little left and add the loading
     */
    private func createIndicatorLoading(){
        UIView.animate(withDuration: 0.3) {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30);
            self.layoutIfNeeded()
        }
        //create the loading view
        self.createIndicatorView()
    }
    
    /**
     create indicator view
     */
    private func createIndicatorView(){
        let indicator = UIActivityIndicatorView();
        indicator.style = self.indicatorViewStyle ? .gray : .white;
        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if let frame = self.titleLabel?.frame {
            indicator.center = CGPoint(x: frame.maxX + 15,y: self.bounds.size.height / 2)
        }
        indicator.transform = CGAffineTransform(scaleX: 0, y: 0);
        indicator.startAnimating()
        //i use some random id to find this view whenever needed
        indicator.tag = -11111111;
        indicator.isUserInteractionEnabled = false;
        self.insertSubview(indicator, at: 0)
        
        
        UIView.animate(withDuration: 0.05, delay: 0.3, options: .curveLinear, animations: {
            indicator.transform  = .identity
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    private func removeIndicatorView(){
        self.viewWithTag(-11111111)?.removeFromSuperview();
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
        //add the new layer
        self.layer.addSublayer(loadingLayer);
        
        //animated path
        let animatedPath = UIBezierPath()
        animatedPath.move(to: CGPoint(x:loadingLayer.bounds.size.width / 1.2,y: -1))
        animatedPath.addLine(to: CGPoint(x:loadingLayer.bounds.size.width,y: -1))
        
        //create our animation and add it to the layer
        let animation = CABasicAnimation()
        animation.keyPath = "path";
        animation.fromValue = path.cgPath;
        animation.toValue = animatedPath.cgPath;
        animation.duration = 1;
        animation.autoreverses = true;
        animation.repeatCount = 100;
        loadingLayer.add(animation,forKey:nil);
    }
    
    
    private func removeTopLineLayer(){
        //Reset button
        self.layer.sublayers?.forEach({layer in
            if layer.accessibilityHint == "button_topline_loading" {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
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
    
    func loadingIsShowing() -> Bool{
        if self.viewWithTag(-11111111) != nil{
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
        
        //[self.tempTimer invalidate];
        
        self.removeIndicatorView();
        self.removeCircleLoadingLayer();
        self.removeAppstoreLayer();
        self.removeFillingLayer();
        self.removeTopLineLayer();
        
    }
    
    /**
     create the filling layer
     
     @param percent of the completion something like 10,12,15...100
     */
    func fillTheButton(with percent : CGFloat){
        _percentFilled = percent;
        if (percent > 100){
            return
        }
        if !_isloadingShowing{
            return
        }
        if self._filledLoadingLayer == nil{
            return
        }
        _percentFilled = 0;
        self._filledLoadingLayer?.sublayers?[0].bounds =  CGRect(x : 0,y: (self.frame.size.height / 2),width: (self.frame.size.width * (percent  / 100)),height: self.frame.size.height)
        
    }
    
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
    
    private func createCircleAndTick(withAndroidAnimation : Bool = false){
        let center = self.center
        self.copyBeforeAnyChanges()
        let radius = min(self.frame.size.width, self.frame.size.height)
        self.setTitle("", for: .normal);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: withAndroidAnimation ? 0.15 : 0.5, animations: {
                self.center = center;
                self.bounds = CGRect(x:self.center.x,y: self.center.y,width: radius,height: radius);
                self.layer.cornerRadius = radius / 2;
                if !withAndroidAnimation {
                    self.transform = CGAffineTransform(scaleX: -1,y: 1);
                }
                self.backgroundColor = self.backgroundFillColor;
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if(finished){
                    self.titleLabel?.text  = ""
                    self.createCircleLoadingLayer()
                    if withAndroidAnimation {
                        self.startCircluarLoadingAnimation(self._circleStrokeLoadingLayer!)
                    }
                }
            })
        }
    }
    
    private func createAppstore(){
        //        let center = self.center
        self.copyBeforeAnyChanges()
        let radius = min(self.frame.size.width, self.frame.size.height)
        self.setTitle("", for: .normal);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                //self.center = center;
                self.bounds = CGRect(x:0,y: self.center.y,width: radius,height: radius);
                self.frame.origin.x = 0
                self.layer.cornerRadius = radius / 2;
                self.alpha = 0.2
                //self.transform = CGAffineTransform(scaleX: -1,y: 1);
                self.backgroundColor = self.backgroundFillColor;
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if(finished){
                    self.titleLabel?.text  = ""
                }
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.createAppstoreLoadingLayer()
        }
    }
    
    private func removeAppstoreLayer(){
        if _animationType != .appstore{
            return
        }
        self.clearTempLayers()
        self._circleStrokeLoadingLayer?.removeAllAnimations()
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
                return
            }
            
            weakSelf.bounds = CGRect(x:0,y: 0,width: cached.frame.size.width,height: cached.frame.size.height);
            weakSelf.layer.cornerRadius = cached.layer.cornerRadius;
            weakSelf.frame.origin.x = 0
            //weakSelf.transform = .identity;
            weakSelf.backgroundColor = cached.backgroundColor;
            weakSelf.layoutIfNeeded();
        }) {[weak self] (finished) in
            if (finished){
                guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
                    return
                }
                weakSelf.setTitle(cached.titleLabel?.text, for: .normal)
                
                weakSelf._circleStrokeLoadingLayer?.removeFromSuperlayer()
                weakSelf._circleStrokeLoadingLayer = nil;
            }
        }
    }
    
    private func removeCircleLoadingLayer(){
        if  _animationType != .circleAndTick && _animationType != .android{
            return
        }
        self.clearTempLayers()
        self.titleLabel?.text  = ""
        self._circleStrokeLoadingLayer?.removeAllAnimations()
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
                return
            }
            weakSelf.bounds = CGRect(x:0,y: 0,width: cached.frame.size.width,height: cached.frame.size.height);
            weakSelf.layer.cornerRadius = cached.layer.cornerRadius;
            weakSelf.transform = .identity;
            weakSelf.backgroundColor = cached.backgroundColor;
            weakSelf.layoutIfNeeded();
        }) {[weak self] (finished) in
            
            if (finished){
                guard let weakSelf = self , let cached = weakSelf._cacheButtonBeforeAnimation else{
                    return
                }
                UIView.performWithoutAnimation {
                    weakSelf.setTitle(cached.titleLabel?.text, for: .normal)
                }
                weakSelf._circleStrokeLoadingLayer?.removeFromSuperlayer()
                weakSelf._circleStrokeLoadingLayer = nil;
            }
        }
    }
    private func clearTempLayers(){
        
        self.layer.sublayers?.forEach({ (layer) in
            if let temp = layer.accessibilityHint,temp == LayerTempKeys.tempLayer {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    private func createCircleLoadingLayer(radius : CGFloat? = nil,centerX : CGFloat? = nil,centerY : CGFloat? = nil){
        self._circleStrokeLoadingLayer = createACircleInsideButton(radius: radius ,centerX: centerX ,centerY: centerY)
        self._circleStrokeLoadingLayer?.accessibilityHint = "button_circle_loading_stroke_parent"
        
        self.layer.addSublayer(self._circleStrokeLoadingLayer!)
    }
    

    private func createACircleInsideButton(radius : CGFloat? = nil,centerX : CGFloat? = nil,centerY : CGFloat? = nil)-> CAShapeLayer{
        let circle = CAShapeLayer()
        let path = UIBezierPath()
        let radius = radius ?? self.frame.width / 2 + 4
        circle.bounds = CGRect(x:0,y: 0,width: radius + 5,height: radius + 5);
        circle.strokeColor = self.loadingColor.cgColor;
        circle.lineWidth = 3;
        circle.fillColor = UIColor.clear.cgColor;
        circle.lineCap = CAShapeLayerLineCap(rawValue: "round");
        circle.strokeStart = 0.0;
        circle.strokeEnd = 0.0;
        let center = CGPoint(x: centerX ?? circle.bounds.midX,y: centerY ?? circle.bounds.midY);
        circle.position = CGPoint(x:self.bounds.midX,y: self.bounds.midY) ;
        circle.anchorPoint = CGPoint(x:0.5,y: 0.5);
        path.addArc(withCenter: center, radius: radius , startAngle: (-.pi / 2), endAngle: (-.pi / 2) + (-2.0 * .pi), clockwise: false)
        
        circle.path = path.cgPath
        return circle
    }
    private func createAppstoreLoadingLayer(){
        // creates the circle loading
        createCircleLoadingLayer(radius: self.frame.midX ,centerX: self.frame.maxX - self.frame.midX)
        
        let circleContainer = copyLayer(of: self._circleStrokeLoadingLayer!)
        circleContainer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        circleContainer.strokeStart = 0
        circleContainer.strokeEnd = 1
        circleContainer.opacity = 1
        circleContainer.accessibilityHint = LayerTempKeys.tempLayer
        
        // check if user specifies an image for pause
        if let image = pauseImage {
            let imageLayer = CAShapeLayer()
            imageLayer.bounds = CGRect(x:0,y: 0,width: 20,height: 20);
            imageLayer.position = CGPoint(x:self.frame.midX,y: circleContainer.bounds.midY);
            imageLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
            imageLayer.contents = image.cgImage
            circleContainer.addSublayer(imageLayer)
        }
        self.layer.addSublayer(circleContainer)
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    private func copyLayer(of copy : CAShapeLayer)-> CAShapeLayer{
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
    
    /**
     fill the stroke
     
     @param percent of the completion something like 10,12,15...100
     */
    func fillTheCircleStrokeLoadingWith(percent:CGFloat){
        
        if (percent > 100){
            //[self.tempTimer invalidate];
            return;
        }
        if !_isloadingShowing{
            return;
        }
        if self._circleStrokeLoadingLayer == nil{
            return;
        }
        
        let animation = CABasicAnimation()
        animation.fromValue = NSNumber(floatLiteral: Double(self._percentFilled / 100))
        animation.toValue = NSNumber(floatLiteral: Double( percent / 100))
        animation.duration = 0.2;
        animation.keyPath = "strokeEnd";
        animation.isRemovedOnCompletion = false;
        animation.fillMode = .forwards;
        self._circleStrokeLoadingLayer?.add(animation, forKey: nil)
        
        _percentFilled = percent;
    }
    
    
    /// convert degree to radian
    ///
    /// - Parameter degree: degree
    /// - Returns: calculated radian
    private func degreeToRadian(degree : CGFloat)->CGFloat{
        return degree * .pi / 180;
    }
}

extension Loady {
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

extension Loady {
    private func createFourPhaseButton(){
        guard let nextPhase = _fourPhasesNextPhase, let fourPhase = fourPhases  else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0);
            self.layoutIfNeeded()
        }
        UIView.beginAnimations("changeTextTransition", context: nil)
        let animation = CATransition()
        animation.isRemovedOnCompletion = true
        animation.duration = 0.2
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        self.titleLabel!.layer.add(animation, forKey:"changeTextTransition")
        
        switch nextPhase {
        case .normal(let name, let image , let background):
            self.setTitle(name , for: .normal)
            self.backgroundColor = background
            self._fourPhasesNextPhase  = fourPhase.loading
            setupImagesInFourPhases(image)
            
            break
        case .loading(let name, let image, let background):
            self.setTitle(name , for: .normal)
            self.backgroundColor = background
            self._fourPhasesNextPhase  = nil
            let circle = setupImagesInFourPhases(image,shrinkContainerLayer: true)
            createCircularLoading(bounds: circle.bounds, center : circle.position)
            break
        case .success(let name, let image, let background):
            self.setTitle(name , for: .normal)
            self.backgroundColor = background
            self._fourPhasesNextPhase  = fourPhase.normal
            setupImagesInFourPhases(image)
            cleanCircularLoading()
            break
        case .error(let name, let image, let background):
            self.setTitle(name , for: .normal)
            self.backgroundColor = background
            self._fourPhasesNextPhase  = fourPhase.normal
            setupImagesInFourPhases(image)
            cleanCircularLoading()
            break
        }
        UIView.commitAnimations()
        
    }
    func normalPhase(){
        guard let fourPhase = fourPhases  else {
            return
        }
        self._fourPhasesNextPhase = fourPhase.normal
        createFourPhaseButton()
        cleanCircularLoading()
    }
    func successPhase(){
        guard let fourPhase = fourPhases  else {
            return
        }
        self._fourPhasesNextPhase = fourPhase.success
        createFourPhaseButton()
    }
    func errorPhase(){
        guard let fourPhase = fourPhases  else {
            return
        }
        self._fourPhasesNextPhase = fourPhase.error
        createFourPhaseButton()
    }
    @discardableResult private func setupImagesInFourPhases(_ image : UIImage? , shrinkContainerLayer : Bool = false)->CAShapeLayer{
        if let imageLayer = self.layer.sublayers?.first(where: { $0.accessibilityHint == LayerTempKeys.tempLayer}) {
            let animation = CATransition()
            animation.isRemovedOnCompletion = true
            animation.duration = 0.2
            animation.type = CATransitionType.push
            animation.subtype = CATransitionSubtype.fromTop
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            imageLayer.sublayers?[0].add(animation, forKey:"changeImageTransition")
            imageLayer.sublayers?[0].contents = image?.cgImage
            imageLayer.sublayers?[0].contentsScale = UIScreen.main.scale
            if shrinkContainerLayer {
                imageLayer.transform =  CATransform3DMakeScale(0.7, 0.7, 1);
            }else{
                imageLayer.transform =  CATransform3DMakeScale(1, 1, 1);
            }
            return imageLayer as! CAShapeLayer
        }else{
            let radius = self.bounds.height / 3
            let circleContainer = createACircleInsideButton(radius: radius)
            circleContainer.fillColor = UIColor.white.cgColor
            circleContainer.position.x = radius * 2
            let imageLayer = CAShapeLayer()
            imageLayer.bounds = CGRect(x:0,y: 0,width: radius,height: radius);
            imageLayer.position = CGPoint(x:circleContainer.bounds.midY,y: circleContainer.bounds.midY);
            imageLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
            imageLayer.contents = image?.cgImage
            imageLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            circleContainer.accessibilityHint = LayerTempKeys.tempLayer
            circleContainer.addSublayer(imageLayer)
            
            self.layer.addSublayer(circleContainer)
            
            return circleContainer
        }
    }
    
    private func cleanCircularLoading(){
        if let loading = self.layer.sublayers?.first(where: { $0.accessibilityHint == LayerTempKeys.circularLoading}) {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            loading.add(animation, forKey: "fade")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                loading.removeFromSuperlayer()
            }
        }
    }
    private func createCircularLoading(bounds : CGRect, center : CGPoint){
        cleanCircularLoading()
        let circularLoadingLayer = CAShapeLayer()
        circularLoadingLayer.fillColor = UIColor.clear.cgColor
        circularLoadingLayer.strokeColor = UIColor.black.cgColor
        circularLoadingLayer.lineWidth = 3
        circularLoadingLayer.bounds = bounds.insetBy(dx: -5, dy: -5)
        //circularLoadingLayer.bounds.size = CGSize(width: 30, height: 30)
        circularLoadingLayer.path = UIBezierPath(ovalIn: circularLoadingLayer.bounds).cgPath
        circularLoadingLayer.position = center
        circularLoadingLayer.anchorPoint = CGPoint(x:0.5,y: 0.5);
        circularLoadingLayer.accessibilityHint = LayerTempKeys.circularLoading
        self.layer.addSublayer(circularLoadingLayer)
        startCircluarLoadingAnimation(circularLoadingLayer)
    }
    
    private struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    private class var poses: [Pose] {
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
    
    private func startCircluarLoadingAnimation(_ layer : CAShapeLayer) {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(layer,keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(layer,keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        animateStrokeHueWithDuration(layer ,duration: totalSeconds * 5)
    }
    
    private func animateKeyPath(_ layer  : CAShapeLayer,keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = .linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    private func animateStrokeHueWithDuration(_ layer  : CAShapeLayer, duration: CFTimeInterval) {
        let count = 200
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        let loadingColor = self.loadingColor
        animation.values = (0 ... count).map {num in
            if num <= 3  && animation.accessibilityHint == nil{
               return loadingColor.withAlphaComponent(CGFloat(num) / 3.0).cgColor
            }else{
              return  loadingColor.cgColor
          }
        }
        animation.duration = duration
        animation.calculationMode = .linear
        animation.autoreverses = true
        
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}
