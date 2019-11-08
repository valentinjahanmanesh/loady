//
//  Loadible.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
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
