//
//  KSTemplateViewModel.h
//  gifMerchantModule
//
//  Created by fengchiwei on 2020/11/16.
//  Copyright © 2020年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSTemplateTableModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^succ)(void);
typedef void (^fail)(BOOL isNetWorkError);

//------------------------------------------------------------------------------------
@interface KSTemplateViewModel : NSObject

@property (nonatomic, strong) NSArray *datas;

- (instancetype)initWithSucc:(succ)succ fail:(fail)fail;

- (void)refreshData;

- (void)selectItem:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
