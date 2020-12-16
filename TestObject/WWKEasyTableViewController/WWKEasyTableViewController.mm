//
//  WWKEasyTableViewController.m
//  WWKEasyTableView
//
//  Created by maxcwfeng on 2020/8/24.
//  Copyright © 2020 maxcwfeng. All rights reserved.
//

#import "WWKEasyTableViewController.h"
#import "WWKEasyTableCategory.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, EasyHoverState) {
    HoverStateNone,         // 没有悬停
    HoverStateWillReplace,  // 即将有一个新的悬停
    HoverStateReplace,      // 新旧悬停交替中
    HoverStateSuspend,      // 悬停中
};

//------------------------------------------------------------
// 该分类主要用于计算高度跟不服用cell的时候保存信息
@interface WWKEasyTableItem(Privated)

@property (nonatomic, strong) UITableViewCell *tmpCell;
@property (nonatomic, strong) UITableViewCell *strongRefCellWhenDisableReuse;
@property (nonatomic, assign) CGFloat easy_lastTblWidth;

@end

//------------------------------------------------------------
@protocol WWKEasyTableViewDelegate <NSObject>

@optional
- (BOOL)shouldHandleKeyboard;
- (void)beforeReloadData;
- (void)afterReloadData;

@end

//------------------------------------------------------------
@interface WWKEasyTableView : UITableView

@property (nonatomic, weak) id<WWKEasyTableViewDelegate> privateDelegate;
@property (nonatomic, assign) BOOL disableSetContentOffset;

@end

@implementation WWKEasyTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delaysContentTouches = false;
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIControl.class]) {
        return true;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    BOOL shouldCallSuper = YES;
    if ([self.privateDelegate respondsToSelector:@selector(shouldHandleKeyboard)]) {
        shouldCallSuper = ![self.privateDelegate shouldHandleKeyboard];
    }
    if (shouldCallSuper) {
        [super scrollRectToVisible:rect animated:animated];
    }
}

- (void)reloadData {
    if ([self.privateDelegate respondsToSelector:@selector(beforeReloadData)]) {
        [self.privateDelegate beforeReloadData];
    }
    [super reloadData];
    if ([self.privateDelegate respondsToSelector:@selector(afterReloadData)]) {
        [self.privateDelegate afterReloadData];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if ( self.disableSetContentOffset ) {
        return;
    }
    [super setContentOffset:contentOffset];
}

@end

//------------------------------------------------------------
@interface WWKIgnoreMemoryWarningTableView : WWKEasyTableView

@end

@implementation WWKIgnoreMemoryWarningTableView

- (void)nop {
    ;
}

+ (void)initialize {
    Method m = class_getInstanceMethod(self, @selector(nop));
    class_addMethod(self, NSSelectorFromString(@"_purgeReuseQueues"), method_getImplementation(m), method_getTypeEncoding(m));
}
@end

//------------------------------------------------------------
@interface WWKEasyDisappearHover : NSObject

@property (nonatomic, strong) WWKEasyTableItem *hoverItem;
@property (nonatomic, strong) UITableViewCell *hoverView;

@end

@implementation WWKEasyDisappearHover
@end

//------------------------------------------------------------
@interface WWKEasyTableKeyboardInfo : NSObject

// 显示或隐藏
@property (nonatomic, assign) BOOL isShow;
// keyboard rect
@property (nonatomic, assign) CGRect keyboardFrameBegin;
@property (nonatomic, assign) CGRect keyboardFrameEnd;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) CGFloat keyboardY;
@property (nonatomic, assign) CGFloat keyboardH;
@property (nonatomic, assign) UIViewAnimationCurve curve;
@property (nonatomic, assign) UIViewAnimationOptions options;
//
@property (nonatomic, assign) CGPoint startContentOffset;
@property (nonatomic, assign) UIEdgeInsets startEdgeInset;
@property (nonatomic, assign) BOOL didChangeContentInset;

