<img src="https://raw.githubusercontent.com/farshadjahanmanesh/loady/master/loady/examples/logo.png" width="100%" style="text-align:center">

[![Version](https://img.shields.io/cocoapods/v/Whisper.svg?style=flat)](http://cocoadocs.org/docsets/Whisper)
[![License](https://img.shields.io/cocoapods/l/Whisper.svg?style=flat)](http://cocoadocs.org/docsets/Whisper)
[![Platform](https://img.shields.io/cocoapods/p/Whisper.svg?style=flat)](http://cocoadocs.org/docsets/Whisper)
![Swift](https://img.shields.io/badge/%20in-swift%204.4-orange.svg)


# Loady
this is a small library to show loading and indicator in UIButton, with fully customizable styles. there are 6 different  styles, you can set the colors from interface builder or programmatically.


## Todo
- [x] animation style : like appstore download button
- [ ] animation style : like telegram sharing
- [ ] animation style : like android

![TOP_LINE](https://raw.githubusercontent.com/farshadjahanmanesh/loady/master/loady/examples/_gif.gif)


## Installation, cocoapods
just add this line into your podfile
```swift
  pod 'loady'
```
or simply copy the source codes into your project, take a look at the example project for more info

## Configs
<img src="https://raw.githubusercontent.com/farshadjahanmanesh/loady/master/loady/examples/_specs.jpeg" width="50%" style="text-align:center">

## Setup programmatically :
```swift

       // sets animation type
        self.allInOneviewButton?.setAnimationType = LoadingType.all.rawValue
        
        // sets the color that fills the button after percent value changed
        self.allInOneviewButton?.setFilledBackgroundColor = .purple
        
        // sets the indicator color above the button
        self.allInOneviewButton?.setLoadingColor = .yellowpercent

        // sets the indictore view color (dark or light) inside the button
        self.allInOneviewButton?.setIndicatorViewDarkStyle = false
        
        // some animations have image inside (e.g appstore pause image), this line sets that image
        self.allInOneviewButton?.pauseImage = UIImage(named: "pause.png")
        
        // starts loading animation
        self.allInOneviewButton?.startLoading()
        
        // some animations have filling background, this sets the filling percent, number is something between 0 to 100
        self.allInOneviewButton?.fillTheButton(with: 10)
        
        // some animations have circular loading , this sets the percents of circle that are completed, number is something between 0 to 100
        self.allInOneviewButton?.fillTheCircleStrokeLoadingWith(percent: 25 )
```
## Set class and change attributes
<img src="https://raw.githubusercontent.com/farshadjahanmanesh/loady/master/loady/examples/_setClass.png" width="50%" style="text-align:center">
<img src="https://raw.githubusercontent.com/farshadjahanmanesh/loady/master/loady/examples/_properties.png" width="50%" style="text-align:center">
