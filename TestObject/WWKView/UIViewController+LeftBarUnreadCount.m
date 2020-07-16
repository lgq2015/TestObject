//
//  UIViewController+LeftBarUnreadCount.mm
//  wework
//
//  Created by maxcwfeng on 2020/7/7.
//  Copyright © 2020 rdgz. All rights reserved.
//

#import "UIViewController+LeftBarUnreadCount.h"
#import <QMUIKit/QMUIKit.h>

#define MAX_COUNT 99

@interface UIViewController ()

@property(nonatomic, strong) UIBarButtonItem *wwk_leftBarUnreadCountItem;

@end

//---------------------------------------------------

@implementation UIViewController (WWKLeftBarUnreadCount)

QMUISynthesizeIdStrongProperty(wwk_leftBarUnreadCountItem, setWwk_leftBarUnreadCountItem)

-(UIImage*) createUnreadBtnImage{
    UIImage *backIndicatorImage = [UINavigationBar appearance].backIndicatorImage;
    if(0 == self.wwk_leftBarUnreadCount)
        return backIndicatorImage;
    
    CGFloat imageHeight = 24.0;
    CGFloat leftMarginForCountUI = 20;
    UIFont *countFont = UIFontMake(13);
    CGRect drawCountRect = CGRectNull;
    NSString *strUnreadCount = nil;
    if(self.wwk_leftBarUnreadCount > MAX_COUNT){
        strUnreadCount = [NSString stringWithFormat:@"%u+",MAX_COUNT];
        CGSize textSize = [strUnreadCount boundingRectWithSize:CGSizeMake(self.view.qmui_width, imageHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:countFont} context:nil].size;
        
        drawCountRect = CGRectMake(leftMarginForCountUI, 0, textSize.width + 12, imageHeight);
    }
    else{
        strUnreadCount = [NSString stringWithFormat:@"%lu",(unsigned long)self.wwk_leftBarUnreadCount];
        drawCountRect = CGRectMake(leftMarginForCountUI, 0, imageHeight, imageHeight);
    }
    
    CGSize contentSize = CGSizeMake(leftMarginForCountUI + drawCountRect.size.width, imageHeight);
    UIGraphicsBeginImageContextWithOptions(contentSize, NO, [[UIScreen mainScreen] scale]);

    //绘制返回箭头
    [backIndicatorImage drawInRect:CGRectMake(0, (imageHeight - backIndicatorImage.size.height) / 2.0, backIndicatorImage.size.width, backIndicatorImage.size.height)];
    
    //未读数背景
    [[UIColor blackColor] setFill];
    UIBezierPath*path3 = [UIBezierPath bezierPathWithRoundedRect:drawCountRect cornerRadius:imageHeight / 2.0];
    [path3 fill];
    
    //未读数
    NSMutableParagraphStyle* style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attribute = @{NSParagraphStyleAttributeName:style, NSFontAttributeName:countFont, NSForegroundColorAttributeName:[UIColor blueColor]};
    drawCountRect.origin.y = (imageHeight - countFont.lineHeight) / 2.0;
    [strUnreadCount drawInRect:drawCountRect withAttributes:attribute];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return resultImage;
}

- (void)onBackClicked{
    if (self.qmui_isPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - setter/getter
- (void)setWwk_leftBarUnreadCount:(NSUInteger)wwk_leftBarUnreadCount{
    objc_setAssociatedObject(self, @selector(wwk_leftBarUnreadCount), @(wwk_leftBarUnreadCount), OBJC_ASSOCIATION_RETAIN);
    
    QMUINavigationButton *button = nil;
    if(self.wwk_leftBarUnreadCountItem && [self.wwk_leftBarUnreadCountItem.customView isKindOfClass:[QMUINavigationButton class]]){
        button = (QMUINavigationButton *)(self.wwk_leftBarUnreadCountItem.customView);
    }
    else{
        button = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeBack];
        button.adjustsImageTintColorAutomatically = NO;
        [button addTarget:self action:@selector(onBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIImage* unreadBtnImage = [self createUnreadBtnImage];
    [button setImage:unreadBtnImage forState:UIControlStateNormal];
    [button setImage:[unreadBtnImage qmui_imageWithAlpha:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
    [button setImage:[unreadBtnImage qmui_imageWithAlpha:NavBarDisabledAlpha] forState:UIControlStateDisabled];
    
    [self resetLeftBarButtonItems:button];
}

- (NSUInteger)wwk_leftBarUnreadCount{
    return [objc_getAssociatedObject(self, @selector(wwk_leftBarUnreadCount)) unsignedIntegerValue];
}

- (void)resetLeftBarButtonItems:(QMUINavigationButton *) button{
    NSMutableArray<UIBarButtonItem*> *leftBarButtonItems = [[NSMutableArray<UIBarButtonItem*> alloc] initWithArray:self.navigationItem.leftBarButtonItems];
    [leftBarButtonItems removeObject:self.wwk_leftBarUnreadCountItem];
    
    self.wwk_leftBarUnreadCountItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [leftBarButtonItems insertObject:self.wwk_leftBarUnreadCountItem atIndex:0];
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}



@end
