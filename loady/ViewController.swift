//
//  ViewController.swift
//  loady
//
//  Created by farshad jahanmanesh on 2/2/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tempTimer1 : Timer?
    var tempTimer2 : Timer?
    var tempTimer3 : Timer?
    var tempTimer : Timer?
    @IBOutlet weak var circleView : Loady?
    @IBOutlet weak var allInOneview : Loady?
    @IBOutlet weak var uberLikeView : Loady?
    @IBOutlet weak var fillingView : Loady?
    @IBOutlet weak var indicatorViewLike : Loady?
    @IBOutlet weak var appstore : Loady?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start and stop animating on user touch
        self.circleView?.addTarget(self, action: #selector(animateView(_:)), for: .touchUpInside)
        self.allInOneview?.addTarget(self, action:#selector(animateView(_:)), for:.touchUpInside)
        self.uberLikeView?.addTarget(self, action:#selector(animateView(_:)), for:.touchUpInside)
        self.fillingView?.addTarget(self, action:#selector(animateView(_:)), for:.touchUpInside)
        self.indicatorViewLike?.addTarget(self, action:#selector(animateView(_:)), for:.touchUpInside)
        self.appstore?.addTarget(self, action:#selector(animateView(_:)), for:.touchUpInside)
        self.appstore?.pauseImage = #imageLiteral(resourceName: "pause-button")
    }
    
    @IBAction func animateView(_ sender : UIButton){
        // check for nil
        guard let button = sender as? Loady else {
            return
        }
        
        // start animating based on button animation style type
        button.startLoading(loadingType: LoadingType(rawValue: button.setAnimationType) ?? .none)
        var percent : CGFloat = 0
        switch button.animationType {
        case .backgroundHighlighter:
            self.tempTimer1?.invalidate()
            self.tempTimer1 = nil
            self.tempTimer1 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                percent += 10;
                button.fillTheButton(with: percent)
                button.fillTheCircleStrokeLoadingWith(percent: percent)
            }
            self.tempTimer1?.fire()
        case .circleAndTick:
            self.tempTimer2?.invalidate()
            self.tempTimer2 = nil
            self.tempTimer2 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                percent += 10;
                button.fillTheCircleStrokeLoadingWith(percent: percent)
            }
            self.tempTimer2?.fire()
        case .appstore:
            self.tempTimer3?.invalidate()
            self.tempTimer3 = nil
            self.tempTimer3 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                percent += 10;
                button.fillTheCircleStrokeLoadingWith(percent: percent)
            }
            self.tempTimer3?.fire()
        case .all:
            self.tempTimer?.invalidate()
            self.tempTimer = nil
            self.tempTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){(t) in
                percent += 10;
                button.fillTheButton(with: percent)
                button.fillTheCircleStrokeLoadingWith(percent: percent)
            }
            self.tempTimer?.fire()
        default:
            break;
        }
    }
    
    
}

