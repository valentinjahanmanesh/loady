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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(box)
        box.backgroundColor = .green
        box.snp.makeConstraints { make in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.center.equalTo(self.view)
        }
        
        let button = LoadingableButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        box.addSubview(button)
        let animation = BackgroundFillingAnimator()
        button.set(delegate: animation)
        button.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(70)
            make.center.equalTo(box).priority(.high)
        }
        button.clipsToBounds = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.startLoading()
            var progress: Float16 = 0
            Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    progress += (0...10).map({Float16($0 / 10)}).randomElement()!
                    animation.set(progress: .init(rawValue: progress / 10))
                }
                .store(in: &self.cancellables)
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
