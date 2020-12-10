//
//  WWKEasyTableItem.h
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/24.
//  Copyright © 2019 wyman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define WWKEasyDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

typedef SEL WWKEasyItemSEL; // 固定的方法签名： - (void)funcName:(WWKEasyTableItem *)item

typedef NS_ENUM(NSUInteger, WWKEasyTableHover) {
    EasyTableHoverNone = 0,
    EasyTableHoverTop,
//    EasyTableHoverBottom, 暂不支持
};

typedef NS_OPTIONS(NSUInteger, WWKEasyTableUpdateType) {
    WWKEasyTableUpdateTypeContent = 1 << 1,         // 刷新内容，不会更新高度，调用configCellBlock
    WWKEasyTableUpdateTypeHeight  = 1 << 2,         // 刷新高度，键盘不会下去，调用configHeightBlock
    WWKEasyTableUpdateTypeHeightAnimated  = 1 << 3, // 刷新高度带动画，键盘不会下去，键盘不会下去，调用configHeightBlock
    // 刷新内容并且刷新高度 configCellBlock和configHeightBlock都会调用
    WWKEasyTableUpdateTypeAnimated = WWKEasyTableUpdateTypeContent | WWKEasyTableUpdateTypeHeightAnimated,
    WWKEasyTableUpdateTypeDefault = WWKEasyTableUpdateTypeContent | WWKEasyTableUpdateTypeHeight,
};


@class WWKEasyTableItem;
typedef void(^WWKEasyTableConfigCellBlock)(__kindof UITableViewCell *cell, __kindof WWKEasyTableItem *item);
typedef CGFloat(^WWKEasyTableConfigHeightBlock)(__kindof WWKEasyTableItem *item);

@interface WWKEasyTableItem<T : NSObject *> : NSObject

/** 上下文对象 */
@property (nonatomic, strong) T contextData;

/** cell的类型 */
@property (nonatomic, strong) Class cellClass;

/** 设置cell,显示的时候会触发 -> willDisplayCell */
@property (nonatomic, copy) WWKEasyTableConfigCellBlock configCellBlock;

@property (nonatomic, copy) void(^cellClickAction)(__kindof WWKEasyTableItem *cellItem);

/** 设置cell高度（如果cellHeight==0，则会计算） -> heightForRowAtIndexPath */
@property (nonatomic, copy) WWKEasyTableConfigHeightBlock configHeightBlock;

/** 自动计算cell高度
    会自动尝试从以下方式去拿到高度
    configHeightBlock -> cell.sizeThatFit: -> autoLayout
 */
@property (nonatomic, assign) BOOL autoCalculateHeight;

/** cell高度, 改变后需要updateCell 或者 reloadCell生效 */
@property (nonatomic, assign) CGFloat cellHeight;

/** 是否关闭cell复用，关闭后identify会被设为唯一值，默认是NO，【注意：此时item会强持有cell】 */
@property (nonatomic, assign, getter = isDisableCellReused) BOOL disableCellReused;

/** 是否关闭高度缓存，关闭后会在多次调用configHeightBlock，默认是NO */
@property (nonatomic, assign, getter = isDisableCellHeightCache) BOOL disableCellHeightCache;

/** 隐藏，数据源还在只是高度变小了看不到，无视cellHeight, 改变后需要updateCell 或者 reloadCell生效 【支持WWKEasyTableGroupItem】*/
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

/** cell的点击事件 - (void)funcName:(WWKEasyTableItem *)item */
@property (nonatomic, assign) WWKEasyItemSEL didSelectRowSelector;

/** 当前tableView */
@property (nonatomic, weak, nullable) UITableView *tableView;

/** 当前item的id，用在-(void)getEasyTableItemsWithfilterID:如果不唯一则会查询返回多个【支持WWKEasyTableGroupItem】 */
@property (nonatomic, copy, nullable) NSString *filterID;

/** cornerStyle, 如果没有设置，将按照group风格计算返回 */
@property (nonatomic, assign) UIRectCorner cornerStyle;

