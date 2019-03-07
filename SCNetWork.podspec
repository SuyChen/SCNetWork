#
#  Be sure to run `pod spec lint SCNetWork.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SCNetWork"
  s.version      = "0.0.1"
  s.summary      = "基于AFN3.2.1网络请求封装，实现网络请求，上传，下载功能。基于YYCache，实现数据缓存。"
  s.homepage     = "https://github.com/SuyChen/SCNetWork"
  s.license      = "MIT"
  s.author             = { "SuyChen" => "286092964@qq.com" }
  # s.social_media_url   = "https://github.com/SuyChen/SCNetWork"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/SuyChen/SCNetWork.git", :tag => "#{s.version}" }
  s.source_files  = "SCNetWork", "SCNetWork/SCNetworkHelper/*.{h,m}"
  s.public_header_files = "SCNetWork/**/*.h"
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 3.2.1'
  s.dependency 'YYCache', '~> 1.0.4'

end
