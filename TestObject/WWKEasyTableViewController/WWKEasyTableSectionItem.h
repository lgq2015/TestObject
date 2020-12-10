//
//  WWKEasyTableSectionItem.h
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/28.
//  Copyright © 2019 wyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWKEasyTableItem.h"
#import "WWKEasyTable.h"

NS_ASSUME_NONNULL_BEGIN

@class WWKEasyTableSectionItem;
typedef void(^WWKEasyTableConfigSectionBlock)(__kindof UIView *view, WWKEasyTableSectionItem *item);
typedef CGFloat(^WWKEasyTableConfigSectionHeightBlock)(WWKEasyTableSectionItem *item);

@interface WWKEasyTableSectionItem<T : NSObject *> : NSObject

/** 自定义类型 */
@property (nonatomic, strong) T contextData;
/** cell数据源 */
@property (nonatomic, strong) NSMutableArray<WWKEasyTableItem *> *cellDataSource;
/** section号-显示后赋值 */
@property (nonatomic, assign) NSInteger section;

/** 组头视图 */
@property (nonatomic, strong) UIView *headerView;
/** 组头高度 */
@property (nonatomic, assign) CGFloat headerHeight;
/** 组头显示时触发 */
@property (nonatomic, copy) WWKEasyTableConfigSectionBlock configHeaderViewBlock;
/** 组头高度计算 */
@property (nonatomic, copy) WWKEasyTableConfigSectionHeightBlock configHeaderHeightBlock;

/** 组尾视图 */
@property (nonatomic, strong) UIView *footerView;
/** 组尾高度 */
@property (nonatomic, assign) CGFloat footerHeight;
/** 组尾 */
@property (nonatomic, copy) WWKEasyTableConfigSectionBlock configFooterViewBlock;
/** 组尾高度计算 */
@property (nonatomic, copy) WWKEasyTableConfigSectionHeightBlock configFooterHeightBlock;

@end

NS_ASSUME_NONNULL_END
