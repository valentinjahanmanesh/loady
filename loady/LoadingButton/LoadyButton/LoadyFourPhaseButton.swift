//
//  LoadyFourPhaseButton.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
class LoadyFourPhaseButton: Loady {
	private var animation: LoadyFourPhaseAnimation? = nil
	open func setPhases(phases: LoadyAnimationOptions.FourPhases){
		animation = LoadyFourPhaseAnimation(loady: self, phases: phases)
	}
	open override func startLoading() {
		if self.loadingIsShowing(){
			return;
		}
		currentAnimation = animation
		currentAnimation?.run()
	}
	open func normalPhase(){
		(currentAnimation as? LoadyFourPhaseAnimation)?.normalPhase()
	}
	open func successPhase(){
		(currentAnimation as? LoadyFourPhaseAnimation)?.successPhase()
	}
	open func errorPhase(){
		(currentAnimation as? LoadyFourPhaseAnimation)?.errorPhase()
	}
}
