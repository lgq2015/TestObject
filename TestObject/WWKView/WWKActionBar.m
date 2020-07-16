//
//  WWKActionBar.m
//  wework
//
//  Created by maxcwfeng on 2020/7/9.
//  Copyright © 2020 rdgz. All rights reserved.
//

#import "WWKActionBar.h"

#define exitIfJudgedEqual(object1, object2) \
    if(object1 == object2)\
        return;

@interface WWKActionBar ()
{
    UIEdgeInsets _contentEdgeInsets;    //左上右下边距
}

@end

//---------------------------------------------------------------
@implementation WWKActionBar

- (instancetype)initWithItemViews:(NSArray<UIView *> *)itemViews backColorType:(WWKActionBarBackColorType) backColorType layoutType:(WWKActionBarLayoutType)layoutType {
    if (self = [super init]) {
        self.layoutType = layoutType;
        self.backColorType = backColorType;
        self.itemViews = itemViews;
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self redesign];
}

- (void)setItemViews:(NSArray<UIView *> *)itemViews{
    exitIfJudgedEqual(_itemViews, itemViews);
    
    [self readdSubView:itemViews];
    [self setNeedsLayout];
}

- (void)setItemSpacing:(CGFloat)itemSpacing{
    exitIfJudgedEqual(_itemSpacing, itemSpacing);
    
    _itemSpacing = itemSpacing;
    [self setNeedsLayout];
}

- (void)setLayoutType:(WWKActionBarLayoutType)layoutType{
    exitIfJudgedEqual(_layoutType, layoutType);
    
    _layoutType = layoutType;
    
    //设置默认的_itemSpacing的
    if(WWKActionBarLayoutType_PriorityLeft == _layoutType
       || WWKActionBarLayoutType_PriorityRight == _layoutType){
        _contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 14);
    } else if(WWKActionBarLayoutType_FixedAround == _layoutType){
        _contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    } else{
        _contentEdgeInsets = UIEdgeInsetsZero;
    }
    
    [self setNeedsLayout];
}

- (void)setBackColorType:(WWKActionBarBackColorType)backColorType{
    exitIfJudgedEqual(_backColorType, backColorType);
    
    _backColorType = backColorType;
//    if(WWKActionBarBackColorType_WhiteBlur == backColorType){
//        self.wwk_applyVisualEffect = YES;
//        self.wwk_effectView.foregroundColor = WWKColor(1);
//    }
//    else if(WWKActionBarBackColorType_GrayBlur == backColorType){
//        self.wwk_applyVisualEffect = YES;
//        self.wwk_effectView.foregroundColor = WWKColor(53);
//    } else{
//        self.wwk_applyVisualEffect = NO;
//    }
}

- (void)readdSubView:(NSArray<UIView *> *) newItemViews{
    //不能直接用qmui_removeAllSubviews，因为磨砂背景也是subview
    if(_itemViews.count){
        for(UIView* tempView in _itemViews){
            [tempView removeFromSuperview];
        }
    }
    _itemViews = newItemViews;
    if(_itemViews.count){
        for(UIView* tempView in _itemViews){
            [self addSubview:tempView];
        }
    }
}

- (void)redesign{
    if(0 == _itemViews.count){
        return;
    }
    
    switch (_layoutType) {
        case WWKActionBarLayoutType_Average:
            [self redesignForAverage];
            break;
        case WWKActionBarLayoutType_PriorityLeft:
            [self redesignForPriorityLeft];
            break;
        case WWKActionBarLayoutType_PriorityRight:
            [self redesignForPriorityRight];
            break;
        case WWKActionBarLayoutType_FixedAround:
            [self redesignForFixedAround];
        default:
            break;
    }
}

- (void)redesignForAverage{
    CGSize drawSize = [self calculateDrawSize];
    
    CGFloat itemWidth = (drawSize.width - (_itemViews.count - 1) * _itemSpacing) / _itemViews.count;
    CGFloat left = _contentEdgeInsets.left;
    for(UIView* tempView in _itemViews){
        CGRect frame = CGRectMake(left, _contentEdgeInsets.top, itemWidth, drawSize.height);
        tempView.frame = frame;
        
        left = tempView.qmui_right + _itemSpacing;
    }
}