/** 按照group风格计算返回 */
@property (nonatomic, assign, readonly) BOOL shouldShowSeparator;

/** 禁止从重用池获取cell来计算高度 */
@property (nonatomic, assign) BOOL disableDequeueCellForCaculateHeight;

/** 当前绑定的cell
    不建议拿这个视图直接操作更新，因为重用机制，滚动的时候还是会去configCellBlock，这样直接操作cell的逻辑可能会被configCellBlock覆盖，所以这业务逻辑还得在configCellBlock写一遍。
    【建议写法：cell的所有配置逻辑在configCellBlock，业务改变数据源然后updateCell或者reloadCell，也可以直接reloadData】
 eg:
 item.configCellBlock = ^(__kindof UITableViewCell * _Nonnull cell, __kindof WWKEasyTableItem * _Nonnull item) {
    if (item.YourLogic) {
        cell.textLabel.text = @"文案1"；
    } else {
        cell.textLabel.text = @"文案2"；
    }
 };

 - (void)otherFunc {
    // 1.改变数据源
    item.YourLogic = YourLogic;
    // 2.刷新这个cell，触发 item.configCellBlock
    [item updateCell:WWKEasyTableUpdateTypeDefault];
 }
 */
@property (nonatomic, weak, nullable) UITableViewCell *cell;

/** 对应的数据源index */
@property (nonatomic, strong, nullable) NSIndexPath *indexPath;

/** 是否在当前是否屏幕可见（滚出来没有） */
@property (nonatomic, assign, readonly, getter=isVisible) BOOL isVisible;

/** cell悬停 */
@property (nonatomic, assign) WWKEasyTableHover hover;

/** 触发reloadRowsAtIndexPaths【支持WWKEasyTableGroupItem】 */
- (void)reloadCell:(UITableViewRowAnimation)animation;

/** cell刷新，和reloadCell相比比较轻量级，并且键盘不会下去，textView高度的变化适合这个【支持WWKEasyTableGroupItem】 */
- (void)updateCell:(WWKEasyTableUpdateType)updateType;

@end

//// 关闭重并且自动计算高度
@interface WWKEasyTableAutoCalAndNotReusedItem : WWKEasyTableItem

@end

@interface WWKEasyTableGroupItem : WWKEasyTableItem

- (void)addItems:(NSArray<WWKEasyTableItem *>*)items;
- (void)addItem:(WWKEasyTableItem *)item;
- (void)removeItem:(WWKEasyTableItem *)item;
- (void)removeItems:(NSArray<WWKEasyTableItem *>*)items;
- (NSArray<WWKEasyTableItem *> *)getItems;

@end

//// 空白item
@interface WWKEasyTableBlankItem : WWKEasyTableItem

+ (instancetype)itemWithHeight:(CGFloat)cellHeight;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL fixedSpace;
@end

//// 文本item
@class WWKEasyTableTextCell, WWKEasyTableTextItem;

@interface WWKEasyTableTextCell : UITableViewCell

@property (nonatomic, strong) UILabel *textLbl;

@property (nonatomic, weak) WWKEasyTableTextItem *textItem;

@end

@interface WWKEasyTableTextItem : WWKEasyTableItem

/** 文本 */
@property (nonatomic, copy) NSString *text;
/** 行间距 */
@property (nonatomic, assign) CGFloat lineHeight;
/** 内边距*/
@property (nonatomic, assign) UIEdgeInsets contentInset;
/** 背景色，默认白色 */
@property (nonatomic, strong) UIColor *backgroundColor;

@end

//// 分割线cell
#define WWKEasySeperate(left, right)  ([WWKEasyTableSeperateItem itemWithLeftOffset:left rightOffset:right])
@interface WWKEasyTableSeperateCell : UITableViewCell
@property (nonatomic, strong) UIView *seperateView;
@property (nonatomic, assign) CGFloat leftOffset;
@property (nonatomic, assign) CGFloat rightOffset;
@property (nonatomic, assign) CGFloat seperatorViewHeight;
@end

