//
//  CyToolDefine.h
//  CyLibs
//
//  Created by clyde on 12-11-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#ifndef CyLibs_CyToolDefine_h_2013_135935
#define CyLibs_CyToolDefine_h_2013_135935

// Debug Logging
#if 1 // Set to 1 to enable debug logging
#define CYLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define CYLog(x, ...)
#endif

// screen size
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// check is iphone5
#define isIphone5 (kScreenHeight == 568.0f)


// 颜色值
// rgb
#define kCyColorFromRGBA(r, g, b, a) [UIColor colorWithRed:((r) / 255.0f) green:((g) / 255.0f) blue:((b) / 255.0f) alpha:(a)]

#define kCyColorFromRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0f) green:((g) / 255.0f) blue:((b) / 255.0f) alpha:(1.0f)]

// 从16进制得到颜色值 0x222222
#define kCyColorFromHexA(hex, a) [UIColor colorWithRed:(((hex & 0xff0000) >> 16) / 255.0f) green:(((hex & 0x00ff00) >> 8) / 255.0f) blue:((hex & 0x0000ff) / 255.0f) alpha:(a)]
#define kCyColorFromHex(hex) [UIColor colorWithRed:(((hex & 0xff0000) >> 16) / 255.0f) green:(((hex & 0x00ff00) >> 8) / 255.0f) blue:((hex & 0x0000ff) / 255.0f) alpha:(1.0f)]
#define kRemoveSaveObject(key) \
[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize]

#pragma mark - UserDefaults
#define kUserDefaults [NSUserDefaults standardUserDefaults]
// 从 [NSUserDefaults standardUserDefaults] 中获取数据
#define kGetObjectFromUserDefaults(key) [kUserDefaults objectForKey:key]
// 保存 obj 到 [NSUserDefaults standardUserDefaults] 中
#define kSaveObjectToUserDefaults(key, object) {\
[kUserDefaults setObject:object forKey:key]; \
[kUserDefaults synchronize]; }
// 从 [NSUserDefaults standardUserDefaults] 中移除数据
#define kRemoveObjectAtUserDefaults(key) {\
[kUserDefaults removeObjectForKey:key];\
[kUserDefaults synchronize]; }

// 本地存储信息
#define kGetUserSystemObject(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define kSaveUserSystemObject(key, value) \
[[NSUserDefaults standardUserDefaults] setObject:value forKey:key]; \
[[NSUserDefaults standardUserDefaults] synchronize]

#define kGetCustomObject(key, value) \
NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:key]; \
if(serialized){ \
value = [NSKeyedUnarchiver unarchiveObjectWithData:serialized];\
}\
else{ \
value = nil; \
}

#define kSaveCustomObject(key, value)  do{\
NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:value];\
if(serialized){ \
[[NSUserDefaults standardUserDefaults] setObject:serialized forKey:key]; \
[[NSUserDefaults standardUserDefaults] synchronize]; \
}\
}\
while(0)
#endif
