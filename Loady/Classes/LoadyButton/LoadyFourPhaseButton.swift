//
//  LoadyFourPhaseButton.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
open class LoadyFourPhaseButton: LoadyButton {
	private var animation: LoadyFourPhaseAnimation? = nil
	open var currentPhase: LoadyAnimationOptions.FourPhases.Phases? {
		(currentAnimation as? LoadyFourPhaseAnimation)?.currentPhase
	}
	open func setPhases(phases: LoadyAnimationOptions.FourPhases){
		animation = LoadyFourPhaseAnimation(phases: phases)
		animation?.inject(loady: self)
	}
	open override func startLoading() {
		if self.loadingIsShowing(){
			return;
		}
		currentAnimation = animation
		currentAnimation?.run()
	}
	open func loadingPhase(){
		(currentAnimation as? LoadyFourPhaseAnimation)?.loadingPhase()
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
