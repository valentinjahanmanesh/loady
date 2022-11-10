Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = "loady"
  s.module_name = "Loady"
  s.summary = "fully customizable loading button with 8 different styles."
  s.requires_arc = true
  s.version = "1.0.8"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "farshad jahanmanesh" => "farshadjahanmanesh@gmail.com" }
  s.homepage = "https://github.com/farshadjahanmanesh/loady"
  s.source = { :git => "https://github.com/farshadjahanmanesh/loady.git",
               :tag => "#{s.version}" }
  s.framework = "UIKit"
  s.source_files = "Loady/Classes/**/*"
  #s.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  s.swift_version = "5.0"
  
  end
