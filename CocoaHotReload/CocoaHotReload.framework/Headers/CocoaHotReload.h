//
//  CocoaHotReload.h
//  CocoaHotReload-iOS
//
//  Created by mambaxie on 2020/3/11.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "CocoaHotReloadDefine.h"

#if COCOA_HOT_RELOAD_ENABLE

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CocoaHotReload : NSObject

+ (void)run;

// 当前版本
+ (NSString *)currentVersion;

@end

NS_ASSUME_NONNULL_END

#endif
