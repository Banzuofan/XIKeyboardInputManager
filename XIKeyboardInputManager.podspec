#
# Be sure to run `pod lib lint XIKeyboardInputManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'XIKeyboardInputManager'
    s.version          = '1.0.1'
    s.summary          = 'XIKeyboardInputManager is a usefull tool to control input view pinned on the top of the keyboard.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = '${s.summary} when use it, you only need to focus on making the specified input view as the designed UI.'
    
    s.homepage         = 'https://github.com/Banzuofan'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = 'banzuofan@hotmail.com'
    s.source           = { :git => 'https://github.com/Banzuofan/XIKeyboardInputManager.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'XIKeyboardInputManager/**/*'
    
    # s.resource_bundles = {
    #   'XIKeyboardInputManager' => ['XIKeyboardInputManager/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
