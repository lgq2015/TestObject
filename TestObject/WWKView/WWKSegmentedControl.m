//
//  WWKSegmentedControl.m
//  wework
//
//  Created by 王泽一 on 2016/12/12.
//  Copyright © 2016年 rdgz. All rights reserved.
//

#import "WWKSegmentedControl.h"
#import <QMUIKit/QMUIKit.h>

#define exitIfJudgedEqual(object1, object2) \
if(object1 == object2)\
    return;

#define segmentInterval 0
#define segmentLeftRightMargin 10

@interface WWKSegmentedControl()

@property(nonatomic, strong) UISegmentedControl *sysSegmentedControl;

@property(nonatomic, strong) NSMutableArray<QMUIButton*> *innerButtonArray;

@end

//----------------------------------------------------------------------
@implementation WWKSegmentedControl

@synthesize customSelectedButtonTitleColor = _customSelectedButtonTitleColor;
@synthesize customNormalButtonTitleColor = _customNormalButtonTitleColor;
@synthesize titleFont = _titleFont;

- (instancetype)initWithItems:(nullable NSArray<NSString*> *)itemStringArray controlType:(WWKSegmentedControlType) controlType{
    if(self == [super init]){
        self.controlType = controlType;
        self.itemStringArray = itemStringArray;
    }
    return self;
}

- (NSMutableArray<QMUIButton *> *)innerButtonArray{
    if(nil == _innerButtonArray)
        _innerButtonArray = [[NSMutableArray<QMUIButton*> alloc] init];
    
    return _innerButtonArray;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self redesign];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if(WWKSegmentedControlType_Tab == _controlType){
        CGFloat eachWidth = 0;
        CGFloat eachHeight = 0;
        if(0 == _innerButtonArray.count){
            return CGSizeZero;
        }
        
        eachWidth = CGRectGetWidth(_innerButtonArray[0].frame);
        eachHeight = CGRectGetHeight(_innerButtonArray[0].frame);
        return CGSizeMake(eachWidth * _innerButtonArray.count + segmentInterval * (_innerButtonArray.count - 1), eachHeight);
    }
    
    [_sysSegmentedControl sizeToFit];
    return CGSizeMake(_sysSegmentedControl.qmui_width, _sysSegmentedControl.qmui_height);
}

- (void)readdSubView{
    [self qmui_removeAllSubviews];
    [_innerButtonArray removeAllObjects];
    self.sysSegmentedControl = nil;
    
    if(0 == _itemStringArray.count){
        return;
    }
    
    if(WWKSegmentedControlType_Tab == _controlType){
        for(int i = 0; i < _itemStringArray.count; i++){
            QMUIButton* btn = [[QMUIButton alloc] init];
            [btn addTarget:self action:@selector(segmentActionOfBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:_itemStringArray[i] forState:UIControlStateNormal];
            [btn setTag:i];
            [self addSubview:btn];
            [self.innerButtonArray addObject:btn];
        }
        return;
    }
    
    self.sysSegmentedControl = [[UISegmentedControl alloc] initWithItems:_itemStringArray];
    [_sysSegmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_sysSegmentedControl];
}

- (void)redesign{
    if(0 == _itemStringArray.count){
        return;
    }
    
    switch (_controlType) {
        case WWKSegmentedControlType_Tab:
            [self redesignForCustom];
            break;
        case WWKSegmentedControlType_SysSegmentedControl:
            [self redesignForSystem];
            break;
        default:
            break;
    }
}

- (CGFloat)contenDefaultHeight{
    return fabs(self.qmui_height - 0.0) < FLT_EPSILON ? 32 : self.qmui_height;
}

- (void)redesignForCustom{
    CGFloat eachHeight = [self contenDefaultHeight];
    CGFloat eachWidth = 0;
    for(QMUIButton* tempBtn in _innerButtonArray){
        [tempBtn.titleLabel setFont:self.titleFont];
        [tempBtn setContentEdgeInsets:UIEdgeInsetsMake(0, segmentLeftRightMargin, 0, segmentLeftRightMargin)];
        [tempBtn sizeToFit];
        if(tempBtn.qmui_width > eachWidth){
            eachWidth = tempBtn.qmui_width;
        }
    }
    
    CGFloat left = 0;
    for(QMUIButton* tempBtn in _innerButtonArray){
        [tempBtn setFrame:CGRectMake(left, 0, eachWidth, eachHeight)];
        left = tempBtn.qmui_right + segmentInterval;
    }
    
    self.selectedSegmentIndex = _selectedSegmentIndex;
}

- (void)redesignForSystem{
    CGFloat eachHeight = [self contenDefaultHeight];
    CGFloat eachWidth = 0;
    for(NSString* title in _itemStringArray){
        CGSize titleSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, eachHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil].size;
        titleSize.width += (segmentLeftRightMargin * 2);
        if(titleSize.width > eachWidth){
            eachWidth = titleSize.width;
        }
    }
    
    for(int i = 0; i<_sysSegmentedControl.numberOfSegments; i++){
        [_sysSegmentedControl setWidth:eachWidth forSegmentAtIndex:i];
    }
    [_sysSegmentedControl setQmui_height:eachHeight];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.customNormalButtonTitleColor,NSForegroundColorAttributeName,self.titleFont,NSFontAttributeName,nil];
    [_sysSegmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];

    dic = [NSDictionary dictionaryWithObjectsAndKeys:self.customSelectedButtonTitleColor,NSForegroundColorAttributeName,self.titleFont,NSFontAttributeName,nil];
    [_sysSegmentedControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    
    self.selectedSegmentIndex = _selectedSegmentIndex;
}

