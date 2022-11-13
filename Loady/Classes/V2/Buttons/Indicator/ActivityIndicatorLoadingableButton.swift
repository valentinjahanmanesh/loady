//
//  ActivityIndicatorLoadingableButton.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/11/2022.
//

import Foundation
import UIKit

open class ActivityIndicatorLoadingableButton: LoadingableButton {
    private var loadingView: UIView?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        super.set(delegate: ActivityIndicatorAnimator())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.set(delegate: ActivityIndicatorAnimator())
    }
    
    @discardableResult
    public func set(options: ActivityIndicatorAnimator.Configuration) -> Self {
        super.set(delegate: ActivityIndicatorAnimator(options: options))
        return self
    }
    
    override public func addSubview(forLoading view: UIView) {
        self.insertSubview(view, at: 0)
        loadingView = view
        loadingView?.alpha = 0
    }
    public override func animationDidStart() {
        super.animationDidStart()
        updateTitlePosition()
    }
    override public func animationDidStop() {
        super.animationDidStop()
        updateTitlePosition()
        
        animate (duration: 0.3, {
            self.loadingView?.alpha = 0.001
        }) { _ in
            self.loadingView?.removeFromSuperview()
        }
    }
}

fileprivate extension ActivityIndicatorLoadingableButton {
    func animate(duration: TimeInterval = 0.5,_ animation: @escaping ()->Void, _ completion: ((Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            animation()
            self.layoutIfNeeded()
        }) { completed in
            completion?(completed)
        }
    }
    
    func updateTitlePosition() {
        guard let options =  (self.animatorDelegate as? ActivityIndicatorAnimator)?.options else {
            return
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        if options.buttonLabelPosition == .move {
            guard let label = self.titleLabel else {
                self.loadingView?.center  = self.center
                return
            }
            let titleEdge = calculateTitleEdge(options: options,
                                               titleFrame: label.frame,
                                               currentTitleEdgeInsets: self.titleEdgeInsets,
                                               isLoading: self.isLoading)
            
            let indicatorCenterX = calculateIndicatorPosition(options: options,
                                                              titleFrame: label.frame,
                                                              currentIndicatorCenterX: self.loadingView?.center.x ?? 0,
                                                              isLoading: self.isLoading)
            self.loadingView?.center.x = indicatorCenterX
            animate({
                self.loadingView?.alpha = 1
                self.titleEdgeInsets = titleEdge
            })
        } else {
            animate {
                self.titleLabel?.layer.opacity = self.isLoading ? 0 : 1
            }
        }
    }
}

extension ActivityIndicatorLoadingableButton {
    public func calculateTitleEdge(options: ActivityIndicatorAnimator.Configuration,
                                   titleFrame: CGRect,
                                   currentTitleEdgeInsets: UIEdgeInsets,
                                   spaceBetweenLabelAndIndicator: CGFloat = 2,
                                   isLoading: Bool
    ) -> UIEdgeInsets {
        
        let titleLabeltotalMovement = spaceBetweenLabelAndIndicator + options.size.width
        let edgeOfTitlelabel: UIEdgeInsets
        
        if isLoading {
            if options.indicatorPosition == .leading {
                edgeOfTitlelabel = .init(top: 0, left: currentTitleEdgeInsets.left + titleLabeltotalMovement, bottom: 0, right: 0)
            } else {
                edgeOfTitlelabel = .init(top: 0, left: currentTitleEdgeInsets.left - titleLabeltotalMovement, bottom: 0, right: 0)
            }
        } else {
            edgeOfTitlelabel = .init(top: 0, left: currentTitleEdgeInsets.left + (options.indicatorPosition == .leading ? -1: 1) * titleLabeltotalMovement, bottom: 0, right: 0)
        }
        
        return edgeOfTitlelabel
    }
    
    public func calculateIndicatorPosition(options: ActivityIndicatorAnimator.Configuration,
                                           titleFrame: CGRect,
                                           currentIndicatorCenterX: CGFloat,
                                           spaceBetweenLabelAndIndicator: CGFloat = 2,
                                           isLoading: Bool) -> CGFloat {
        let indicatorCenterX: CGFloat
        if isLoading {
            if options.indicatorPosition == .leading {
                indicatorCenterX = titleFrame.origin.x
            } else {
                indicatorCenterX = titleFrame.origin.x + titleFrame.width
            }
        } else {
            indicatorCenterX = currentIndicatorCenterX
        }
        return indicatorCenterX
    }
}
