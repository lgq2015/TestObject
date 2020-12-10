//
//  WWKEasyTableCategory.m
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/24.
//  Copyright © 2019 wyman. All rights reserved.
//

#import "WWKEasyTable.h"

@implementation NSObject (WWKEasyTableCategory)

+ (instancetype)easy_dynamicCast:(NSObject *)obj {
    if (![obj isKindOfClass:self]) return nil;
    return obj;
}

- (id)easy_performSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    if (nil == aSelector) return nil;
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:aSelector];
    if(methodSignature == nil) {
        return nil;
    } else {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:aSelector];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
        NSInteger  signatureParamCount = methodSignature.numberOfArguments - 2;
        NSInteger requireParamCount = objects.count;
        NSInteger resultParamCount = MIN(signatureParamCount, requireParamCount);
        for (NSInteger i = 0; i < resultParamCount; i++) {
            id  obj = objects[i];
            
            const char *type = [methodSignature getArgumentTypeAtIndex:2 + i];
            
            /**
             *
             enum _NSObjCValueType {
             NSObjCNoType = 0,
             NSObjCVoidType = 'v',
             NSObjCCharType = 'c',
             NSObjCShortType = 's',
             NSObjCLongType = 'l',
             NSObjCLonglongType = 'q',
             NSObjCFloatType = 'f',
             NSObjCDoubleType = 'd',
             NSObjCBoolType = 'B',
             NSObjCSelectorType = ':',
             NSObjCObjectType = '@',
             NSObjCStructType = '{',
             NSObjCPointerType = '^',
             NSObjCStringType = '*',
             NSObjCArrayType = '[',
             NSObjCUnionType = '(',
             NSObjCBitfield = 'b'
             } API_DEPRECATED("Not supported", macos(10.0,10.5), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
             */
            if (strcmp(type, "@") == 0) {
                [invocation setArgument:&obj atIndex:i+2];
            } else if (strcmp(type, "c") == 0) {
                char v = [obj charValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "s") == 0) {
                short v = [obj shortValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "l") == 0) {
                long v = [obj longValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "q") == 0) {
                long long v = [obj longLongValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "f") == 0) {
                float v = [obj floatValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "d") == 0) {
                double v = [obj doubleValue];
                [invocation setArgument:&v atIndex:i+2];
            } else if (strcmp(type, "B") == 0) {
                BOOL v = [obj boolValue];
                [invocation setArgument:&v atIndex:i+2];
            } else {
                [invocation setArgument:&obj atIndex:i+2];
            }
        }
        [invocation invoke];
        //返回值处理
        id callBackObject = nil;
        if (methodSignature.methodReturnLength) {
            // https://stackoverflow.com/questions/22018272/nsinvocation-returns-value-but-makes-app-crash-with-exc-bad-access
            // 用c指针再转成OC
            void *tempResult = nil;
            [invocation getReturnValue:&tempResult];
            callBackObject = (__bridge id)tempResult;
        }
        return callBackObject;
    }
}

void *k_key_easy_params = &k_key_easy_params;
- (void)setEasy_params:(NSMutableDictionary *)easy_params {
    objc_setAssociatedObject(self, &k_key_easy_params, easy_params, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)easy_params {
    NSMutableDictionary *re = objc_getAssociatedObject(self, &k_key_easy_params);
    if (!re) {
        re = [NSMutableDictionary dictionary];
        [self setEasy_params:re];
    }
    return re;
}

@end


@implementation UIView (WWKEasyTableCategory)

- (instancetype)easy_duplicate {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
#pragma clang diagnostic pop
}

// 限制size-宽度
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize width:(NSInteger)width rowMargin:(CGFloat)rowMargin {
    if (!self.subviews.count ||  itemSize.width > width) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    int colCount = width / itemSize.width;
    CGFloat colMargin = colCount > 1 ? (width - (itemSize.width * colCount)) / (colCount-1) : 0;
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        int row = i / colCount;
        int rol = i % colCount;
        subView.frame = CGRectMake((itemSize.width + colMargin)*rol, (itemSize.height + rowMargin)*row, itemSize.width, itemSize.height);
    }
    unsigned long row = (self.subviews.count-1) / colCount;
    CGFloat height = itemSize.height*(row+1) + rowMargin*row;
    return CGSizeMake(width, height);
}

