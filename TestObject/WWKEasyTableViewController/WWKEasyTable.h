//
//  WWKEasyTableCategory.h
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/24.
//  Copyright © 2019 wyman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (WWKEasyTableCategory)

/** 执行方法，支持多参返回值 */
- (id)easy_performSelector:(SEL)aSelector withObjects:(NSArray *)objects;

/** 动态类型转化 */
+ (instancetype)easy_dynamicCast:(NSObject *)obj;

/** 携带信息 */
@property (nonatomic, strong) NSMutableDictionary *easy_params;


@end


@interface UIView (WWKEasyTableCategory)

- (instancetype)easy_duplicate;

/** 间距适配 限制size-宽度 */
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize width:(NSInteger)width rowMargin:(CGFloat)rowMargin;

/** 九宫格平铺 限制size-列间距-列数 */
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount rowMargin:(CGFloat)rowMargin;

- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount rowMargin:(CGFloat)rowMargin edgeInset:(UIEdgeInsets)edgeInset;

/** 宽度适配 限制列间距-列数-宽度 */
- (CGSize)easy_layoutViewItemHeight:(CGFloat)itemHeight colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount width:(NSInteger)width rowMargin:(CGFloat)rowMargin;

/** 水平平铺 限制size-列间距 */
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin;

/** list 布局 */
- (CGSize)easy_layoutViewItemRowMargin:(CGFloat)rowMargin width:(NSInteger)width;

/** list 布局 根据元素的sizeToFit */
- (CGSize)easy_layoutViewHorizenItemRowMarginCenter:(CGFloat)margin;
- (CGSize)easy_layoutViewHorizenItemRowMarginTop:(CGFloat)margin;

@end


@interface NSString (WWKEasyTableCategory)

/** 给定字号 返回一行文字实际宽度 */
- (CGFloat)easy_getWidthInOneLineWithFont:(UIFont *)font;

/** 给定字号 返回一行文字实际高度 */
- (CGFloat)easy_getHeightInOneLineWithFont:(UIFont *)font;

/** 给定最大宽度和字号 返回实际高度 */
- (CGFloat)easy_getHeightWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font;

/** 给定最大宽度和字号 再根据行数返回实际高度 */
- (CGFloat)easy_getHeightWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font inNumberLine:(NSInteger)number;

/** 获取富文本,行高 */
- (NSAttributedString *)easy_stringWithParagraphlineSpeace:(CGFloat)lineSpacing textColor:(UIColor *)textcolor textFont:(UIFont *)font;

/** 获取富文本高度 */
- (CGFloat)easy_getHeightWithParagraphSpeace:(CGFloat)lineSpeace font:(UIFont*)font maxWidth:(CGFloat)maxWidth;

/** 获取富文本高度制定行数 */
- (CGFloat)easy_getHeightWithParagraphSpeace:(CGFloat)lineSpeace font:(UIFont*)font maxWidth:(CGFloat)maxWidth inNumberLine:(NSInteger)number;

/**
 * 设置行高-行间距-字间距构造富文本
 * 多行文本的单行渲染高度 ：行高+行间距 【文本渲染是在行高内居中的】，所以计算公式如下
 * 真实的一行高度 = (lineHeight-fontSize)/2 + fontSize + (lineHeight-fontSize)/2 + lineSpacing
 */
- (NSAttributedString *)easy_attributeStringFont:(UIFont *)font textColor:(UIColor *)textColor lineHeight:(CGFloat)lineHeight lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing underlineStyle:(NSUnderlineStyle)underlineStyle;
- (NSAttributedString *)easy_attributeStringFont:(UIFont *)font textColor:(UIColor *)textColor lineHeight:(CGFloat)lineHeight lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing underlineStyle:(NSUnderlineStyle)underlineStyle alignment:(NSTextAlignment)alignment;

/** 从某个富文本拷贝属性 */
- (NSAttributedString *)easy_attributeStringWithOtherAttributeString:(NSAttributedString *)attributeString;

@end

@interface UILabel (WWKEasyTableCategory)

/** 设置行高和字间距 */
- (void)easy_lineHeight:(CGFloat)lineHeight wordSpacing:(CGFloat)wordSpacing;

@end

@interface NSAttributedString (WWKEasyTableCategory)

/** 计算文本高度 */
- (CGFloat)easy_attributeStringGetHeightWithMaxWidth:(CGFloat)maxWidth;

@end

typedef void(^HighlightConfig)(BOOL isHighlightNew, BOOL isHighlightOld);
@interface WWKHighlightControl : UIControl

@property (nonatomic, copy) HighlightConfig easy_highlightConfig;

@end

NS_ASSUME_NONNULL_END
