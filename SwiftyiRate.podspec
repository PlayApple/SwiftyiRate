Pod::Spec.new do |s|
  s.name         = "SwiftyiRate"
  s.version      = "1.0.1"
  s.summary      = "SwiftyiRate makes it easy to deal with rate app in Swift"
  s.homepage     = "https://github.com/PlayApple/SwiftyiRate"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "LiuYanghui" => "cocos2der@gmail.com" }
  
  s.requires_arc = true

  #  When using multiple platforms
  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/PlayApple/SwiftyiRate.git", :tag => s.version }
  s.source_files  = "SwiftyiRate/*.swift"
  s.resources = "SwiftyiRate/SwiftyiRate.bundle"
end
