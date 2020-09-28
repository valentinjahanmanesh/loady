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
    private var oldTitleEdgeInsets: UIEdgeInsets = .zero
    private var oldImageEdgeInsets: UIEdgeInsets = .zero
    public func run() {
        loading = true
        let indicator = self.activiyIndicator
        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if let button = self.loady as? UIButton, let titleLabel = button.titleLabel {
            self.oldTitleEdgeInsets = button.titleEdgeInsets
            self.oldImageEdgeInsets = button.imageEdgeInsets
            
            let rightLeftInset: (right:CGFloat,left: CGFloat) = self.loady.semanticContentAttribute == .forceRightToLeft ? (0,30) : (30,0)
            
            UIView.animate(withDuration: 0.3) {
                button.titleEdgeInsets = UIEdgeInsets(top: button.titleEdgeInsets.top, left: rightLeftInset.left + button.titleEdgeInsets.left, bottom: button.titleEdgeInsets.bottom, right: rightLeftInset.right + button.titleEdgeInsets.right);
                button.imageEdgeInsets = UIEdgeInsets(top: button.imageEdgeInsets.top, left: rightLeftInset.left + button.imageEdgeInsets.left, bottom: button.imageEdgeInsets.bottom, right: rightLeftInset.right + button.imageEdgeInsets.right);
                self.loady.layoutIfNeeded()
            }
            
            if let imageView = button.imageView, (imageView.frame.minX < 8 || imageView.frame.maxX > button.frame.width - 8) {
                button.imageView?.removeFromSuperview()
            }
            
            if titleLabel.frame.minX < 8 || titleLabel.frame.maxX > button.frame.size.width - 8 {
                button.imageView?.removeFromSuperview()
            }
            
            if titleLabel.superview == nil , button.imageView?.superview == nil {
                indicator.center = CGPoint(x: self.loady.bounds.midX,y: self.loady.bounds.midY)
            } else if button.frame.width < button.intrinsicContentSize.width + 38 {
                titleLabel.removeFromSuperview()
                button.imageView?.removeFromSuperview()
                indicator.center = CGPoint(x: self.loady.bounds.midX,y: self.loady.bounds.midY)
            } else {
                indicator.center = CGPoint(x: (rightLeftInset.left == 0 ?  titleLabel.frame.maxX + 15 :  titleLabel.frame.minX - 15) ,y: self.loady.bounds.midY)
            }
            
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
        self.loady?.insertSubview(indicator, at: 0)
        UIView.animate(withDuration: 0.05, delay: 0.3, options: .curveLinear, animations: {
            indicator.transform  = .identity
            self.loady?.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    public func stop() {
        loading = false
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                self.activiyIndicator.transform = .init(scaleX: 0.1, y: 0.1)
                self.activiyIndicator.alpha = 1
                self.loady.layoutIfNeeded()
            }
            if let button = self.loady as? UIButton {
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                    button.titleEdgeInsets = self.oldTitleEdgeInsets
                    button.imageEdgeInsets = self.oldImageEdgeInsets
                    button.titleLabel?.alpha = 1
                    self.loady.layoutIfNeeded()
                }
            }
        }) {[weak self] (done) in
            self?.activiyIndicator.removeFromSuperview()
            guard let loady = self?.loady, let button = loady as? UIButton else {return}
            if let titleLabel = button.titleLabel, titleLabel.superview == nil {
                titleLabel.isHidden = true
                button.addSubview(titleLabel)
            }
            
            if let imageView = button.imageView, imageView.superview == nil {
                imageView.isHidden = true
                button.addSubview(imageView)
            }
        }
    }
}