// 限制size-列间距
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin {
    if (!self.subviews.count) {
        return CGSizeZero;
    }
    NSInteger colCount = self.subviews.count;
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        int rol = i % colCount;
        subView.frame = CGRectMake((itemSize.width + colMargin)*rol, 0, itemSize.width, itemSize.height);
    }
    return CGSizeMake(itemSize.width*self.subviews.count+(self.subviews.count-1)*colMargin, itemSize.height);
}

// 限制size-列间距-列数
- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount rowMargin:(CGFloat)rowMargin {
    CGFloat maxWidth = colCount > 1 ? (itemSize.width * colCount + colMargin * (colCount-1)) : itemSize.width;
    if (!self.subviews.count || itemSize.width > maxWidth) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    if (colCount > self.subviews.count) {
        maxWidth = itemSize.width * self.subviews.count + colMargin * (self.subviews.count-1);
    }
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        int row = i / colCount;
        int rol = i % colCount;
        subView.frame = CGRectMake((itemSize.width + colMargin)*rol, (itemSize.height + rowMargin)*row, itemSize.width, itemSize.height);
    }
    unsigned long row = (self.subviews.count-1) / colCount;
    CGFloat height = itemSize.height*(row+1) + rowMargin*row;
    return CGSizeMake(maxWidth, height);
}

- (CGSize)easy_layoutViewItemSize:(CGSize)itemSize colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount rowMargin:(CGFloat)rowMargin edgeInset:(UIEdgeInsets)edgeInset {
    CGFloat maxWidth = colCount > 1 ? (itemSize.width * colCount + colMargin * (colCount-1)) : itemSize.width;
    if (!self.subviews.count || itemSize.width > maxWidth) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    if (colCount > self.subviews.count) {
        maxWidth = itemSize.width * self.subviews.count + colMargin * (self.subviews.count-1);
    }
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        int row = i / colCount;
        int rol = i % colCount;
        subView.frame = CGRectMake((itemSize.width + colMargin)*rol, edgeInset.top + (itemSize.height + rowMargin)*row, itemSize.width, itemSize.height);
    }
    unsigned long row = (self.subviews.count-1) / colCount;
    CGFloat height = itemSize.height*(row+1) + rowMargin*row;
    height += edgeInset.bottom;
    return CGSizeMake(maxWidth, height);
}


// 限制列间距-列数-宽度
- (CGSize)easy_layoutViewItemHeight:(CGFloat)itemHeight colMargin:(CGFloat)colMargin colCount:(NSInteger)colCount width:(NSInteger)width rowMargin:(CGFloat)rowMargin {
    CGSize itemSize = CGSizeZero;
    itemSize.height = itemHeight;
    itemSize.width = colCount > 1 ? (width - colMargin*(colCount-1)) / colCount : width;
    if (!self.subviews.count || itemSize.width > width) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        int row = i / colCount;
        int rol = i % colCount;
        subView.frame = CGRectMake((itemSize.width + colMargin)*rol, (itemSize.height + rowMargin)*row, itemSize.width, itemSize.height);
    }
    unsigned long row = (self.subviews.count-1) / colCount;
    CGFloat height = itemSize.height*(row+1) + rowMargin*row;
    return CGSizeMake(width, height);
}

/** list 布局 */
- (CGSize)easy_layoutViewItemRowMargin:(CGFloat)rowMargin width:(NSInteger)width {
    if (!self.subviews.count) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    CGFloat bottom = 0;
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        CGFloat h = [subView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        subView.frame = CGRectMake(0, ((i>0)?(bottom+rowMargin):0), width, h);
        bottom = subView.frame.origin.y+subView.bounds.size.height;
    }
    return CGSizeMake(width, bottom);
}