@interface WWKEasyTableSeperateItem : WWKEasyTableItem

+ (instancetype)itemWithLeftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset;

/** 左边距 */
@property (nonatomic, assign) CGFloat leftOffset;
/** 右边距 */
@property (nonatomic, assign) CGFloat rightOffset;
/** 背景色，默认白色 */
@property (nonatomic, strong) UIColor *backgroundColor;
/** 分割线颜色，默认灰色 */
@property (nonatomic, strong) UIColor *seperateColor;

@end

////  图片
@interface WWKEasyTableImageCell : UITableViewCell
@property (nonatomic, strong) UIImageView *imgView;
@end
@class WWKEasyTableImageItem;
typedef void(^WWKEasyTableImageConfigCellBlock)(__kindof WWKEasyTableImageCell *cell, __kindof WWKEasyTableImageItem *item);
@interface WWKEasyTableImageItem : WWKEasyTableItem

+ (instancetype)itemWithSize:(CGSize)size cellConfig:(WWKEasyTableImageConfigCellBlock)cellConfig;

/** size */
@property (nonatomic, assign) CGSize imgSize;

@end

/////////////////////////////////////// 废弃属性/方法

@interface WWKEasyTableItem(Deprecated)

/** 当前控制器 */
@property (nonatomic, weak) NSObject *eventObserver WWKEasyDeprecated("此属性作废");

/** 是否关闭cell复用，默认是NO */
@property (nonatomic, assign, getter = isCloseReused) BOOL closeReused WWKEasyDeprecated("已过期，请使用 disableCellReused");

/** 是否关闭cellCache，默认是NO */
@property (nonatomic, assign, getter = isCloseCellCache) BOOL closeCellCache WWKEasyDeprecated("已过期，请使用 disableCellHeightCache");

/** 触发configCellBlock */
- (void)updateCell WWKEasyDeprecated("此方法作废， 请使用 - (void)updateCell:");

/** 触发tableview刷新高度并且不隐藏键盘 */
- (void)layoutCell WWKEasyDeprecated("此方法作废， 请使用 - (void)updateCell:");
- (void)layoutCellAnimated WWKEasyDeprecated("此方法作废， 请使用 - (void)updateCell:");

@end

#define WWKEasyText(_text)  ({\
WWKEasyTableTextItem *_text_easy_item = [WWKEasyTableTextItem itemWithCellConfig:^(__kindof WWKEasyTableTextCell * _Nonnull cell, __kindof WWKEasyTableTextItem * _Nonnull item) { \
    cell.textLbl.text = _text; \
}]; \
_text_easy_item;\
})
typedef void(^WWKEasyTableTextConfigCellBlock)(__kindof WWKEasyTableTextCell *cell, __kindof WWKEasyTableTextItem *item);
@interface WWKEasyTableTextItem()

+ (instancetype)itemWithCellConfig:(WWKEasyTableTextConfigCellBlock)cellConfig WWKEasyDeprecated("此方法作废， 请使用 configCellBlock");

+ (instancetype)itemWithLeftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset lineHeight:(CGFloat)lineHeight cellConfig:(WWKEasyTableTextConfigCellBlock)cellConfig WWKEasyDeprecated("此方法作废， 请使用 contentInset 和 configCellBlock");

@property (nonatomic, assign) CGFloat leftOffset WWKEasyDeprecated("此方法作废， 请使用 contentInset");

@property (nonatomic, assign) CGFloat rightOffset WWKEasyDeprecated("此方法作废， 请使用 contentInset");

@end

//// 空白cell
#define WWKEasyBlank(height)  ([WWKEasyTableBlankItem itemWithHeight:height])
#define WWKEasyBlankColor(height, color)  ({\
WWKEasyTableBlankItem *_blank_item_ = [WWKEasyTableBlankItem itemWithHeight:height];\
_blank_item_.backgroundColor = color;\
_blank_item_;\
})


NS_ASSUME_NONNULL_END