#pragma mark - operational event response
-(void)segmentActionOfBtn:(QMUIButton*) btn{
    self.selectedSegmentIndex = btn.tag;
    if(_didSelectItemBlock){
        _didSelectItemBlock(btn.tag);
    }
}

-(void)segmentAction:(UISegmentedControl *) seg{
    self.selectedSegmentIndex = seg.selectedSegmentIndex;
    if(_didSelectItemBlock){
        _didSelectItemBlock(seg.selectedSegmentIndex);
    }
}

#pragma mark - setter/getter
- (void)setItemStringArray:(NSArray<NSString *> *)itemStringArray{
    exitIfJudgedEqual(_itemStringArray, itemStringArray);
    
    _itemStringArray = itemStringArray;
    [self readdSubView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setControlType:(WWKSegmentedControlType)controlType{
    exitIfJudgedEqual(_controlType, controlType);
    
    _controlType = controlType;
    [self readdSubView];
    [self layoutIfNeeded];
}

- (UIColor *)customSelectedButtonTitleColor{
    if(_customSelectedButtonTitleColor){
        return _customSelectedButtonTitleColor;
    }
    
    if(_controlType == WWKSegmentedControlType_Tab){
        return [UIColor blueColor];
    }
    
    return [UIColor blueColor];
}

- (void)setCustomSelectedButtonTitleColor:(UIColor *)customSelectedButtonTitleColor{
    exitIfJudgedEqual(_customSelectedButtonTitleColor, customSelectedButtonTitleColor);
    
    _customSelectedButtonTitleColor = customSelectedButtonTitleColor;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIColor *)customNormalButtonTitleColor{
    if(_customNormalButtonTitleColor){
        return _customNormalButtonTitleColor;
    }
    
    if(_controlType == WWKSegmentedControlType_Tab){
        return [[UIColor blueColor] colorWithAlphaComponent:0.5];
    }
    
    return [UIColor blueColor];
}

- (void)setCustomNormalButtonTitleColor:(UIColor *)customNormalButtonTitleColor{
    exitIfJudgedEqual(_customNormalButtonTitleColor, customNormalButtonTitleColor);
    
    _customNormalButtonTitleColor = customNormalButtonTitleColor;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIFont *)titleFont{
    return _titleFont ?: [UIFont systemFontOfSize:20];
}

- (void)setTitleFont:(UIFont *)titleFont{
    exitIfJudgedEqual(_titleFont, titleFont);
    
    _titleFont = titleFont;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    _selectedSegmentIndex = selectedSegmentIndex;
    
    if(WWKSegmentedControlType_Tab == _controlType){
        if(_selectedSegmentIndex >= _innerButtonArray.count){
            return;
        }
        
        for (NSInteger index = 0; index < [_innerButtonArray count]; index++) {
            QMUIButton* button = [_innerButtonArray objectAtIndex:index];
            if (index == _selectedSegmentIndex) {
                [button setTitleColor:self.customSelectedButtonTitleColor forState:UIControlStateNormal];
                continue;
            }
            
            [button setTitleColor:self.customNormalButtonTitleColor forState:UIControlStateNormal];
        }
        return;
    }
    
    if(_sysSegmentedControl){
        _sysSegmentedControl.selectedSegmentIndex = _selectedSegmentIndex;
    }
}


@end