/** list 布局 根据元素的sizeToFit */
- (CGSize)easy_layoutViewHorizenItemRowMarginTop:(CGFloat)margin {
    if (!self.subviews.count) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }
    CGFloat bottom = 0;
    CGFloat left = 0;
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        [subView sizeToFit];
        CGFloat viewX = left;
        if (0!=i) {
            viewX = left + margin;
        }
        subView.frame = CGRectMake(viewX, 0, subView.bounds.size.width, subView.bounds.size.height);
        bottom = MAX(bottom, subView.frame.size.height);
        left += subView.frame.size.width;
    }
    return CGSizeMake(left, bottom);
}

- (CGSize)easy_layoutViewHorizenItemRowMarginCenter:(CGFloat)margin {
    if (!self.subviews.count) {
        NSLog(@"[FLEX LAYOUT WARNING] temSize.width > maxWidth");
        return CGSizeZero;
    }

    CGSize re = [self easy_layoutViewHorizenItemRowMarginTop:margin];
    CGFloat centerY = re.height*0.5;
    for (int i=0; i < self.subviews.count; i++) {
        UIView *subView = self.subviews[i];
        subView.frame = CGRectMake(subView.frame.origin.x, centerY-subView.frame.size.height*0.5, subView.frame.size.width, subView.frame.size.height);
    }
    return re;
}

@end


@implementation WWKHighlightControl : UIControl

- (void)setHighlighted:(BOOL)highlighted {
    BOOL old = self.highlighted;
    [super setHighlighted:highlighted];
    if (self.easy_highlightConfig) {
        self.easy_highlightConfig(highlighted, old);
    } else {
        self.alpha = highlighted ? 0.5f : 1.0f;
    }
}

@end

@implementation NSAttributedString (WWKEasyTableCategory)

- (CGFloat)easy_attributeStringGetHeightWithMaxWidth:(CGFloat)maxWidth {
    UILabel *calLabel = [UILabel new];
    calLabel.attributedText = self;
    calLabel.frame = CGRectMake(0, 0, maxWidth, 0);
    calLabel.numberOfLines = 0;
    [calLabel sizeToFit];
    return CGRectGetHeight(calLabel.frame);
}

@end

@implementation NSString (WWKEasyTableCategory)

/** 给定字号 返回一行文字实际宽度 */
- (CGFloat)easy_getWidthInOneLineWithFont:(UIFont *)font {
    CGFloat maxH = [@"oneLineH" easy_getHeightWithMaxWidth:MAXFLOAT font:font];
    CGSize textMaxSize = CGSizeMake(MAXFLOAT, maxH);
    NSDictionary *textFontDict = @{NSFontAttributeName:font};
    CGRect textContentRect = [self boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontDict context:nil];
    return textContentRect.size.width;
}

/** 给定字号 返回一行文字实际高度 */
- (CGFloat)easy_getHeightInOneLineWithFont:(UIFont *)font {
    return [@"8888" easy_getHeightWithMaxWidth:[UIScreen mainScreen].bounds.size.width font:font inNumberLine:1];
}

/** 给定最大宽度和字号 返回实际高度 */
- (CGFloat)easy_getHeightWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font{
    CGSize textMaxSize = CGSizeMake(maxWidth, MAXFLOAT);
    NSDictionary *textFontDict = @{NSFontAttributeName:font};
    CGRect textContentRect = [self boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontDict context:nil];
    return textContentRect.size.height;
}

/** 给定最大宽度和字号 再根据行数返回实际高度 */
- (CGFloat)easy_getHeightWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font inNumberLine:(NSInteger)number {
    CGFloat maxH = [@"oneLineH" easy_getHeightWithMaxWidth:maxWidth font:font];
    CGSize textMaxSize = CGSizeMake(maxWidth, maxH*number);
    NSDictionary *textFontDict = @{NSFontAttributeName:font};
    CGRect textContentRect = [self boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontDict context:nil];
    return textContentRect.size.height;
}

