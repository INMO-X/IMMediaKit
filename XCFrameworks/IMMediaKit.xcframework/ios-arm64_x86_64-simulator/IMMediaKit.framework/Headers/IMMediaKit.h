//
//  IMMediaKit.h
//  IMMediaKit
//
//  Umbrella header — required for `DEFINES_MODULE = YES` 和二进制分发的 Module Map。
//  Swift 实现的公开 API 通过 `@objc public` / `public` 自动桥接到 module；
//  Obj-C 调用方 `#import <IMMediaKit/IMMediaKit.h>` 即可使用。
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double IMMediaKitVersionNumber;
FOUNDATION_EXPORT const unsigned char IMMediaKitVersionString[];

// 本 SDK 的所有对外接口都用 Swift 实现，无需在此处暴露 .h 文件。
