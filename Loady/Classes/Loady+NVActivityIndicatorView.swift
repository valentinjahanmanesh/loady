//
//  NVActivityIndicatorView.swift
//  loady
//
//  Created by farshad on 2/21/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//
import UIKit
public protocol LoadyActivityIndicator where Self: UIView{
    /**
     Start animating.
     */
    func startAnimating()
    
    /**
     Stop animating.
     */
	func stopAnimating()
}

extension UIActivityIndicatorView : LoadyActivityIndicator {
    // its a bug in Swift compiler? -_-
    
}
