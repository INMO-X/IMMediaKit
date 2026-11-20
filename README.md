# IMMediaKit

INMO 本地媒体管理 SDK 的 **静态 XCFramework**：图片 / 视频沙盒存储、元数据、分页查询、日期分组、视频封面、下采样加载、双层缓存、事件订阅。无 UI、纯本地。

---

## 环境要求

- iOS 15.0+
- Swift 5
- Xcode 15+
- CocoaPods，并开启 `use_frameworks!`

## 安装：二选一

| 子规格 | 内容 | 额外依赖 |
|--------|------|----------|
| `IMMediaKit`（默认 = `IMMediaKit/Core`） | 本地媒体管理 + 设备同步落盘 | 无 |
| `IMMediaKit/Editing` | 上面全部 + 图片编辑 | ZLImageEditor 3.0.0（不打进包） |

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  pod 'IMMediaKit', :git => 'https://github.com/INMO-X/IMMediaKit.git', :tag => '0.1.2'
  # 需要图片编辑时换成：
  # pod 'IMMediaKit/Editing', :git => 'https://github.com/INMO-X/IMMediaKit.git', :tag => '0.1.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
```

**只能写一行。** 两个子规格是同一个 Swift module `IMMediaKit` 的两份二进制，同时引入会重复符号。

Editing 的编辑器图标在 **`IMMediaKitEditing.bundle`**，隐私清单在 **`IMMediaKit.bundle`**，不要重命名。

## 隐私

媒体只存在 App 沙盒，SDK 不联网。详见 [docs/PRIVACY.md](docs/PRIVACY.md)。

## 示例

[Example/](Example/) 用 tag `0.1.2` 的 `IMMediaKit/Editing`：生成一张图片导入沙盒、按日期分组列出、加载缩略图，并打开图片编辑器。

```bash
cd Example
pod install
open IMMediaKit.xcworkspace
```

## 文档

| 文档 | 说明 |
|------|------|
| [docs/USAGE.md](docs/USAGE.md) | 场景用法 |
| [docs/PRIVACY.md](docs/PRIVACY.md) | 隐私清单与宿主配置 |
