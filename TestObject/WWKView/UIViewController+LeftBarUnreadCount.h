//
//  UIViewController+UnreadCount.h
//  wework
//
//  Created by maxcwfeng on 2020/7/7.
//  Copyright © 2020 rdgz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (WWKLeftBarUnreadCount)

@property(nonatomic, assign) NSUInteger wwk_leftBarUnreadCount;

@property(nonatomic, readonly, strong) UIBarButtonItem *wwk_leftBarUnreadCountItem;

@end

NS_ASSUME_NONNULL_END
