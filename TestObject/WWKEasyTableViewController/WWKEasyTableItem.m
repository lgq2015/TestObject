//
//  WWKEasyTableItem.m
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/24.
//  Copyright © 2019 wyman. All rights reserved.
//

#import "WWKEasyTableItem.h"
#import "WWKEasyTable.h"

@interface WWKEasyTableItem()

/** 当前控制器 */
@property (nonatomic, weak) NSObject *eventObserver;
/** 是否关闭cell复用，默认是NO */
@property (nonatomic, assign, getter = isCloseReused) BOOL closeReused;
/** 是否关闭cellCache，默认是NO */
@property (nonatomic, assign, getter = isCloseCellCache) BOOL closeCellCache;
/** 临时的cell */
@property (nonatomic, strong) UITableViewCell *tmpCell;

/** 防止递归 */
@property (nonatomic, assign) BOOL cellUpdating;

/** 当禁止重用时，应该强持有这个cell */
@property (nonatomic, strong) UITableViewCell *strongRefCellWhenDisableReuse;

/** 计算时tblview的宽度 */
@property (nonatomic, assign) CGFloat easy_lastTblWidth;
@end

@implementation WWKEasyTableItem


- (void)updateCell:(WWKEasyTableUpdateType)updateType {
    if (self.cellUpdating) return;
    self.cellUpdating = YES;
    if (updateType & WWKEasyTableUpdateTypeContent) {
        if (self.configCellBlock) {
            self.configCellBlock(self.cell, self);
        }
        // 因为改变颜色需要强制渲染，但是在didSelectCell 有animate的模式，会导致又被渲染回去，实际上apple需要在displayCell进行处理。所以需要触发reloadCell
        [self.cell setNeedsFocusUpdate];
        [self.cell updateFocusIfNeeded];
    }
    if (updateType & WWKEasyTableUpdateTypeHeight) {
        if (self.configHeightBlock) {
           self.cellHeight = self.configHeightBlock(self);
        }
        if (self.autoCalculateHeight) {
            self.cellHeight = 0;
        }
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
        });
    } else if (updateType & WWKEasyTableUpdateTypeHeightAnimated) {
        if (self.configHeightBlock) {
            self.cellHeight = self.configHeightBlock(self);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 因为有动画所以延时时间更久
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
            });
        });
    }
    self.cellUpdating = NO;
}

