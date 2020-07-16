//
//  WWKActionBar.h
//  wework
//
//  Created by maxcwfeng on 2020/7/9.
//  Copyright © 2020 rdgz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WWKActionBarLayoutType) {
    WWKActionBarLayoutType_Average = 0,
    WWKActionBarLayoutType_PriorityLeft = 1,     //以左边的控件为主，剩余空间再给右边控件,这种类型仅支持传入两个以下的控件，包括两个
    WWKActionBarLayoutType_PriorityRight = 2,    //以右边的控件为主，剩余空间再给左边控件,这种类型仅支持传入两个以下的控件，包括两个
    WWKActionBarLayoutType_FixedAround = 3,      //左右两个控件固定，剩余空间留个中间的控件，仅支持固定传入三个控件，多传或少传有容错
};

typedef NS_ENUM(NSInteger, WWKActionBarBackColorType) {
    WWKActionBarBackColorType_None = 0,
    WWKActionBarBackColorType_WhiteBlur = 1,      //磨砂白
    WWKActionBarBackColorType_GrayBlur  = 2,      //磨砂灰
};

//---------------------------------------------------------------
@interface WWKActionBar : UIView

- (instancetype)initWithItemViews:(NSArray<UIView *> *)itemViews backColorType:(WWKActionBarBackColorType) backColorType layoutType:(WWKActionBarLayoutType)layoutType;

@property(nonatomic, copy) NSArray<UIView *> *itemViews;    //设置为nil代表清空

@property(nonatomic, assign) CGFloat itemSpacing;   //子控件间隔，跟UIcolletionview的用法差不过  |item| - itemSpacing - |item|

@property(nonatomic, assign) WWKActionBarLayoutType layoutType;

@property(nonatomic, assign) WWKActionBarBackColorType backColorType;

+ (QMUIButton*)buttonWithTitle:(NSString*) title;

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor;

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor image:(UIImage*) btnImag;

+ (QMUIButton*)buttonWithTitle:(NSString*) title titleColor:(UIColor*) titleColor image:(UIImage*) btnImag btnType:(QMUIButtonImagePosition)btnType;

@end

NS_ASSUME_NONNULL_END
