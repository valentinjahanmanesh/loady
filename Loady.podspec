Pod::Spec.new do |s|

  # 1
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = "loady"
  s.module_name = "Loady"
  s.summary = "fully customizable loading button with 8 different styles."
  s.requires_arc = true
  
  # 2
  s.version = "1.0.6"
  
  # 3
  s.license = { :type => "MIT", :file => "LICENSE" }
  
  # 4 - Replace with your name and e-mail address
  s.author = { "farshad jahanmanesh" => "farshadjahanmanesh@gmail.com" }
  
  # 5 - Replace this URL with your own GitHub page's URL (from the address bar)
  s.homepage = "https://github.com/farshadjahanmanesh/loady"
  
  # 6 - Replace this URL with your own Git URL from "Quick Setup"
  s.source = { :git => "https://github.com/farshadjahanmanesh/loady.git", 
               :tag => "#{s.version}" }
  
  # 7
  s.framework = "UIKit"
  
  # 8
  s.source_files = "Loady/Classes/**/*"
  
  # 9
  #s.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  
  # 10
  s.swift_version = "5.0"
  
  end