@end

@implementation WWKEasyTableKeyboardInfo

@end

//------------------------------------------------------------
@interface WWKEasyTableViewController () <UIGestureRecognizerDelegate, WWKEasyTableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *topHoverItemMap;
@property (nonatomic, strong) NSMutableArray<WWKEasyDisappearHover *> *disappearHoverCellArr;
@property (nonatomic, strong) WWKEasyTableItem *currentTopHoverItem;
@property (nonatomic, strong) UITableViewCell *currentTopHoverView;
@property (nonatomic, assign) EasyHoverState topHoverState;

@property (nonatomic, strong) WWKEasyTableKeyboardInfo *keyboardInfo;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, weak) WWKEasyTableItem *fixedSpaceItem;   //用于撑满屏幕高度时候用，平时用的不多
@property (nonatomic, assign) BOOL fixedSpaceReloading;

@end

@implementation WWKEasyTableViewController
{
    BOOL _didShowKeybord;
    BOOL _isAppear;
}

- (instancetype)init {
    if (self = [super init]) {
        self.endEditingWhenTouch = YES;
    }
    return self;
}

- (void)dealloc {
    [self _removeKeyboardNoti];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WWKEasyTableItemLayout" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WWKEasyTableItemFixedSpace" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputHandleOption = WWKEasyKeyboardHandleOptionNone;
    [self _setupUI];
    [self _addKeyboardNoti];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEditCellFrameWhenEditing) name:@"WWKEasyTableItemLayout" object:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableItemFixedSpace:) name:@"WWKEasyTableItemFixedSpace" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isAppear = NO;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

- (void)setInputHandleOption:(WWKEasyInputHandleOption)inputHandleOption {
    _inputHandleOption = inputHandleOption;
    // 更新通知
    [self _removeKeyboardNoti];
    [self _addKeyboardNoti];
}

- (BOOL)shouldHandleKeyboard {
    if (self.inputHandleOption==WWKEasyKeyboardHandleOptionNone ||
        self.inputHandleOption==WWKEasyKeyboardHandleOptionSystem) {
        return NO;
    }
    
    return YES;
}

- (void)setDisableTableEstimatedType:(BOOL)disable {
    _disableTableEstimatedType = disable;
    if (disable) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
    } else {
        self.tableView.estimatedRowHeight = 44;
        self.tableView.estimatedSectionFooterHeight = 20;
        self.tableView.estimatedSectionHeaderHeight = 20;
    }
}

- (void)_setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.disableTableEstimatedType = NO;
    
    self.tableView = [[WWKEasyTableView alloc] initWithFrame:CGRectZero style:[self tableViewStyle]];
    ((WWKEasyTableView*)self.tableView).disableSetContentOffset = self.disableTableViewSetContentOffset;
    [(WWKEasyTableView *)self.tableView setPrivateDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    tap.delegate = self;
    self.tap = tap;
    [self.tableView addGestureRecognizer:tap];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.clipsToBounds = YES;
    self.disappearHoverCellArr = [NSMutableArray array];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!self.ignoreLayoutTableView) {
        self.tableView.frame = self.view.bounds;
    }
}

- (void)beforeReloadData {
    [self.dataSource enumerateObjectsUsingBlock:^(WWKEasyTableSectionItem * _Nonnull sectionItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [sectionItem.cellDataSource enumerateObjectsUsingBlock:^(WWKEasyTableItem * _Nonnull obj, NSUInteger idx2, BOOL * _Nonnull stop2) {
            obj.indexPath = [NSIndexPath indexPathForRow:idx2 inSection:idx];
        }];
    }];
}

