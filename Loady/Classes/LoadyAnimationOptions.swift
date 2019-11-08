//
//  LoadyAnimationOptions.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/5/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit
/// a structure for creating four phases button
public struct LoadyAnimationOptions {
    public struct FourPhases {
		public typealias Phase = (title:String,image : UIImage?,background:UIColor)
        public enum Phases {
            case normal(Phase)
            case loading(Phase)
            case success(Phase)
            case error(Phase)
        }
		let normalPhase: Phase
		let loadingPhase: Phase
		let successPhase: Phase
		let errorPhase: Phase
		public init(normalPhase: Phase, loadingPhase: Phase, successPhase: Phase, errorPhase: Phase) {
			self.normalPhase = normalPhase
			self.loadingPhase = loadingPhase
			self.successPhase = successPhase
			self.errorPhase = errorPhase
		}
    }
    public struct Downloading {
        var downloadingLabel : (title:String,font : UIFont, textColor : UIColor)?
        var percentageLabel: (font : UIFont, textColor : UIColor)?
        var downloadedLabel : (title:String,font : UIFont, textColor : UIColor)?
        init(downloadingLabel : (title:String,font : UIFont, textColor : UIColor)?,percentageLabel: (font : UIFont, textColor : UIColor)?,downloadedLabel : (title:String,font : UIFont, textColor : UIColor)?) {
            self.downloadingLabel = downloadingLabel
            self.percentageLabel = percentageLabel
            self.downloadedLabel = downloadedLabel
        }
    }
    
    var downloading : Downloading?
}
