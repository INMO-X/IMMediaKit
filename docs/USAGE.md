# IMMediaKit 使用说明

本地媒体管理 SDK：沙盒内图片 / 视频存储、元数据、分页查询、按日期分组、视频封面、下采样加载、双层缓存、事件订阅。无 UI、纯本地，不联网。

## 安装：二选一

| 子规格 | 内容 | 额外依赖 |
|--------|------|----------|
| `IMMediaKit`（默认 = `IMMediaKit/Core`） | 本地媒体管理 + 设备同步落盘（`IMLocalImageStore`） | 无 |
| `IMMediaKit/Editing` | 上面全部 + 图片编辑（涂鸦 / 裁剪 / 马赛克 / 文字 / 贴纸 / 滤镜 / 调节） | ZLImageEditor 3.0.0 |

两个子规格是同一个 Swift module `IMMediaKit` 的两份二进制，**Podfile 里只能写一行**：

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static   # dynamic 也可以

target 'YourApp' do
  pod 'IMMediaKit', :git => 'https://github.com/INMO-X/IMMediaKit.git', :tag => '0.1.2'
  # 需要图片编辑时换成这一行（不要两行同时写）：
  # pod 'IMMediaKit/Editing', :git => 'https://github.com/INMO-X/IMMediaKit.git', :tag => '0.1.2'
end
```

同时写 `IMMediaKit` 和 `IMMediaKit/Editing` 会链接两份同名 module，出现重复符号。

```swift
import IMMediaKit
```

## 1. 启动与绑定用户

```swift
try? IMMediaSDK.shared.start(configuration: .default)   // AppDelegate
IMMediaSDK.shared.configure(userID: currentUserID)       // 登录 / 切换账号后
```

## 2. 增删查

```swift
IMMediaSDK.shared.importFile(at: pickedURL) { result in ... }
IMMediaSDK.shared.importImage(uiImage) { result in ... }
IMMediaSDK.shared.importBatch(urls: urls, progress: { done, total in ... }) { result in ... }

IMMediaSDK.shared.delete(id: item.id) { _ in }
IMMediaSDK.shared.deleteBatch(ids: ids) { _ in }

let page1 = IMMediaSDK.shared.fetch(query: IMMediaQuery(limit: 50))
let groups = IMMediaSDK.shared.fetchGrouped(query: .allFirstPage)   // 今天 / 昨天 / 本周 / 本月 / 更早
```

## 3. 加载图片

```swift
private var token: IMImageRequestToken?

func bind(_ item: IMMediaItem) {
    let req = IMImageRequest(item: item, targetSize: imageView.bounds.size, priority: .normal)
    token = IMMediaSDK.shared.loadImage(req) { [weak self] image in
        self?.imageView.image = image
    }
}

override func prepareForReuse() {
    super.prepareForReuse()
    token?.cancel()
}
```

## 4. 订阅事件

事件强制在主队列派发。

```swift
let sub = IMMediaSDK.shared.events.sink { event in
    switch event {
    case .inserted(let item):       refresh(adding: item)
    case .batchInserted(let items): refresh(addingMany: items)
    case .updated(let item):        refresh(updating: item)
    case .deleted(let id):          refresh(removing: id)
    case .batchDeleted(let ids):    refresh(removingMany: ids)
    case .storeReloaded:            reloadAll()
    }
}

let token = IMMediaSDK.shared.subscribe { event in ... }   // token.invalidate() 取消
```

## 5. 设备同步落盘

```swift
let store = try IMLocalImageStore(userID: currentUserID)   // 按「用户 + 设备」分桶
let url = try store.saveOriginal(data: data, fileName: name, deviceID: deviceID, kind: .photo)   // .photo / .video / .audio
let thumbs = store.listThumbnails(deviceID: deviceID)
store.clearDevice(deviceID)
```

## 6. 图片编辑（仅 `IMMediaKit/Editing`）

```swift
IMImageEditor.shared.configureFilterLocalization { key, zh in
    NSLocalizedString(key, value: zh, comment: "")
}

IMImageEditor.shared.present(image: image, from: self, persist: true) { result in
    guard let result else { return }        // nil = 用户取消
    imageView.image = result.editedImage
    _ = result.savedItem                    // persist: true 时写回 sandbox 的新记录
}
```

编辑器 Tab 图标在 **`IMMediaKitEditing.bundle`**，由 CocoaPods 拷进 App，不要重命名；找不到时回退为 SF Symbol。

宿主若使用 IQKeyboardManager，把 `IMImageEditor.keyboardAvoidanceExemptViewControllerTypes` 登记进它的 `disabledDistanceHandlingClasses` / `disabledTouchResignedClasses` / `disabledToolbarClasses`。

## 注意事项

- 二进制是 Release 构建：内部 `os_log` 调试日志和 `IMMediaLogger.sink` 回调只在源码 DEBUG 构建里生效。
- 所有数据只在本机沙盒。`IMMediaSDK.shared.reset(completion:)` 清空全部元数据和文件，通常在退出登录后调用。