- (void)reloadCell:(UITableViewRowAnimation)animation {
    if (![self isIsVisible] || !self.indexPath) return;
    // 因为有高度缓存，所以reload的时候尝试刷新高度
    if (self.cellUpdating) return;
    self.cellUpdating = YES;
    if (self.configCellBlock && self.cell) {
        self.configCellBlock(self.cell, self);
        if (self.configHeightBlock) {
           self.cellHeight = self.configHeightBlock(self);
        }
    }
    if (self.autoCalculateHeight) {
        self.cellHeight = 0;
    }
    if (animation == UITableViewRowAnimationNone) {
        [UIView performWithoutAnimation:^{
            [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
        }];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
    }
    self.cellUpdating = NO;
}


- (BOOL)isIsVisible {
    return [self.tableView.visibleCells containsObject:self.cell];
}

- (UITableViewCell *)cell {
    if (!_cell) {
        return self.tmpCell;
    }
    return _cell;
}

- (void)setCellHeight:(CGFloat)cellHeight {
    _cellHeight = cellHeight;
}

- (void)setHidden:(BOOL)hidden {
    _hidden = hidden;
}

-(UIRectCorner)cornerStyle {
    if (!self.indexPath) {
        return 0;
    }
    if (_cornerStyle > 0) {
        return _cornerStyle;
    }
    
    QMUITableViewCellPosition postion = [self.tableView qmui_positionForRowAtIndexPath:self.indexPath];
    UIRectCorner cornerStyle = 0;
    
    if (postion == QMUITableViewCellPositionSingleInSection) {
        cornerStyle = UIRectCornerAllCorners;
    }else if (postion == QMUITableViewCellPositionLastInSection){
        cornerStyle = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }else if (postion == QMUITableViewCellPositionFirstInSection){
        cornerStyle = UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    
    return cornerStyle;
}

-(BOOL)shouldShowSeparator {
    QMUITableViewCellPosition postion = [self.tableView qmui_positionForRowAtIndexPath:self.indexPath];
    if (postion == QMUITableViewCellPositionSingleInSection || postion == QMUITableViewCellPositionLastInSection) {
        return NO;
    } else {
        return YES;
    }
}

@end

@interface WWKEasyTableGroupItem()

@property (nonatomic, strong) NSMutableArray *itemArrM;

@end

@implementation WWKEasyTableGroupItem

- (instancetype)init {
    if (self = [super init]) {
        self.itemArrM = [NSMutableArray array];
    }
    return self;
}

- (void)addItems:(NSArray<WWKEasyTableItem *>*)items {
    if (items.count) {
        [self.itemArrM addObjectsFromArray:items];
    }
}

- (void)addItem:(WWKEasyTableItem *)item {
    if (item) {
        [self.itemArrM addObject:item];
    }
}

- (void)removeItem:(WWKEasyTableItem *)item {
    if (item) {
        [self.itemArrM removeObject:item];
    }
}

- (void)removeItems:(NSArray<WWKEasyTableItem *>*)items {
    if (items.count) {
        [self.itemArrM removeObjectsInArray:items];
    }
}

- (NSArray<WWKEasyTableItem *> *)getItems {
    // 递归取出所有item
    NSMutableArray *allItem = [NSMutableArray array];
    for (WWKEasyTableItem *item in self.itemArrM) {
        if ([item isKindOfClass:[WWKEasyTableGroupItem class]]) {
            WWKEasyTableGroupItem *subGroupItem = (WWKEasyTableGroupItem *)item;
            [allItem addObjectsFromArray:[subGroupItem getItems]];
        } else {
            [allItem addObject:item];
        }
    }
    return [allItem copy];
}

// 支持组操作
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    for (WWKEasyTableItem *item in self.itemArrM) {
        item.hidden = hidden;
    }
}

- (void)setFilterID:(NSString *)filterID {
    [super setFilterID:filterID];
    for (WWKEasyTableItem *item in self.itemArrM) {
        item.filterID = filterID;
    }
}

- (void)reloadCell:(UITableViewRowAnimation)animation {
    if (self.cellUpdating) return;
    self.cellUpdating = YES;
    NSMutableArray *indexPathArr = [NSMutableArray array];
    for (WWKEasyTableItem *item in self.itemArrM) {
        if (![item isIsVisible] || !item.indexPath) continue;
        if (item.configCellBlock && item.cell) {
            item.configCellBlock(item.cell, item);
            if (item.configHeightBlock) {
               item.cellHeight = item.configHeightBlock(item);
            }
        }
        if (item.autoCalculateHeight) {
            item.cellHeight = 0;
        }
        if (item.indexPath) {
            [indexPathArr addObject:item.indexPath];
        }
    }

    for (WWKEasyTableItem *item in self.itemArrM) {
        if (![item isIsVisible] || !item.indexPath) continue;
        if (item.configCellBlock && item.cell) {
            item.configCellBlock(item.cell, item);
            if (item.configHeightBlock) {
               item.cellHeight = item.configHeightBlock(item);
            }
        }
        if (item.autoCalculateHeight) {
            item.cellHeight = 0;
        }
        if (item.indexPath) {
            [indexPathArr addObject:item.indexPath];
        }
    }
    if (animation == UITableViewRowAnimationNone) {
        [UIView performWithoutAnimation:^{
            [self.tableView reloadRowsAtIndexPaths:indexPathArr withRowAnimation:animation];
        }];
    } else {
        [self.tableView reloadRowsAtIndexPaths:indexPathArr withRowAnimation:animation];
    }
    self.cellUpdating = NO;
}

- (void)updateCell:(WWKEasyTableUpdateType)updateType {
    if (self.cellUpdating) return;
    self.cellUpdating = YES;
    for (WWKEasyTableItem *item in self.itemArrM) {
        if (updateType & WWKEasyTableUpdateTypeContent) {
            if (item.configCellBlock) {
                item.configCellBlock(item.cell, item);
            }
            // 因为改变颜色需要强制渲染，但是在didSelectCell 有animate的模式，会导致又被渲染回去，实际上apple需要在displayCell进行处理。所以需要触发reloadCell
            [item.cell setNeedsFocusUpdate];
            [item.cell updateFocusIfNeeded];
        }
        if (updateType & WWKEasyTableUpdateTypeHeight) {
            if (item.configHeightBlock) {
               item.cellHeight = item.configHeightBlock(item);
            }
            if (item.autoCalculateHeight) {
                item.cellHeight = 0;
            }
        } else if (updateType & WWKEasyTableUpdateTypeHeightAnimated) {
            if (item.configHeightBlock) {
                item.cellHeight = item.configHeightBlock(item);
            }
        }
    }
    // 刷新
    if (updateType & WWKEasyTableUpdateTypeHeight) {
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
        });
    } else if (updateType & WWKEasyTableUpdateTypeHeightAnimated) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 因为有动画所以延时时间更久
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
            });
        });
    }
    self.cellUpdating = NO;
}
@end