- (void)afterReloadData {
    // 这段逻辑是为了实现 fixedSpace 的能力
    // 1.强制布局获取高度
    // 2.计算出差的高度
    // 3.重刷一遍表单
    if (!self.fixedSpaceItem || !self.disableTableEstimatedType) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fixedSpaceReloading) {
            return;
        }
        if (!self.fixedSpaceItem.easy_params[@"p_fixedSpaceMinHeight"]) {
            [self.tableView layoutIfNeeded];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.fixedSpaceReloading)  {
                return;
            }
            CGFloat allItemHeight = 0;
            CGFloat beforeFixedSpaceItemHeight = 0;
            CGFloat afterFixedSpaceItemHeight = 0;
            BOOL itemDetected = NO;
            for (WWKEasyTableSectionItem *obj in self.dataSource) {
                allItemHeight += obj.headerHeight;
                allItemHeight += obj.footerHeight;
                if (itemDetected) {
                    afterFixedSpaceItemHeight += obj.headerHeight;
                    afterFixedSpaceItemHeight += obj.footerHeight;
                } else {
                    beforeFixedSpaceItemHeight += obj.headerHeight;
                    beforeFixedSpaceItemHeight += obj.footerHeight;
                }
                for (WWKEasyTableItem *item in obj.cellDataSource) {
                    if (item != self.fixedSpaceItem) {
                        allItemHeight += item.cellHeight;
                        if (itemDetected) {
                            afterFixedSpaceItemHeight += item.cellHeight;
                        } else {
                            beforeFixedSpaceItemHeight += item.cellHeight;
                        }
                    } else {
                        itemDetected = YES;
                    }
                }
            }
            if (!itemDetected) {
                return;
            }
            float fixedSpaceMinHeight = [self.fixedSpaceItem.easy_params[@"p_fixedSpaceMinHeight"] floatValue];
            if (!fixedSpaceMinHeight) {
                self.fixedSpaceItem.easy_params[@"p_fixedSpaceMinHeight"] = @(self.fixedSpaceItem.cellHeight);
                fixedSpaceMinHeight = self.fixedSpaceItem.cellHeight;
            }

            if ((allItemHeight + fixedSpaceMinHeight) < self.tableView.bounds.size.height) { // 调整一波
                self.fixedSpaceItem.cellHeight = self.tableView.bounds.size.height-afterFixedSpaceItemHeight-beforeFixedSpaceItemHeight;
            } else {
                if (fixedSpaceMinHeight) {
                    self.fixedSpaceItem.cellHeight = fixedSpaceMinHeight;
                }
            }
            if (self.fixedSpaceItem.cellHeight <= 0) {
                self.fixedSpaceItem.cellHeight = fixedSpaceMinHeight;
            }
            
            self.fixedSpaceReloading = YES;
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.fixedSpaceReloading = NO;
            });
        });
    });
}

- (void)_removeKeyboardNoti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)_addKeyboardNoti {
    if (WWKEasyKeyboardHandleOptionDisable ==_inputHandleOption) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(easykeyboardDidShow:)  name:UIKeyboardDidShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(easykeyboardDidHide:)  name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(easykeyboardWillShow:)  name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(easykeyboardWillHide:)  name:UIKeyboardWillHideNotification object:nil];
}

