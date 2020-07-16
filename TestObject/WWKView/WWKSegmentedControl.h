//
//  WWKSegmentedControl.h
//  wework
//
//  Created by 王泽一 on 2016/12/12.
//  Copyright © 2016年 rdgz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WWKSegmentedControlClickBlock)(NSInteger index);

typedef NS_ENUM(NSInteger, WWKSegmentedControlType) {
    WWKSegmentedControlType_Tab = 0,
    WWKSegmentedControlType_SysSegmentedControl = 1,
};

@interface WWKSegmentedControl : UIView

@property(nonatomic, copy) NSArray<NSString*>* itemStringArray;
@property(nonatomic, copy) WWKSegmentedControlClickBlock didSelectItemBlock;
@property(nonatomic, assign) WWKSegmentedControlType controlType;
@property(nonatomic, assign) NSInteger selectedSegmentIndex;
@property(nonatomic, strong) UIColor *customSelectedButtonTitleColor;
@property(nonatomic, strong) UIColor *customNormalButtonTitleColor;
@property(nonatomic, strong) UIFont *titleFont;

- (instancetype)initWithItems:(nullable NSArray<NSString*> *)itemStringArray controlType:(WWKSegmentedControlType) controlType;


@end