@implementation WWKEasyTableBlankItem

- (instancetype)init {
    if (self= [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setFixedSpace:(BOOL)fixedSpace {
    _fixedSpace = fixedSpace;
    if (_fixedSpace) { // 这个时候需要通知easyTableView 计算高度，调整自己的高度
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemFixedSpace" object:self];
    }
}

+ (instancetype)itemWithHeight:(CGFloat)cellHeight {
    WWKEasyTableBlankItem *blankItem = [WWKEasyTableBlankItem new];
    blankItem.cellHeight = cellHeight;
    blankItem.cellClass = UITableViewCell.class;
    blankItem.configCellBlock = ^(__kindof UITableViewCell * _Nonnull cell, __kindof WWKEasyTableBlankItem * _Nonnull item) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = item.backgroundColor;
    };
    return blankItem;
}

@end

@implementation WWKEasyTableSeperateCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.seperateView = [UIView new];
    self.seperatorViewHeight = 0.f;
    [self.contentView addSubview:self.seperateView];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat spH = self.seperatorViewHeight > 0 ? self.seperatorViewHeight : self.contentView.bounds.size.height;
    CGFloat vMargin = (self.contentView.bounds.size.height - spH)/2.f;
    self.seperateView.frame = CGRectMake(self.leftOffset, vMargin, self.contentView.bounds.size.width-self.rightOffset-self.leftOffset, spH);
}
@end

@interface WWKEasyTableTextCell()

@end

@implementation WWKEasyTableTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLbl = [UILabel new];
    self.textLbl.font = [UIFont systemFontOfSize:13.f];
    self.textLbl.numberOfLines = 0.0;
    self.textLbl.textColor = [UIColor qmui_colorWithHexString:@"#888888"];
    [self.contentView addSubview:self.textLbl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (UIEdgeInsetsEqualToEdgeInsets(self.textItem.contentInset, UIEdgeInsetsZero)) {
        CGFloat textW = size.width - self.textItem.leftOffset - self.textItem.rightOffset;
        CGFloat textH = 0;
        if (self.textLbl.attributedText) {
           textH = [self.textLbl.attributedText easy_attributeStringGetHeightWithMaxWidth:textW];
        } else {
           textH = [self.textLbl.text easy_getHeightWithMaxWidth:textW font:self.textLbl.font];
        }
        if (self.textItem) {
            self.textLbl.frame = CGRectMake(self.textItem.leftOffset, 0, textW, textH);
        }

        return CGSizeMake(size.width, textH);
    } else {
        CGFloat textW = size.width - self.textItem.contentInset.left - self.textItem.contentInset.right;
        CGFloat textH = 0;
        if (self.textLbl.attributedText) {
           textH = [self.textLbl.attributedText easy_attributeStringGetHeightWithMaxWidth:textW];
        } else {
           textH = [self.textLbl.text easy_getHeightWithMaxWidth:textW font:self.textLbl.font];
        }
        if (self.textItem) {
            self.textLbl.frame = CGRectMake(self.textItem.contentInset.left, self.textItem.contentInset.top, textW, textH);
        }
        
        return CGSizeMake(size.width, self.textItem.contentInset.top+textH+self.textItem.contentInset.bottom);
    }
}

@end

@implementation WWKEasyTableSeperateItem : WWKEasyTableItem

+ (instancetype)itemWithLeftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset {
    WWKEasyTableSeperateItem *seperateItem = [WWKEasyTableSeperateItem new];
    seperateItem.cellHeight = (1 / [[UIScreen mainScreen] scale]);
    seperateItem.cellClass = WWKEasyTableSeperateCell.class;
    seperateItem.leftOffset = leftOffset;
    seperateItem.rightOffset = rightOffset;
    seperateItem.backgroundColor = [UIColor whiteColor];
    seperateItem.seperateColor = [UIColor qmui_colorWithHexString:@"#D5D5D5"];
    seperateItem.configCellBlock = ^(__kindof WWKEasyTableSeperateCell * _Nonnull cell, __kindof WWKEasyTableSeperateItem * _Nonnull item) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = item.backgroundColor;
        cell.leftOffset = item.leftOffset;
        cell.rightOffset = item.rightOffset;
        cell.seperateView.backgroundColor = item.seperateColor;
    };
    return seperateItem;
}