/** 获取富文本,行高 */
- (NSAttributedString *)easy_stringWithParagraphlineSpeace:(CGFloat)lineSpacing textColor:(UIColor *)textcolor textFont:(UIFont *)font {
    // 设置段落
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    // NSKernAttributeName字体间距
    NSDictionary *attributes = @{ NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@1.5f};
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    // 创建文字属性
    NSDictionary * attriBute = @{NSForegroundColorAttributeName:textcolor,NSFontAttributeName:font};
    [attriStr addAttributes:attriBute range:NSMakeRange(0, self.length)];
    return attriStr;
}

/** 获取富文本高度 */
- (CGFloat)easy_getHeightWithParagraphSpeace:(CGFloat)lineSpeace font:(UIFont*)font maxWidth:(CGFloat)maxWidth {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    /** 行高 */
    paraStyle.lineSpacing = lineSpeace;
    // NSKernAttributeName字体间距
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f };
    CGSize size = [self boundingRectWithSize:CGSizeMake(maxWidth,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}


/** 获取富文本高度制定行数 */
- (CGFloat)easy_getHeightWithParagraphSpeace:(CGFloat)lineSpeace font:(UIFont*)font maxWidth:(CGFloat)maxWidth inNumberLine:(NSInteger)number {
    CGFloat maxH = [@"oneLineH" easy_getHeightWithParagraphSpeace:lineSpeace font:font maxWidth:maxWidth];
    CGSize textMaxSize = CGSizeMake(maxWidth, maxH*number);
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    /** 行高 */
    paraStyle.lineSpacing = lineSpeace;
    // NSKernAttributeName字体间距
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f };
    CGSize size = [self boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
    
}

/**
 * 设置行高-行间距-字间距构造富文本
 */
- (NSAttributedString *)easy_attributeStringFont:(UIFont *)font textColor:(UIColor *)textColor lineHeight:(CGFloat)lineHeight lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing underlineStyle:(NSUnderlineStyle)underlineStyle {
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.minimumLineHeight = lineHeight;
    CGFloat baselineOffset = (lineHeight - font.lineHeight) / 4;
    attributeDict[NSParagraphStyleAttributeName] = paragraphStyle;
    attributeDict[NSBaselineOffsetAttributeName] = @(baselineOffset);
    attributeDict[NSKernAttributeName] = @(wordSpacing);
    attributeDict[NSFontAttributeName] = font;
    attributeDict[NSForegroundColorAttributeName] = textColor;
    attributeDict[NSUnderlineStyleAttributeName] = @(underlineStyle);
    NSAttributedString *re = [[NSAttributedString alloc] initWithString:self attributes:attributeDict];
    return re;
}

- (NSAttributedString *)easy_attributeStringFont:(UIFont *)font textColor:(UIColor *)textColor lineHeight:(CGFloat)lineHeight lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing underlineStyle:(NSUnderlineStyle)underlineStyle alignment:(NSTextAlignment)alignment {
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.alignment = alignment;
    CGFloat baselineOffset = (lineHeight - font.lineHeight) / 4;
    attributeDict[NSParagraphStyleAttributeName] = paragraphStyle;
    attributeDict[NSBaselineOffsetAttributeName] = @(baselineOffset);
    attributeDict[NSKernAttributeName] = @(wordSpacing);
    attributeDict[NSFontAttributeName] = font;
    attributeDict[NSForegroundColorAttributeName] = textColor;
    attributeDict[NSUnderlineStyleAttributeName] = @(underlineStyle);
    NSAttributedString *re = [[NSAttributedString alloc] initWithString:self attributes:attributeDict];
    return re;
}

- (NSAttributedString *)easy_attributeStringWithOtherAttributeString:(NSAttributedString *)attributeString {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributeString];
    [mutableAttributedString.mutableString setString:self];
    return [mutableAttributedString copy];
}


@end


@implementation UILabel (WWKEasyTableCategory)

/** 设置行高和字间距 */
- (void)easy_lineHeight:(CGFloat)lineHeight wordSpacing:(CGFloat)wordSpacing {
    self.attributedText = [self.text easy_attributeStringFont:self.font textColor:self.textColor lineHeight:lineHeight lineSpacing:0 wordSpacing:wordSpacing underlineStyle:NSUnderlineStyleNone];
}

@end
