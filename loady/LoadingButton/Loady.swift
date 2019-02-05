//
//  Loady.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import Foundation
import UIKit

enum LoadingType : Int{
    case none
    case topLine
    case indicator
    case backgroundHighlighter
    case circleAndTick
    case all
    case appstore
}
class Loady : UIButton {
    // public settings
    @IBInspectable var setAnimationType = 0
    @IBInspectable var setLoadingColor : UIColor = UIColor.black
    @IBInspectable var setFilledBackgroundColor : UIColor = UIColor.black
    @IBInspectable var setIndicatorViewDarkStyle = false
    open var pauseImage : UIImage? 
    var animationType = LoadingType.none
    
    // private settings
    private let _tempsLayerKey = "temps"
    fileprivate var _percentFilled : CGFloat = 0
    fileprivate var _isloadingShowing = false
    fileprivate var _filledLoadingLayer : CAShapeLayer?
    fileprivate var _circleStrokeLoadingLayer : CAShapeLayer?
    fileprivate var _cacheButtonBeforeAnimation : UIButton?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.setAnimationType != 0 {
            self.animationType = LoadingType(rawValue: self.setAnimationType) ?? .none
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.animationType = .none;
        _percentFilled = 0;
        if self.setAnimationType != 0 {
            self.animationType = LoadingType(rawValue: self.setAnimationType) ?? .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _percentFilled = 0;
        self.animationType = .none;
        self.setFilledBackgroundColor = .black;
        self.setLoadingColor = .black
        if(self.setAnimationType != 0){
            self.animationType = LoadingType(rawValue: self.setAnimationType) ?? .none
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
    func startLoading(loadingType:LoadingType){
        if self.loadingIsShowing(){
            self.endAndDeleteLoading()
            return;
        }
        switch (loadingType) {
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
        default:
            break;
        }
        
        //indicates that loading is showing
        _isloadingShowing = true;
    }
    
    /**
     move the text a little left and add the loading
     */
    func createIndicatorLoading(){
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
    func createIndicatorView(){
        let indicator = UIActivityIndicatorView();
        indicator.style = self.setIndicatorViewDarkStyle ? .gray : .white;
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
    func removeIndicatorView(){
        self.viewWithTag(-11111111)?.removeFromSuperview();
    }
    
    
    ///line loading
    func createTopLineLoading(){
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
        loadingLayer.strokeColor = self.setLoadingColor.cgColor;
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
    
    
    func removeTopLineLayer(){
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
    func endAndDeleteLoading(){
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
    func createFillingLoading(){
        _percentFilled = 0;
        //a shape for filling the button
        let layer = CAShapeLayer();
        layer.backgroundColor = self.setFilledBackgroundColor.cgColor
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
    func removeFillingLayer(){
        self._filledLoadingLayer?.removeFromSuperlayer();
        _filledLoadingLayer = nil;
    }
    
    func createCircleAndTick(){
        let center = self.center
        self.copyBeforeAnyChanges()
        let radius = min(self.frame.size.width, self.frame.size.height)
        self.setTitle("", for: .normal);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.center = center;
                self.bounds = CGRect(x:self.center.x,y: self.center.y,width: radius,height: radius);
                self.layer.cornerRadius = radius / 2;
                self.transform = CGAffineTransform(scaleX: -1,y: 1);
                self.backgroundColor = self.setFilledBackgroundColor;
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if(finished){
                    self.titleLabel?.text  = ""
                    self.createCircleLoadingLayer()
                }
            })
        }
    }
    
    func createAppstore(){
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
                self.backgroundColor = self.setFilledBackgroundColor;
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
    
    func removeAppstoreLayer(){
        if animationType != .appstore{
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
    
    func removeCircleLoadingLayer(){
        if  animationType != .circleAndTick{
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
                    if let temp = layer.accessibilityHint,temp == _tempsLayerKey {
                        layer.removeFromSuperlayer()
                    }
        })
    }
    
    func createCircleLoadingLayer(radius : CGFloat? = nil,centerX : CGFloat? = nil,centerY : CGFloat? = nil){
        self._circleStrokeLoadingLayer = CAShapeLayer()
        let path = UIBezierPath()
        self._percentFilled = 0
        self._circleStrokeLoadingLayer!.bounds = CGRect(x:0,y: 0,width: self.frame.width + 5,height: self.frame.height + 5);
        self._circleStrokeLoadingLayer!.strokeColor = self.setLoadingColor.cgColor;
        self._circleStrokeLoadingLayer!.lineWidth = 3;
        self._circleStrokeLoadingLayer!.fillColor = UIColor.clear.cgColor;
        self._circleStrokeLoadingLayer!.lineCap = CAShapeLayerLineCap(rawValue: "round");
        self._circleStrokeLoadingLayer!.strokeStart = 0.0;
        self._circleStrokeLoadingLayer!.strokeEnd = 0.0;
        let center = CGPoint(x: centerX ?? self._circleStrokeLoadingLayer!.bounds.midX,y: centerY ?? self._circleStrokeLoadingLayer!.bounds.midY);
        self._circleStrokeLoadingLayer!.position = CGPoint(x:self.bounds.midX,y: self.bounds.midY) ;
        self._circleStrokeLoadingLayer!.anchorPoint = CGPoint(x:0.5,y: 0.5);
        path.addArc(withCenter: center, radius: radius ?? self.frame.width / 2 + 4, startAngle: (-.pi / 2), endAngle: (-.pi / 2) + (-2.0 * .pi), clockwise: false)
        
        self._circleStrokeLoadingLayer?.path = path.cgPath
        self._circleStrokeLoadingLayer?.accessibilityHint = "button_circle_loading_stroke_parent"
        
        self.layer.addSublayer(self._circleStrokeLoadingLayer!)
        
    }
    func createAppstoreLoadingLayer(){
        // creates the circle loading
        createCircleLoadingLayer(radius: self.frame.midX ,centerX: self.frame.maxX - self.frame.midX)
        
        let circleContainer = copyLayer(of: self._circleStrokeLoadingLayer!)
        circleContainer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        circleContainer.strokeStart = 0
        circleContainer.strokeEnd = 1
        circleContainer.opacity = 1
        circleContainer.accessibilityHint = _tempsLayerKey
        
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
    func degreeToRadian(degree : CGFloat)->CGFloat{
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
