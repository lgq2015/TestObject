//
//  KSTemplateTableViewCell.h
//  gifMerchantModule
//
//  Created by fengchiwei on 2020/11/16.
//  Copyright © 2020年 tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "KSTemplateListItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSTemplateTableViewCell : UITableViewCell

@property(nullable, nonatomic, weak) id delegate;

- (void)updateWithData:(KSTemplateListItem *)item;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
