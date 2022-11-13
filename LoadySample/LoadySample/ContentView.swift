//
//  ContentView.swift
//  LoadySample
//
//  Created by Farshad Jahanmanesh on 10/11/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        MainViewControllerRepresntable()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import UIKit
import SnapKit
import Loady
final class MainViewController: UIViewController {
    private lazy var box =  UIView()
    private var cancellables: [AnyCancellable] = []
    let timer = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
        .receive(on: DispatchQueue.main)
        .share()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(box)
        box.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top)
            make.left.equalTo(self.view.snp.left)
            make.height.equalTo(self.view.frame.height)
            make.center.equalTo(self.view)
        }
        
        let offsetForLeftOrRight: CGFloat = 16
        let offsetForCenter: CGFloat = 16
        let offsetForTop: CGFloat = 16
        let buttonDefaultSize = CGSize(width: self.view.frame.width / 2 - offsetForLeftOrRight - (offsetForCenter / 2), height: 50)
        
        let backgroundFillingButton = createBackgroundFillingButton()
        bind(button: backgroundFillingButton, size: buttonDefaultSize, to: box, leftOffset: offsetForLeftOrRight, topOffset: 0)
        
        let rightButtonOffset = buttonDefaultSize.width + offsetForLeftOrRight + offsetForCenter
        let topLineButton = createTopLineButton()
        bind(button: topLineButton, size: buttonDefaultSize, to: box, leftOffset: rightButtonOffset, topOffset: 0)

        let activityIndicatorButton = createActivityIndicatorButton()
        bind(button: activityIndicatorButton, size: buttonDefaultSize, to: box, leftOffset: rightButtonOffset, topOffset: buttonDefaultSize.height + offsetForTop)
        
        
        var progressValue: Float16 = 0
        self.timer.sink { _ in
            guard backgroundFillingButton.isLoading else {return}
            if progressValue == 1.0 {
                progressValue = 0
            }
            progressValue += 0.1
            
            try! backgroundFillingButton.update(progress: .init(rawValue: progressValue))
        }
        .store(in: &self.cancellables)
    }
    
    private var defaultStyle: (_ button: inout LoadingableButton) -> Void = { button in
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Do Action", for: .normal)
        button.addTarget(self, action: #selector(toggleAnimation), for: .touchUpInside)
    }
    
    private func createTopLineButton() -> LoadingableButton {
        var button: LoadingableButton = TopLineLoadingableButton()
            .do(beforeLoading: { button in
                button.setTitle("Please Wait", for: .normal)
            }, loadingFinished: { button in
                button.setTitle("Do Action", for: .normal)
            })
        defaultStyle(&button)
        
        return button
    }
    
    @objc private func toggleAnimation(sender: UIButton) {
        guard let button = sender as? LoadingableButton else {return}
        if button.isLoading {
            button.stopLoading()
        } else {
            button.startLoading()
        }
    }
    
    private func createBackgroundFillingButton() -> LoadingableButton{
        var button: LoadingableButton = BackgroundFillingLoadingableButton()
            .do(beforeLoading: { button in
                button.setTitle("Please Wait", for: .normal)
            }, loadingFinished: { button in
                button.setTitle("Do Action", for: .normal)
            })
        button.clipsToBounds = true
        defaultStyle(&button)
        return button
    }
    
    private func createActivityIndicatorButton() -> LoadingableButton{
        var button: LoadingableButton = ActivityIndicatorLoadingableButton()
            .set(options: ActivityIndicatorAnimator.Configuration(indicatorPosition: .trailing))
            .do(beforeLoading: { button in
                button.setTitle("Please Wait", for: .normal)
            }, loadingFinished: { button in
                button.setTitle("Do Action", for: .normal)
            })
        
        button.clipsToBounds = true
        defaultStyle(&button)
        return button
    }
    
    private func bind(button: LoadingableButton, size buttonSize: CGSize ,to box: UIView, leftOffset: CGFloat, topOffset: CGFloat) {
        box.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(buttonSize.width)
            make.height.equalTo(buttonSize.height)
            make.topMargin
                .equalTo(box.snp_topMargin)
                .offset(topOffset)
                .priority(.high)
            
            make.leadingMargin
                .equalTo(box.snp_leadingMargin)
                .offset(leftOffset)
                .priority(.high)
        }
    }
    
    
}

struct MainViewControllerRepresntable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController
    
    func makeUIViewController(context: Context) -> MainViewController {
        let vc = MainViewController()
        // Do some configurations here if needed.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
