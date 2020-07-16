//
//  rootViewController.m
//  TestObject
//
//  Created by maxcwfeng on 2018/6/21.
//  Copyright © 2018年 冯驰伟. All rights reserved.
//

#import "rootViewController.h"
#import "fengchiweiViewController.h"
#import "RALocalFileSystem.h"
#import "MyWorkerClass.h"
#include "testHpp.hpp"
#include "testCPPEleven.hpp"

#define kMsg1 100
#define kMsg2 101

@interface rootViewController()<NSPortDelegate>
{
    CFAbsoluteTime startTime;
    CATransform3D _transform;
    NSString* _currentTimeString;
    NSString* _beforeTimeString;
    
    NSArray* _beforeAnimationImageArr;
    NSArray* _currentAnimationImageArr;
    
    CGFloat _jianju;
    
    UIImageView * _animationImageViewUp;
    UIImageView * _animationImageViewDown;
    UIImageView * _animationImageViewCenter;
    
    int _animationIndex;
    CGFloat _animationDelay;
    BOOL _biaozhi;
    
    UIImageView* contentView;
}

@property (strong, nonatomic) CADisplayLink * displaylink;
@property (strong, nonatomic) NSMutableDictionary * numberImageDic;

@property (strong, nonatomic) UIImageView * numberImageViewOneUp;
@property (strong, nonatomic) UIImageView * numberImageViewOneDown;
@property (strong, nonatomic) UIImageView * numberImageViewOneCenter;

@property (strong, nonatomic) UIImageView * numberImageViewTwoUp;
@property (strong, nonatomic) UIImageView * numberImageViewTwoDown;
@property (strong, nonatomic) UIImageView * numberImageViewTwoCenter;

@property (strong, nonatomic) UIImageView * numberImageViewThreeUp;
@property (strong, nonatomic) UIImageView * numberImageViewThreeDown;
@property (strong, nonatomic) UIImageView * numberImageViewThreeCenter;

@property (strong, nonatomic) UIImageView * numberImageViewFourUp;
@property (strong, nonatomic) UIImageView * numberImageViewFourDown;
@property (strong, nonatomic) UIImageView * numberImageViewFourCenter;

@property (strong, nonatomic) NSMutableArray *gifImages;

@property (nonatomic,strong) NSThread *thread;



@end

//------------------------------------------------------------------
@implementation rootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1. 创建主线程的port
    // 子线程通过此端口发送消息给主线程
    NSPort *myPort = [NSMachPort port];

    //2. 设置port的代理回调对象
    myPort.delegate = self;

    //3. 把port加入runloop，接收port消息
    [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];

    NSLog(@"---myport %@", myPort);
    //4. 启动次线程,并传入主线程的port
    MyWorkerClass *work = [[MyWorkerClass alloc] init];
    self.thread = [[NSThread alloc]initWithTarget:work selector:@selector(launchThreadWithPort:) object:myPort];
    [self.thread start];
    
    
    UIButton *tempBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 350, 100, 50)];
    tempBtn.backgroundColor = [UIColor blueColor];
    [tempBtn setTitle:@"test" forState:UIControlStateNormal];
    [tempBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempBtn];
    
    //C++11语言测试入口
    mainTest();
    
    //定时器设置
    //[NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(action:) userInfo:nil repeats:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"rootVC-1";
}

- (void)btnClick
{
    fengchiweiViewController* tempVC = [[fengchiweiViewController alloc] init];
    [self.navigationController pushViewController:tempVC animated:YES];
}

- (void)handlePortMessage:(id)message{
    NSLog(@"接到子线程传递的消息！%@",message);
    
    NSArray* array = [message valueForKeyPath:@"components"];
    for(NSData* data in array)
    {
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
    }

    //1. 消息id
    NSUInteger msgId = [[message valueForKeyPath:@"msgid"] integerValue];

    //2. 当前主线程的port
    NSPort *localPort = [message valueForKeyPath:@"localPort"];

    //3. 接收到消息的port（来自其他线程）
    NSPort *remotePort = [message valueForKeyPath:@"remotePort"];

    if (msgId == kMsg1)
    {
        //向子线的port发送消息
        [remotePort sendBeforeDate:[NSDate date]
                             msgid:kMsg2
                        components:nil
                              from:localPort
                          reserved:0];

    } else if (msgId == kMsg2){
        NSLog(@"操作2....\n");
    }
}

