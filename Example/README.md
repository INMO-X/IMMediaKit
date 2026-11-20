# IMMediaKit Example

可运行 Demo，依赖公开仓 tag `0.1.2` 的 `IMMediaKit/Editing` 静态库。

```bash
cd Example
pod install
open IMMediaKit.xcworkspace
```

选择 scheme **IMMediaKit_Example**。右上角「导入」生成一张图片写进沙盒，列表按日期分组并异步加载缩略图；点一条打开图片编辑器，保存后作为新记录写回。首行检查 `IMMediaKitEditing.bundle` 是否已拷进 App。

只需要本地媒体管理时，把 Podfile 里的 `IMMediaKit/Editing` 换成 `IMMediaKit`，并去掉 ViewController 里的 `IMImageEditor` 调用。

本地未推送 tag 时，把 Podfile 里的 `:git` 行换成注释中的 `:path`。
