//
//  LoadyButton.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
class LoadyButton: Loady {
	func setAnimation(_ animation: LoadyAnimation) {
		self.animationType = type(of: animation).animationTypeKey
		animation.inject(loady: self)
		self.currentAnimation = animation
	}
}