-(void) action:(NSTimer*) temp
{
    [self performSelector:@selector(performFunction) onThread:self.thread withObject:nil waitUntilDone:NO];
}

-(void) performFunction
{
    NSLog(@"tempNSThread");
}

- (void) pressBtn:(UIButton *) btn
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleMatch:) object:@4];
}

-(void) handleMatch:(NSNumber*) tagIDNumber
{
    NSLog(@"handleMatch");
}

-(void) kkkk
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage* img = [self captureView:_animationImageViewUp];
        [_gifImages addObject:img];
    });
    
    
    UIImage* myUIImage = [UIImage imageNamed:@"rect.png"];
    CIImage* kkk = [CIImage imageWithCGImage:myUIImage.CGImage];
    
    CGSize tempsize = myUIImage.size;
    //tempsize.width += (50 * 2.0);
    
//    CIImage* returnImage = [self drawHighlightOverlayForPoints:kkk topLeft:CGPointMake(50, tempsize.height*2 ) topRight:CGPointMake(50 + tempsize.width, tempsize.height*2) bottomLeft:CGPointMake(0, 0 ) bottomRight:CGPointMake(tempsize.width + 50 * 2, 0 )];
    

    UIGraphicsBeginImageContextWithOptions(tempsize,NO,0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 0, 0);//起始点
    CGContextAddLineToPoint (context, tempsize.width, 0);//上线
    CGContextAddLineToPoint (context, tempsize.width - 50, tempsize.height);//右线
    CGContextAddLineToPoint (context, 50.0, tempsize.height);//斜线
    CGContextClosePath(context);//收拢， 做成直角梯形
    [[UIColor colorWithPatternImage:myUIImage] setFill];
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) runAnimation
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_gifImages removeAllObjects];
    
    CGFloat imageW = 73 * 0.5;
    CGFloat imageH = 122 * 0.5 * 0.5 + 2 * _jianju;
    CGRect upViewRect = CGRectMake(110, 150, imageW, imageH);
    CGRect downViewRect = CGRectMake(110, 150 + imageH,  imageW, imageH);
    
    
    
    NSArray* imgArray = [_numberImageDic objectForKey:[_beforeTimeString substringWithRange:NSMakeRange(0,1)]];
    NSArray* imgArrayEx = [_numberImageDic objectForKey:[_currentTimeString substringWithRange:NSMakeRange(0,1)]];
    _numberImageViewOneUp = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewOneUp.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewOneUp.image = imgArray[0];
    _numberImageViewOneUp.alpha = 0.0;
    [contentView addSubview:_numberImageViewOneUp];
    
    UIView* abc = [UIView new];
    abc.frame = upViewRect;
    [contentView addSubview:abc];
    
    _numberImageViewOneDown = [[UIImageView alloc] initWithFrame:downViewRect];
    _numberImageViewOneDown.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewOneDown.image = imgArray[1];
    _numberImageViewOneDown.alpha = 0.0;
    [contentView addSubview:_numberImageViewOneDown];
    
    _numberImageViewOneCenter = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewOneCenter.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewOneCenter.image = imgArrayEx[0];
    _numberImageViewOneCenter.alpha = 0.0;
    [contentView addSubview:_numberImageViewOneCenter];
    
    /////////
    imgArray = [_numberImageDic objectForKey:[_beforeTimeString substringWithRange:NSMakeRange(1,1)]];
    imgArrayEx = [_numberImageDic objectForKey:[_currentTimeString substringWithRange:NSMakeRange(1,1)]];
    upViewRect.origin.x += (imageW + 0.5);
    _numberImageViewTwoUp = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewTwoUp.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewTwoUp.image = imgArray[0];
    _numberImageViewTwoUp.alpha = 0.0;
    [contentView addSubview:_numberImageViewTwoUp];
    
    downViewRect.origin.x += (imageW + 0.5);
    _numberImageViewTwoDown = [[UIImageView alloc] initWithFrame:downViewRect];
    _numberImageViewTwoDown.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewTwoDown.image = imgArray[1];
    _numberImageViewTwoDown.alpha = 0.0;
    [contentView addSubview:_numberImageViewTwoDown];
    
    _numberImageViewTwoCenter = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewTwoCenter.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewTwoCenter.image = imgArrayEx[0];
    _numberImageViewTwoCenter.alpha = 0.0;
    [contentView addSubview:_numberImageViewTwoCenter];
    
    /////////
    imgArray = [_numberImageDic objectForKey:[_beforeTimeString substringWithRange:NSMakeRange(2,1)]];
    imgArrayEx = [_numberImageDic objectForKey:[_currentTimeString substringWithRange:NSMakeRange(2,1)]];
    upViewRect.origin.x += (imageW + 11);
    _numberImageViewThreeUp = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewThreeUp.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewThreeUp.image = imgArray[0];
    _numberImageViewThreeUp.alpha = 0.0;
    [contentView addSubview:_numberImageViewThreeUp];
    
    downViewRect.origin.x += (imageW + 11);
    _numberImageViewThreeDown = [[UIImageView alloc] initWithFrame:downViewRect];
    _numberImageViewThreeDown.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewThreeDown.image = imgArray[1];
    _numberImageViewThreeDown.alpha = 0.0;
    [contentView addSubview:_numberImageViewThreeDown];
    
    _numberImageViewThreeCenter = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewThreeCenter.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewThreeCenter.image = imgArrayEx[0];
    _numberImageViewThreeCenter.alpha = 0.0;
    [contentView addSubview:_numberImageViewThreeCenter];
    
    /////////
    imgArray = [_numberImageDic objectForKey:[_beforeTimeString substringWithRange:NSMakeRange(3,1)]];
    imgArrayEx = [_numberImageDic objectForKey:[_currentTimeString substringWithRange:NSMakeRange(3,1)]];
    upViewRect.origin.x += (imageW + 0.5);
    _numberImageViewFourUp = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewFourUp.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewFourUp.image = imgArray[0];
    _numberImageViewFourUp.alpha = 0.0;
    [contentView addSubview:_numberImageViewFourUp];
    
    downViewRect.origin.x += (imageW + 0.5);
    _numberImageViewFourDown = [[UIImageView alloc] initWithFrame:downViewRect];
    _numberImageViewFourDown.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewFourDown.image = imgArray[1];
    _numberImageViewFourDown.alpha = 0.0;
    [contentView addSubview:_numberImageViewFourDown];
    
    _numberImageViewFourCenter = [[UIImageView alloc] initWithFrame:upViewRect];
    _numberImageViewFourCenter.layer.anchorPoint=CGPointMake(0.5, 1.0);
    _numberImageViewFourCenter.image = imgArrayEx[0];
    _numberImageViewFourCenter.alpha = 0.0;
    [contentView addSubview:_numberImageViewFourCenter];
    
    _transform = _numberImageViewOneUp.layer.transform;
    _transform.m34  = 1.0 / 100;
    
    _numberImageViewOneCenter.layer.transform = CATransform3DRotate(_transform, M_PI, 1, 0, 0);
    _numberImageViewTwoCenter.layer.transform = CATransform3DRotate(_transform, M_PI, 1, 0, 0);
    _numberImageViewThreeCenter.layer.transform = CATransform3DRotate(_transform, M_PI, 1, 0, 0);
    _numberImageViewFourCenter.layer.transform = CATransform3DRotate(_transform, M_PI, 1, 0, 0);
    
    _animationIndex = 3;
    _animationDelay = 0.5;
    self.displaylink.paused = NO;

    NSString* tempChat = [_beforeTimeString substringWithRange:NSMakeRange(3,1)];
    NSString* tempChatEx = [_currentTimeString substringWithRange:NSMakeRange(3,1)];
    
    _animationImageViewUp = _numberImageViewFourUp;
    _animationImageViewDown = _numberImageViewFourDown;
    _animationImageViewCenter = _numberImageViewFourCenter;
    
    _beforeAnimationImageArr = [_numberImageDic objectForKey:tempChat];
    _currentAnimationImageArr = [_numberImageDic objectForKey:tempChatEx];
    startTime = CFAbsoluteTimeGetCurrent();
    
    _biaozhi = YES;
}