- (NSMutableArray<WWKEasyTableSectionItem *> *)dataSource {
    if (!_dataSource) {
        _dataSource = (NSMutableArray<WWKEasyTableSectionItem *> *)[NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableDictionary<NSString *, WWKEasyTableItem *> *)topHoverItemMap {
    if (!_topHoverItemMap) {
        _topHoverItemMap = (NSMutableDictionary<NSString *, WWKEasyTableItem *> *)[NSMutableDictionary dictionary];
    }
    return _topHoverItemMap;
}

- (void)handleTableItemFixedSpace:(NSNotification *)noti {
    self.fixedSpaceItem = noti.object; // 这是个需要动态调整高度的间距
}

- (UIResponder *)currentFirstResponder {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    return [keyWindow performSelector:@selector(firstResponder)];
}

- (UITableViewCell *)currentFirstResponderCell {
    UIResponder *responder = [self currentFirstResponder];
    if (![responder isKindOfClass:[UIView class]]) {
        return nil;
    }
    UIView *responderView = (UIView *)responder;
    UIView *superV = responderView;
    while (![superV isKindOfClass:[UITableViewCell class]] && superV) {
        superV = [superV superview];
    }
    if (superV == responderView) {
        superV = nil;
    }
    return (UITableViewCell *)superV;
}

- (void)handleEditCellFrameWhenEditing {
    if (![self shouldHandleKeyboard]) return;
    
    UIResponder *firstResponder = [self currentFirstResponder];
    UITableViewCell *cell = [self currentFirstResponderCell];
    if (!cell || !self.keyboardInfo) return;
    
    CGRect cellRectInView = [cell convertRect:cell.bounds toView:self.view];
    cellRectInView.size.height = cellRectInView.size.height + self.inputBottomMargin;
    
    if (self.inputHandleOption == WWKEasyKeyboardHandleOptionCursor) { // 查找光标的位置
        if ([firstResponder isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)firstResponder;
            CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
            CGRect caretRectInView = [textView convertRect:caretRect toView:self.view];
            cellRectInView.origin.y = caretRectInView.origin.y;      // 光标相对整个view的y
            cellRectInView.size.height = caretRectInView.size.height + self.inputBottomMargin;   // 光标的高度 （应该是textview的行高比较合理） + 设置的底部间距
        }
    }
    
    CGFloat margin = CGRectGetMaxY(cellRectInView) - self.keyboardInfo.keyboardY;
    if ((!self->_didShowKeybord && margin != 0) || (self->_didShowKeybord && margin>0)) {//只处理往上滚
        if ((self.tableView.contentOffset.y + margin) > 0) { //只处理往上滚
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + margin) animated:!self->_didShowKeybord];
        }
    }
}

- (void)easykeyboardWillShow:(NSNotification *)noti {
    if (!_isAppear) return;
    NSDictionary *info = [noti userInfo];
    // 构造键盘信息
    WWKEasyTableKeyboardInfo *keyboardInfo = [WWKEasyTableKeyboardInfo new];
    keyboardInfo.isShow = YES;
    keyboardInfo.keyboardFrameBegin = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardInfo.keyboardFrameEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardInfo.animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardInfo.keyboardY = self.view.bounds.size.height - keyboardInfo.keyboardFrameEnd.size.height;
    keyboardInfo.keyboardH = keyboardInfo.keyboardFrameEnd.size.height;
    keyboardInfo.curve = (UIViewAnimationCurve)[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    keyboardInfo.options = keyboardInfo.curve<<!6;
    
    // 记录数据
    if (!self.keyboardInfo) {
        keyboardInfo.startContentOffset = self.tableView.contentOffset;
    } else {
        keyboardInfo.startContentOffset = self.keyboardInfo.startContentOffset;
    }
    if (!self.keyboardInfo) {
        keyboardInfo.startEdgeInset = self.tableView.contentInset;
    } else {
        keyboardInfo.startEdgeInset = self.keyboardInfo.startEdgeInset;
    }
    self.keyboardInfo = keyboardInfo;
    if (self.inputHandleOption==WWKEasyKeyboardHandleOptionSystem) {
        self.keyboardInfo.didChangeContentInset = YES;
        [UIView animateWithDuration:keyboardInfo.animationDuration delay:0.0 options:keyboardInfo.options animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.keyboardInfo.keyboardH, self.tableView.contentInset.right);
        } completion:nil];
    } else if ([self shouldHandleKeyboard]){
        self.keyboardInfo.didChangeContentInset = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.keyboardInfo.keyboardH, self.tableView.contentInset.right);
    }
    
    if (self.inputHandleOption == WWKEasyKeyboardHandleOptionCursor) { // 通知时候的光标位置是老位置，在此时无法获取最新的光标位置，所以延时处理
        self.keyboardInfo.didChangeContentInset = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleEditCellFrameWhenEditing];
        });
    } else if (self.inputHandleOption == WWKEasyKeyboardHandleOptionCell) {
        self.keyboardInfo.didChangeContentInset = YES;
        [self handleEditCellFrameWhenEditing];
    }
}