@end

@implementation WWKEasyTableAutoCalAndNotReusedItem

- (instancetype)init {
    if (self = [super init]) {
        self.autoCalculateHeight = YES;
        self.disableCellReused = YES;
    }
    return self;
}

@end

@implementation WWKEasyTableTextItem : WWKEasyTableItem

- (instancetype)init {
    if (self = [super init]) {
        self.cellClass = WWKEasyTableTextCell.class;
        self.autoCalculateHeight = YES;
    }
    return self;
}

+ (instancetype)itemWithCellConfig:(WWKEasyTableTextConfigCellBlock)cellConfig {
    return [WWKEasyTableTextItem itemWithLeftOffset:12 rightOffset:12 lineHeight:18 cellConfig:cellConfig];
}

+ (instancetype)itemWithLeftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset lineHeight:(CGFloat)lineHeight cellConfig:(WWKEasyTableTextConfigCellBlock)cellConfig {
    WWKEasyTableTextItem *textItem = [WWKEasyTableTextItem new];
    textItem.cellClass = WWKEasyTableTextCell.class;
    textItem.leftOffset = leftOffset;
    textItem.rightOffset = rightOffset;
    textItem.lineHeight = lineHeight;
    textItem.autoCalculateHeight = YES;
    textItem.configCellBlock = ^(__kindof WWKEasyTableTextCell * _Nonnull cell, __kindof WWKEasyTableTextItem * _Nonnull item) {
        cell.textItem = item;
        cell.textLbl.text = item.text;
        if (cellConfig) {
            cellConfig(cell, item);
        }
        if (item.lineHeight) {
            if (cell.textLbl.attributedText) { // 其实应该拷贝一下只修改lineHeight
                
            } else { // 重新设置富文本
                
            }
            // 设置富文本
            cell.textLbl.attributedText = [cell.textLbl.text easy_attributeStringFont:cell.textLbl.font textColor:cell.textLbl.textColor lineHeight:cell.textItem.lineHeight lineSpacing:0 wordSpacing:0 underlineStyle:NSUnderlineStyleNone alignment:cell.textLbl.textAlignment];
        }
    };
    return textItem;
}


@end

////  图片
@interface WWKEasyTableImageCell ()
@property (nonatomic, assign) CGSize si;
@end

@implementation  WWKEasyTableImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.imgView = [UIImageView new];
    [self.contentView addSubview:self.imgView];
}

- (CGFloat)p_layoutUI:(CGFloat)width {
    CGFloat imgw = self.si.width;
    CGFloat imgh = self.si.height;
    if (imgw == CGFLOAT_MAX) {
        imgw = width;
    }
    if (imgh == CGFLOAT_MAX) {
        imgh = [self.imgView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    }
    self.imgView.frame  = CGRectMake((width-imgw)*0.5, 0, imgw, imgh);
    return imgh;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_layoutUI:self.bounds.size.width];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, [self p_layoutUI:size.width]);
}

@end

@implementation WWKEasyTableImageItem : WWKEasyTableItem

+ (instancetype)itemWithSize:(CGSize)size cellConfig:(WWKEasyTableImageConfigCellBlock)cellConfig {
    WWKEasyTableImageItem *item = [WWKEasyTableImageItem new];
    item.imgSize = size;
    item.cellClass = WWKEasyTableImageCell.class;
    item.cellHeight = size.height;
    item.autoCalculateHeight = YES;
    item.configCellBlock = ^(__kindof WWKEasyTableImageCell * _Nonnull cell, __kindof WWKEasyTableImageItem * _Nonnull ii) {
        cell.si = size;
        if (cellConfig) {
            cellConfig(cell, ii);
        }
        cell.si = ii.imgSize;
    };
    return item;
}


@end

/////////////////////////////////////// 废弃属性/方法

@implementation WWKEasyTableItem(Deprecated)

- (void)updateCell {
    if (self.configCellBlock) {
        self.configCellBlock(self.cell, self);
    }
    // 因为改变颜色需要强制渲染，但是在didSelectCell 有animate的模式，会导致又被渲染回去，实际上apple需要在displayCell进行处理。所以需要触发reloadCell
    [self.cell setNeedsFocusUpdate];
    [self.cell updateFocusIfNeeded];
}


- (void)layoutCell {
    [UIView performWithoutAnimation:^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
    });
}

- (void)layoutCellAnimated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 因为有动画所以延时时间更久
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WWKEasyTableItemLayout" object:self.tableView];
        });
    });
}


@end