- (void)updateAnimation
{
    CFAbsoluteTime nowTime = CFAbsoluteTimeGetCurrent() - startTime;
    
    if(_biaozhi && nowTime < 0.15)
        return;
    
    if(nowTime >= (_biaozhi ? 1.0 : 0.5))
    {
        _animationImageViewUp.alpha = 1.0;
        _animationImageViewDown.alpha = 0.0;
        _animationImageViewCenter.alpha = 1.0;
        
        CGFloat rotateRadians = M_PI;
        _animationImageViewUp.layer.transform = CATransform3DRotate(_transform, rotateRadians, 1, 0, 0);
        _animationImageViewCenter.layer.transform = CATransform3DRotate(_transform, 2 * rotateRadians, 1, 0, 0);
        
        if(--_animationIndex < 0)
        {
            self.displaylink.paused = YES;
            return;
        }
        NSString* tempChat = [_beforeTimeString substringWithRange:NSMakeRange(_animationIndex,1)];
        NSString* tempChatEx = [_currentTimeString substringWithRange:NSMakeRange(_animationIndex,1)];
        if([tempChat isEqualToString:tempChatEx])
        {
            self.displaylink.paused = YES;
            return;
        }
        
        if(2 == _animationIndex)
        {
            _animationImageViewUp = _numberImageViewThreeUp;
            _animationImageViewDown = _numberImageViewThreeDown;
            _animationImageViewCenter = _numberImageViewThreeCenter;
        }
        
        if(1 == _animationIndex)
        {
            _animationImageViewUp = _numberImageViewTwoUp;
            _animationImageViewDown = _numberImageViewTwoDown;
            _animationImageViewCenter = _numberImageViewTwoCenter;
        }
        
        if(0 == _animationIndex)
        {
            _animationImageViewUp = _numberImageViewOneUp;
            _animationImageViewDown = _numberImageViewOneDown;
            _animationImageViewCenter = _numberImageViewOneCenter;
        }
        
        _beforeAnimationImageArr = [_numberImageDic objectForKey:tempChat];
        _currentAnimationImageArr = [_numberImageDic objectForKey:tempChatEx];
        
        _animationDelay = 0.0;
        startTime = CFAbsoluteTimeGetCurrent();
        
        _biaozhi = NO;
        return;
    }
    
    
    if(nowTime < _animationDelay)
    {
        if(3 == _animationIndex)
        {
            _numberImageViewOneUp.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewOneDown.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewTwoUp.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewTwoDown.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewThreeUp.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewThreeDown.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewFourUp.alpha = (nowTime - 0.15) / 0.26;
            _numberImageViewFourDown.alpha = (nowTime - 0.15) / 0.26;
        }
    }
    else
    {
        CGFloat rotateRadians = (nowTime - _animationDelay) / 0.5 * 180 * M_PI/180;
        _animationImageViewUp.layer.transform = CATransform3DRotate(_transform, rotateRadians, 1, 0, 0);
        
        _animationImageViewCenter.layer.transform = CATransform3DRotate(_transform, M_PI + rotateRadians, 1, 0, 0);
        _animationImageViewCenter.alpha = (nowTime - _animationDelay) / 0.5;
        
        if(nowTime - _animationDelay <= 0.25)
        {
            _animationImageViewUp.alpha = 1.0 - (nowTime - _animationDelay) / 0.25;
        }
        else
        {
            _animationImageViewUp.image = _currentAnimationImageArr[2];
            _animationImageViewUp.alpha = ((nowTime - _animationDelay) - 0.25) / 0.25;
            _animationImageViewDown.alpha = 1.0 - _animationImageViewUp.alpha;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage* img = [self captureView:_animationImageViewUp];
        [_gifImages addObject:img];
    });
}

