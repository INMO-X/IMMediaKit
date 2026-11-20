#
# Binary pod for the static XCFrameworks produced by Scripts/build_xcframeworks.sh.
#
# Customer Podfile fail-safe (CocoaPods cannot enforce):
#   Use `IMMediaKit` (= Core) OR `IMMediaKit/Editing` — never both. Both
#   subspecs vendor the same Swift module IMMediaKit → duplicate symbols.
#
Pod::Spec.new do |s|
  s.name             = 'IMMediaKit'
  s.version          = '0.1.2'
  s.summary          = 'INMO X local media management SDK (static XCFramework)'
  s.description      = <<-DESC
  INMO X 本地媒体管理 SDK 静态二进制：图片 / 视频沙盒存储、元数据、分页查询、日期分组、
  视频封面、下采样加载、双层缓存、事件订阅。
  子规格二选一：Core（默认，含设备同步落盘）或 Editing（Core + 图片编辑，依赖 ZLImageEditor）。
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jiangqi' => 'jiangqi@inmolens.com' }
  s.homepage         = 'https://github.com/INMO-X/IMMediaKit'
  s.source           = { :git => 'https://github.com/INMO-X/IMMediaKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  s.static_framework = true

  s.default_subspecs = 'Core'

  # 本地媒体管理 + 设备同步落盘（IMLocalImageStore）。无第三方依赖。
  s.subspec 'Core' do |ss|
    ss.vendored_frameworks = 'XCFrameworks/IMMediaKit.xcframework'
    ss.frameworks = 'Foundation', 'UIKit', 'ImageIO', 'AVFoundation', 'CoreImage', 'CoreServices', 'CryptoKit', 'Combine'
    ss.resource_bundles = {
      'IMMediaKit' => ['IMMediaKit/Resources/PrivacyInfo.xcprivacy']
    }
  end

  # Core 全部 + 图片编辑。不要与 Core 同时引入。
  # 编辑器图标在 IMMediaKitEditing.bundle，运行时按这个名字查找，不能改名。
  s.subspec 'Editing' do |ss|
    ss.vendored_frameworks = 'XCFrameworks/variants/Editing/IMMediaKit.xcframework'
    ss.frameworks = 'Foundation', 'UIKit', 'ImageIO', 'AVFoundation', 'CoreImage', 'CoreServices', 'CryptoKit', 'Combine'
    ss.resource_bundles = {
      'IMMediaKit'        => ['IMMediaKit/Resources/PrivacyInfo.xcprivacy'],
      'IMMediaKitEditing' => ['IMMediaKit/Resources/Editing/*.xcassets']
    }
    ss.dependency 'ZLImageEditor', '3.0.0'
  end
end
