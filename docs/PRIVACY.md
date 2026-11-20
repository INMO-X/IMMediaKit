# Privacy（IMMediaKit）

框架自带的隐私清单，以及宿主 App 仍需自己配置的部分。

## 隐私清单（`PrivacyInfo.xcprivacy`）

源码路径：`IMMediaKit/Resources/PrivacyInfo.xcprivacy`。Core 与 Editing 两个变体共用同一份。

| Key | 取值 |
|-----|------|
| `NSPrivacyTracking` | `false`。框架不做跨 App / 网站追踪。 |
| `NSPrivacyTrackingDomains` | 空。 |
| `NSPrivacyCollectedDataTypes` | 空。媒体只存在 App 沙盒，框架不联网、不上传。 |
| `NSPrivacyAccessedAPITypes` | 见下表。 |

| API | 原因码 | 代码里的用途 |
|-----|--------|----------------|
| File timestamp | `C617.1` | `IMMediaStorage`、`IMImageLoader` 通过 `FileManager.attributesOfItem` 读取 App 容器内媒体文件的大小与修改时间；`IMDiskCache` 按 `contentModificationDate` 做缩略图 LRU 淘汰；`IMLocalImageStore` 按修改时间排序同步文件。 |

## 二进制消费者拿到清单的两个位置

1. **每个 XCFramework 切片内**：`IMMediaKit.framework/PrivacyInfo.xcprivacy`。
2. **CocoaPods resource bundle** `IMMediaKit.bundle`：静态链接不会把 framework 目录嵌进 App，清单还放在资源包根目录，随 `[CP] Copy Pods Resources` 进包。

Editing 变体另有 `IMMediaKitEditing.bundle`，只放编辑器图标。

## 宿主仍需自己声明的部分

SDK 只处理宿主传入的文件 URL / `UIImage`，不直接访问相册或相机。宿主自己选图、拍照或保存到系统相册时，按需配置 `NSPhotoLibraryUsageDescription`、`NSPhotoLibraryAddUsageDescription`、`NSCameraUsageDescription`。

ZLImageEditor（Editing 变体）的隐私清单随它自己的 pod 进包。