-(void) createSubtitleItemImage:(NSString*) numberString
{
    if(nil == _numberImageDic)
        _numberImageDic = [NSMutableDictionary dictionary];
    
    NSArray* numberImageArray = [_numberImageDic objectForKey:numberString];
    if(numberImageArray)
        return;
    
    UIImage* beijingUpImage = [UIImage imageNamed:@"beijingUp.png"];
    UIImage* beijingDownImage = [UIImage imageNamed:@"beijingDown.png"];

    CGSize size = CGSizeMake(beijingUpImage.size.width, beijingUpImage.size.height * 2.0);
    
//    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    [ChaniseText drawAtPoint:CGPointMake((size.width - sizeChanise.width) / 2.0, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:25],NSForegroundColorAttributeName:[UIColor whiteColor]}];
//
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    [EngleseText drawAtPoint:CGPointMake((size.width - sizeEnglese.width) / 2.0, sizeChanise.height + 3.5) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSKernAttributeName:@(3), NSForegroundColorAttributeName:[UIColor whiteColor]}];
//
//    self.drawImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [beijingUpImage drawAtPoint:CGPointMake(0, 0)];
    [beijingDownImage drawAtPoint:CGPointMake(0, beijingUpImage.size.height + 1)];
                                            
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [numberString drawAtPoint:CGPointMake(0, -8) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:60 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //up
    CGImageRef sourceImageRef = [newImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, 0, CGImageGetWidth(sourceImageRef), CGImageGetHeight(sourceImageRef) / 2.0));
    UIImage *upImage = [self wuliaoImae:[UIImage imageWithCGImage:newImageRef]];
    
    //down
    newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, CGImageGetHeight(sourceImageRef) / 2.0 + 1, CGImageGetWidth(sourceImageRef), CGImageGetHeight(sourceImageRef) / 2.0));
    UIImage *downImage = [self wuliaoImae:[UIImage imageWithCGImage:newImageRef]];
    
    UIImage *rotateDownImage = [[UIImage alloc] initWithCGImage:newImageRef scale:1.0 orientation:UIImageOrientationDownMirrored];
    
    
    numberImageArray = @[upImage, downImage, rotateDownImage];
    [_numberImageDic setObject:numberImageArray forKey:numberString];
}

