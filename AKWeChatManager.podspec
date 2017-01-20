#
# Be sure to run `pod lib lint AKWeChatManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKWeChatManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AKWeChatManager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/AKWeChatManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Freud' => 'lixiangyujiayou@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/AKWeChatManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AKWeChatManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AKWeChatManager' => ['AKWeChatManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'AFNetworking'

  s.dependency 'AKWeChatSDK'

  #静态库传递详细资料查看这里 http://luoxianming.cn/2016/03/27/CocoaPods/
  #静态库传递要求Podfile中添加以下代码
  #pre_install do |installer|
    #workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    #def installer.verify_no_static_framework_transitive_dependencies; end
  #end

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup',
    'ENABLE_BITCODE' => 'NO'
  }
end