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

  s.frameworks = 'CFNetwork', 'CoreGraphics', 'CoreTelephony', 'MobileCoreServices', 'Security','SystemConfiguration'
  s.libraries = 'c++', 'sqlite3', 'z'

  s.dependency 'AFNetworking'
  s.dependency 'AKWeChatSDK'

  #静态库传递详细资料查看这里 http://luoxianming.cn/2016/03/27/CocoaPods/
  #静态库传递要求Podfile中添加以下代码
  #pre_install do |installer|
    #workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    #def installer.verify_no_static_framework_transitive_dependencies; end
  #end

  #为什么需要-ObjC参数？
  #苹果官方Q&A上有这么一段话：
  #The "selector not recognized" runtime exception occurs due to an issue between the implementation of standard UNIX static libraries, the linker and the dynamic nature of Objective-C. Objective-C does not define linker symbols for each function (or method, in Objective-C) - instead, linker symbols are only generated for each class. If you extend a pre-existing class with categories, the linker does not know to associate the object code of the core class implementation and the category implementation. This prevents objects created in the resulting application from responding to a selector that is defined in the category.
  #翻译:运行时的异常时由于静态库,链接器,与OC语言的动态的特性之间的问题,OC语言并不是对每一个函数或者方法建立符号表,而只是对每一个类创建了符号表.如果一个类有了分类,那么链接器就不会将核心类与分类之间的代码完成进行合并,这就阻止了在最终的应用程序中的可执行文件缺失了分类中的代码,这样函数调用接失败了.

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC -l"WeChatSDK"',
    'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/AKWeChatSDK/**'
  }
end