- (void)easykeyboardWillHide:(NSNotification *)noti {
    if (!_isAppear || !self.keyboardInfo.didChangeContentInset) {
        return;
    }
    self.tableView.contentInset = self.keyboardInfo.startEdgeInset;
    self.tableView.contentOffset = self.keyboardInfo.startContentOffset;
    self.keyboardInfo = nil;
}

- (void)easykeyboardDidShow:(NSNotification *)noti {
    if (!_isAppear) return;
    self->_didShowKeybord = YES;
}

- (void)easykeyboardDidHide:(NSNotification *)noti {
//    if (!_isAppear) return;
    self->_didShowKeybord = NO;
}

-(void)setIgnoreMemoryWarning:(BOOL)ignoreMemoryWarning{
    _ignoreMemoryWarning = ignoreMemoryWarning;
    if (ignoreMemoryWarning) {
        object_setClass(self.tableView, [WWKIgnoreMemoryWarningTableView class]);
    }else{
        object_setClass(self.tableView, [WWKEasyTableView class]);
    }
}

- (void)setDisableTableViewSetContentOffset:(BOOL)disableTableViewSetContentOffset {
    _disableTableViewSetContentOffset = disableTableViewSetContentOffset;
    if ( self.isViewLoaded && _tableView != nil && [_tableView isKindOfClass:[WWKEasyTableView class]] ) {
        ((WWKEasyTableView*)_tableView).disableSetContentOffset = disableTableViewSetContentOffset;
    }
}