-(UIImage*) wuliaoImae:(UIImage*) inputImage
{
    CGSize size = CGSizeMake(inputImage.size.width, inputImage.size.height);
    size.height += (2 * _jianju);
    
    UIGraphicsBeginImageContext(size);
    
    [inputImage drawAtPoint:CGPointMake(0, _jianju)];

    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void) initCurrentAndbeforeTimeTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmm"];
    NSDate *datenow = [NSDate date];
    NSDate *beforeDatenow =  [datenow initWithTimeInterval:60 sinceDate:datenow];

//    _currentTimeString = [formatter stringFromDate:datenow];
//    _beforeTimeString = [formatter stringFromDate:beforeDatenow];
    
    _currentTimeString = @"2345";
    _beforeTimeString = @"1234";
}

-(void) initNumberImages
{
    for(int i =0; i < [_currentTimeString length]; i++)
    {
        [self createSubtitleItemImage:[_currentTimeString substringWithRange:NSMakeRange(i,1)]];
    }
    
    for(int i =0; i < [_beforeTimeString length]; i++)
    {
        [self createSubtitleItemImage:[_beforeTimeString substringWithRange:NSMakeRange(i,1)]];
    }
}

-(CADisplayLink *)displaylink {
    if (!_displaylink) {
        _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation)];
        _displaylink.paused = YES;
        [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displaylink.preferredFramesPerSecond = 30;
    }
    return _displaylink;
}

- (UIImage*)captureView:(UIView*)theView
{
    UIView* kk = [theView snapshotViewAfterScreenUpdates:NO];
    
    UIGraphicsBeginImageContextWithOptions(kk.frame.size, NO, [[UIScreen mainScreen] scale]);
    [theView drawViewHierarchyInRect:kk.bounds afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapshot;
}

- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
//    CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:0 green:1 blue:0 alpha:0.6]];
//    overlay = [overlay imageByCroppingToRect:image.extent];
//    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
//    return [overlay imageByCompositingOverImage:image];
    
    //CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform" keysAndValues:@"inputImage", image, @"inputTopLeft", [CIVector vectorWithCGPoint:topLeft], @"inputTopRight", [CIVector vectorWithCGPoint:topRight], @"inputBottomRight", [CIVector vectorWithCGPoint:bottomLeft], @"inputBottomLeft", [CIVector vectorWithCGPoint:bottomRight], nil];
    CIImage *outputImage = [filter outputImage];
    //CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    //CGImageRelease(cgimg);
    
    return outputImage;
}

@end