- (void)redesignForPriorityLeft{
    if(1 == _itemViews.count){
        return [self drawOnlyOneItem:YES];
    }
    
    CGSize drawSize = [self calculateDrawSize];
    
    UIView* leftItemView = _itemViews[0];
    CGRect leftItemFrame = CGRectMake(_contentEdgeInsets.left, _contentEdgeInsets.top, leftItemView.qmui_width, drawSize.height);
    leftItemView.frame = leftItemFrame;
    
    UIView* rightItemView = _itemViews[1];
    CGFloat width = (leftItemView.qmui_width + _itemSpacing) > drawSize.width ? 0.0 : drawSize.width - (leftItemView.qmui_width + _itemSpacing);
    CGRect rightItemFrame = CGRectMake(leftItemView.qmui_right + _itemSpacing, _contentEdgeInsets.top, width, drawSize.height);
    rightItemView.frame = rightItemFrame;
}

- (void)redesignForPriorityRight{
    if(1 == _itemViews.count){
        return [self drawOnlyOneItem:YES];
    }
    
    CGSize drawSize = [self calculateDrawSize];
    
    UIView* rightItemView = _itemViews[1];
    CGRect rightItemFrame = CGRectMake(_contentEdgeInsets.left + drawSize.width - rightItemView.qmui_width, _contentEdgeInsets.top, rightItemView.qmui_width, drawSize.height);
    rightItemView.frame = rightItemFrame;

    UIView* leftItemView = _itemViews[0];
    CGFloat width = (rightItemView.qmui_width + _itemSpacing) > drawSize.width ? 0.0 : drawSize.width - (rightItemView.qmui_width + _itemSpacing);
    CGRect leftItemFrame = CGRectMake(rightItemView.qmui_left - _itemSpacing - width, _contentEdgeInsets.top, width, drawSize.height);
    leftItemView.frame = leftItemFrame;
}

- (void)redesignForFixedAround{
    if(1 == _itemViews.count){
        //仅左边固定一个item，不改宽度。
        return [self drawOnlyOneItem:NO];
    }
    
    CGSize drawSize = [self calculateDrawSize];
    
    //先排左右两边固定的两个item
    UIView* leftItemView = _itemViews[0];
    UIView* centerItemView = _itemViews.count > 2 ? _itemViews[1] : nil;
    UIView* rightItemView = _itemViews.count > 2 ? _itemViews[2] : _itemViews[1];

    CGRect leftItemFrame = CGRectMake(_contentEdgeInsets.left, _contentEdgeInsets.top, leftItemView.qmui_width, drawSize.height);
    leftItemView.frame = leftItemFrame;
    
    CGRect rightItemFrame = CGRectMake(_contentEdgeInsets.left + drawSize.width - rightItemView.qmui_width, _contentEdgeInsets.top, rightItemView.qmui_width, drawSize.height);
    rightItemView.frame = rightItemFrame;
    
    if(nil == centerItemView){
        return;
    }
    
    CGFloat centerItemWidth = drawSize.width - leftItemView.qmui_width - rightItemView.qmui_width - 2 * _itemSpacing;
    if(centerItemWidth < 0){
        centerItemWidth = 0;
    }
    
    //排中间item
    CGRect centerItemFrame = CGRectMake(leftItemView.qmui_right + _itemSpacing, _contentEdgeInsets.top, centerItemWidth, drawSize.height);
    centerItemView.frame = centerItemFrame;
}

- (void)drawOnlyOneItem:(BOOL)needFillWidth{
    CGSize drawSize = [self calculateDrawSize];
    
    UIView* itemView = _itemViews[0];
    CGFloat width = needFillWidth ? drawSize.width : itemView.qmui_width;
    
    CGRect itemFrame = CGRectMake(_contentEdgeInsets.left, _contentEdgeInsets.top, width, drawSize.height);
    itemView.frame = itemFrame;
}

- (CGSize)calculateDrawSize{
    return CGSizeMake(self.qmui_width - _contentEdgeInsets.left - _contentEdgeInsets.right, self.qmui_height - _contentEdgeInsets.top - _contentEdgeInsets.bottom);
}

+ (QMUIButton*)buttonWithTitle:(NSString*) title{
    return [self buttonWithTitle:title titleColor:[UIColor redColor]];
}

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor{
    return [self buttonWithTitle:title titleColor:titleColor image:nil];
}

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor image:(UIImage*) btnImag{
    return [self buttonWithTitle:title titleColor:titleColor image:btnImag btnType:QMUIButtonImagePositionLeft];
}

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor image:(UIImage*) btnImag btnType:(QMUIButtonImagePosition)btnType{
    QMUIButton* btn = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(32, 32)];
    [btn setImage:btnImag forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setImagePosition:btnType];
    
    return btn;
}

@end