- (void)tapClick {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tap) {
        if (self->_didShowKeybord && self.endEditingWhenTouch && self.inputHandleOption != WWKEasyKeyboardHandleOptionDisable) {
            if ( self.customEndEditingWhenTouchBlock != nil ) {
                return self.customEndEditingWhenTouchBlock(touch);
            }
            return YES;
        }
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Item magic

- (NSString *)create16LetterAndNumber {
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    return result;
}

- (UITableViewCell *)cellForItem:(WWKEasyTableItem *)item {
    if (item.disableCellReused && item.strongRefCellWhenDisableReuse) {
        return item.strongRefCellWhenDisableReuse;
    }
    Class cellClass = [item cellClass];
    NSString *reusableIdentifer = NSStringFromClass(cellClass);
    if (item.isDisableCellReused) {
        NSTimeInterval time= [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
        reusableIdentifer = [NSString stringWithFormat:@"%@_%p_%@_%f", cellClass, item, [self create16LetterAndNumber], time];
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableIdentifer];
    if (!cell) {
        cell = [[cellClass alloc] easy_performSelector:@selector(initWithStyle:reuseIdentifier:) withObjects:@[
                                                                                                               @(UITableViewCellStyleValue1),
                                                                                                               reusableIdentifer
                                                                                                               ]];
    }
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusableIdentifer];
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WWKEasyTableViewDefaultCell"];
    }
    if (item.disableCellReused) {
        item.strongRefCellWhenDisableReuse = cell;
    }
    return cell;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    return sectionItem.cellDataSource.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WWKEasyTableSectionItem<NSArray *> *sectionItem = [self.dataSource objectAtIndex:section];
    sectionItem.section = section;
    if (sectionItem.configHeaderViewBlock) {
        sectionItem.configHeaderViewBlock(sectionItem.headerView, sectionItem);
    }
    return sectionItem.headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    sectionItem.section = section;
    if (sectionItem.configFooterViewBlock) {
        sectionItem.configFooterViewBlock(sectionItem.footerView, sectionItem);
    }
    return sectionItem.footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    sectionItem.section = section;
    if (sectionItem.configHeaderViewBlock && sectionItem.headerView==view) {
        sectionItem.configHeaderViewBlock(view, sectionItem);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    sectionItem.section = section;
    if (sectionItem.configFooterViewBlock && sectionItem.footerView==view) {
        sectionItem.configFooterViewBlock(view, sectionItem);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    if (!sectionItem.headerView) {
        return CGFLOAT_MIN;
    }
    if (!sectionItem.headerHeight && sectionItem.configHeaderHeightBlock) {
        sectionItem.headerHeight = sectionItem.configHeaderHeightBlock(sectionItem);
    }
    return sectionItem.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:section];
    if (!sectionItem.footerView) {
        return CGFLOAT_MIN;
    }
    if (!sectionItem.footerHeight && sectionItem.configFooterHeightBlock) {
        sectionItem.footerHeight = sectionItem.configFooterHeightBlock(sectionItem);
    }
    return sectionItem.footerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    WWKEasyTableItem *item = [sectionItem.cellDataSource objectAtIndex:indexPath.row];
    item.tableView = self.tableView;
    UITableViewCell *cell = [self cellForItem:item];
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    WWKEasyTableItem *item = [sectionItem.cellDataSource objectAtIndex:indexPath.row];
    item.cell = cell;
    item.tmpCell = nil;
    item.indexPath = indexPath;
    if (item.isHidden) {
        item.cell.hidden = YES;
    } else {
        item.cell.hidden = NO;
    }
    if (self.autoCellBackgroundColor) {
        item.cell.contentView.backgroundColor = self.tableView.backgroundColor;
    }
    if (item.configCellBlock) {
        item.configCellBlock(cell, item);
    }
    if (item.hover == EasyTableHoverTop) {
        [self.topHoverItemMap setObject:item forKey:@(indexPath.row).stringValue];
    }
    if (self.OPEN_DEBUG) {
        CGFloat red = ( arc4random() % 255 / 255.0 );
        CGFloat green = ( arc4random() % 255 / 255.0 );
        CGFloat blue = ( arc4random() % 255 / 255.0 );
        UIColor *randomColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        item.cell.contentView.backgroundColor = randomColor;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.topHoverItemMap removeObjectForKey:@(indexPath.row).stringValue];
}
 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    WWKEasyTableItem *item = [sectionItem.cellDataSource objectAtIndex:indexPath.row];
    if (item.isHidden) {
        item.cell.hidden = YES;
        return 0.01;
    } else {
        item.cell.hidden = NO;
    }
    
    BOOL itemLastWidthChanged = NO;
    CGFloat tblWidth = tableView.bounds.size.width;
    if (item.easy_lastTblWidth != tblWidth) {
        itemLastWidthChanged = YES;
        item.easy_lastTblWidth = tblWidth;
    }
    
    if (0.01==item.cellHeight || 0==item.cellHeight || item.disableCellReused || item.isDisableCellHeightCache || itemLastWidthChanged) {
        if (item.configHeightBlock) {
            // 1.没有则构造一个cell用于布局计算-这个cell最终有可能被系统抛弃掉
            if (!item.cell) {
                if (item.disableDequeueCellForCaculateHeight) {
                    NSString *reusableIdentifer = [NSString stringWithFormat:@"%@_caculate", NSStringFromClass([item cellClass])];
                    item.tmpCell = [[[item cellClass] alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusableIdentifer];
                } else {
                    item.tmpCell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
                }
                item.cell = item.cell; // 由于有可能被析构
            }
            // 2.给这个cell喂了数据再计算高度
            if (item.configCellBlock) {
                item.configCellBlock(item.cell, item);
            }
            // 3.计算高度
            item.cellHeight = item.configHeightBlock(item);
        } else if (item.autoCalculateHeight) {
            // 1.没有则构造一个cell用于布局计算-这个cell最终有可能被系统抛弃掉
            if (!item.cell) {
                if (item.disableDequeueCellForCaculateHeight) {
                    NSString *reusableIdentifer = [NSString stringWithFormat:@"%@_caculate", NSStringFromClass([item cellClass])];
                    item.tmpCell = [[[item cellClass] alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusableIdentifer];
                } else {
                    item.tmpCell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
                }
                item.cell = item.cell; // 由于有可能被析构
            }
            // 2.给这个cell喂了数据再计算高度
            if (item.configCellBlock) {
                item.configCellBlock(item.cell, item);
            }
            // 3.计算高度 sizeThatFits > autoLayout > configHeightBlock
            CGFloat cellH = [item.cell sizeThatFits:CGSizeMake(tblWidth, CGFLOAT_MAX)].height;
            if (!cellH) {
               cellH = [item.cell.contentView systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, MAXFLOAT) withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height;
                
                [item.cell.contentView sizeThatFits:CGSizeZero];
            }
            // 3.计算高度失效
            if (!cellH) {
                if (item.configHeightBlock) {
                    item.cellHeight = item.configHeightBlock(item);
                }
            }
            item.cellHeight = cellH;
        }
    }

    return item.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.disableAutoDeselectRow) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    WWKEasyTableSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    WWKEasyTableItem *item = [sectionItem.cellDataSource objectAtIndex:indexPath.row];
    if(item.cellClickAction){
        item.cellClickAction(item);
    }
}


#pragma mark - ScrollView

- (BOOL)setTopHoverStateIsRefresh:(EasyHoverState)topHoverState {
    BOOL refreshState = NO;
    if (_topHoverState!=topHoverState) {
        refreshState = YES;
    }
    _topHoverState = topHoverState;
    return refreshState;
}

- (WWKEasyTableItem *)minTopHoverItem {
    NSInteger maxRow = 0;
    NSInteger minRow = NSIntegerMax;
    for (NSString *num in self.topHoverItemMap.allKeys) {
        NSInteger x = num.integerValue;
        if (x < minRow) minRow = x;
        if (x > maxRow) maxRow = x;
    }
    return [self.topHoverItemMap objectForKey:@(minRow).stringValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // hover的逻辑处理
    if (self.dataSource.count > 1) return;
    if (self.topHoverItemMap.allKeys.count <= 0) return;
    
    
    // 1.找到最近那个cell
    WWKEasyTableItem *replaceItem = [self minTopHoverItem];
    CGRect replaceCellRect = [self.tableView rectForRowAtIndexPath:replaceItem.indexPath];
    
    // 2.当前悬停cell相对scroll内容的上下位置
    CGFloat hoverTopInContent = scrollView.contentOffset.y + scrollView.contentInset.top;
    CGFloat hoverBottomInContent = hoverTopInContent + self.currentTopHoverView.frame.size.height;
    CGRect hoverCellRect = CGRectMake(0, hoverTopInContent, scrollView.bounds.size.width, (hoverBottomInContent-hoverTopInContent));
    CGFloat replaceCellRectTop = CGRectGetMinY(replaceCellRect);
    CGFloat replaceCellRectBottom = CGRectGetMaxY(replaceCellRect);
    CGFloat hoverCellRectTop = CGRectGetMinY(hoverCellRect);
    CGFloat hoverCellRectBottom = CGRectGetMaxY(hoverCellRect);
    
    // 3.逻辑
    if (self.currentTopHoverItem != replaceItem) { // 探测到新的一个item
        if (CGRectIntersectsRect(replaceCellRect, hoverCellRect)) {
            // 有交集
            if (!self.currentTopHoverView) {
                if ([self setTopHoverStateIsRefresh:HoverStateSuspend]) {
                    // 第一个刚好悬停
                    [self.currentTopHoverView removeFromSuperview];
                    self.currentTopHoverView = nil;
                    self.currentTopHoverView = [replaceItem.cell easy_duplicate];
                    [self.tableView addSubview:self.currentTopHoverView];
                    self.currentTopHoverItem = replaceItem;
                }
            } else {
                if (replaceCellRectTop < scrollView.contentOffset.y) {
                    if ([self setTopHoverStateIsRefresh:HoverStateSuspend]) {
                        // 老的刚好被滚走了
                        [self.currentTopHoverView removeFromSuperview];
                        WWKEasyDisappearHover *disappearHover = [WWKEasyDisappearHover new];
                        disappearHover.hoverView = self.currentTopHoverView;
                        disappearHover.hoverItem = self.currentTopHoverItem;
                        [self.disappearHoverCellArr addObject:disappearHover];
                        self.currentTopHoverView = [replaceItem.cell easy_duplicate];
                        [self.tableView addSubview:self.currentTopHoverView];
                        self.currentTopHoverItem = replaceItem;
                    }
                } else {
                    // 滚动变换中
                    [self setTopHoverStateIsRefresh:HoverStateReplace];
                    CGRect targetRect = hoverCellRect;
                    targetRect.origin.y = replaceCellRect.origin.y - self.currentTopHoverView.bounds.size.height;
                    targetRect.size.height = self.currentTopHoverView.bounds.size.height;
                    self.currentTopHoverView.frame = targetRect;
                }
            }
        } else if (replaceCellRectBottom < hoverCellRectTop) {
            // 在上面
            [self setTopHoverStateIsRefresh:HoverStateSuspend];
            self.currentTopHoverView.frame = hoverCellRect;
        } else if (replaceCellRectTop > hoverCellRectBottom) {
            // 在下面
            [self setTopHoverStateIsRefresh:HoverStateWillReplace];
            self.currentTopHoverView.frame = hoverCellRect;
        }
        
    } else {
        if (replaceCellRectBottom > hoverCellRectBottom) {
            if ([self setTopHoverStateIsRefresh:HoverStateReplace]) {
                // 刚好滚回来
                WWKEasyDisappearHover *disappearHover = self.disappearHoverCellArr.lastObject;
                [self.currentTopHoverView removeFromSuperview];
                self.currentTopHoverView = nil;
                self.currentTopHoverItem = nil;
                if (disappearHover) {
                    self.currentTopHoverView = disappearHover.hoverView;
                    [self.tableView addSubview:self.currentTopHoverView];
                    self.currentTopHoverItem = disappearHover.hoverItem;
                    [self.disappearHoverCellArr removeObject:disappearHover];
                }
            } else {
                self.currentTopHoverView.frame = hoverCellRect;
            }
        } else {
            self.currentTopHoverView.frame = hoverCellRect;
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.endEditingWhenBeginDragging && self.inputHandleOption != WWKEasyKeyboardHandleOptionDisable) {
        [self.view endEditing:YES];
    }
}

// 根据WWKEasyTableItem的filterID查询对应的WWKEasyTableItem
- (NSArray<__kindof WWKEasyTableItem *> *)getEasyTableItemsWithfilterID:(NSString *)filterID {
    // 这里没有用map效率比较低，但是map维护成本高，先这样用一下吧
    NSMutableArray<WWKEasyTableItem *> *allItems = [NSMutableArray array];
    NSMutableArray<WWKEasyTableItem *> *re = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(WWKEasyTableSectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [allItems addObjectsFromArray:obj.cellDataSource];
    }];
    [allItems enumerateObjectsUsingBlock:^(WWKEasyTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.filterID isEqualToString:filterID]) {
            [re addObject:obj];
        }
    }];
    return [re copy];
}

// 获取所有WWKEasyTableItem
- (NSArray<__kindof WWKEasyTableItem *> *)p_getAllEasyTableItems {
    // 这里没有用map效率比较低，但是map维护成本高，先这样用一下吧
    NSMutableArray<WWKEasyTableItem *> *allItems = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(WWKEasyTableSectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [allItems addObjectsFromArray:obj.cellDataSource];
    }];
    return [allItems copy];
}

@end

