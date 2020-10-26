//
//  fengchiweiViewController.m
//  TestObject
//
//  Created by 冯驰伟 on 2017/12/25.
//  Copyright © 2017年 冯驰伟. All rights reserved.
//

#import "fengchiweiViewController.h"
#import "lame.h"


#define kDefaultBufferDurationSeconds 0.1279   //调整这个值使得录音的缓冲区大小为2048bytes
#define kDefaultSampleRate 44100   //定义采样率为
#define NewkDefaultSampleRate 44100

#define EPSILON 0.000001 //根据精度需要

SystemSoundID soundId;

void completionCallback(SystemSoundID  ssID, void *clientData)
{
}

@interface fengchiweiViewController()
{
    CFAbsoluteTime startTime;
    
    CGFloat fontJianju;
    CGFloat imageX;
    
    CGFloat imageMaxX;
    
    BOOL   needStopFrist;
}

@property (strong, nonatomic) CADisplayLink * _Nullable displaylink;

//地址贴纸1
//@property(nonatomic,strong) UILabel     * locationLabel;
//@property(nonatomic,strong) UIImageView     * timeImageView;


//地址贴纸2
@property(nonatomic,strong) UIView         * contentView;
@property(nonatomic,strong) UIImageView     * triangleLeftView;
@property(nonatomic,strong) UIImageView     * triangleRightView;

@property(nonatomic,strong) UIImage         * drawImage;
@property(nonatomic,strong) UIImageView    * drawImageView;



@end

@implementation fengchiweiViewController

-(void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor grayColor];
    self.sampleRate = kDefaultSampleRate;
    self.bufferDurationSeconds = kDefaultBufferDurationSeconds;

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(10, 100, 300, 50);
    button1.backgroundColor = [UIColor whiteColor];
    [button1 setTitle:@"录音开始" forState:UIControlStateNormal];
    [button1 setTitle:@"录音开始" forState:UIControlStateHighlighted];
    [button1 setTintColor:[UIColor redColor]];
    [button1 addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(10, 170, 300, 50);
    [button2 setTitle:@"录音结束" forState:UIControlStateNormal];
    [button2 setTitle:@"录音结束" forState:UIControlStateHighlighted];
    [button2 setTintColor:[UIColor redColor]];
    [button2 addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame = CGRectMake(10, 240, 300, 50);
    [button3 setTitle:@"播放录音" forState:UIControlStateNormal];
    [button3 setTitle:@"播放录音" forState:UIControlStateHighlighted];
    [button3 setTintColor:[UIColor redColor]];
    [button3 addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4.frame = CGRectMake(10, 310, 300, 50);
    [button4 setTitle:@"转mp3" forState:UIControlStateNormal];
    [button4 setTitle:@"转mp3" forState:UIControlStateHighlighted];
    [button4 setTintColor:[UIColor redColor]];
    [button4 addTarget:self action:@selector(audio_PCMtoMP3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
    [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:(int)self.sampleRate];
    
    
    
    ////////////////////////////////////////////////////////////////////////
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button5.frame = CGRectMake(10, 380, 300, 50);
    [button5 setTitle:@"开始动画" forState:UIControlStateNormal];
    [button5 setTitle:@"开始动画" forState:UIControlStateHighlighted];
    [button5 setTintColor:[UIColor redColor]];
    [button5 addTarget:self action:@selector(runAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    
    
    //地址贴纸1
//    self.locationLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 470, self.view.bounds.size.width, 80)];
//    _locationLabel.numberOfLines=2;
//    _locationLabel.backgroundColor = [UIColor clearColor];
//    _locationLabel.textColor = [UIColor whiteColor];
//    _locationLabel.textAlignment = NSTextAlignmentCenter;
//    _locationLabel.font = [UIFont systemFontOfSize:24];
//    _locationLabel.alpha = 0.0;
//    _locationLabel.attributedText = [[NSAttributedString alloc] initWithString:@"你的所在位置" attributes:@{NSKernAttributeName:@0.5f}];
//    [self.view addSubview:_locationLabel];
//
//    CGSize size = [@"SHANGRL-LA" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSKernAttributeName:@(fontJianju)}];
//    CGFloat imageW = 17;
//    CGFloat imageH = 22;
//    imageX = (_locationLabel.frame.size.width - size.width - imageW) / 2.0 - 7;
//
//    self.timeImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageW, imageH)];
//    _timeImageView.center = CGPointMake(imageX, _locationLabel.frame.size.height / 2.0);
//    _timeImageView.image = [UIImage imageNamed:@"location_icon"];
//    _timeImageView.backgroundColor = [UIColor clearColor];
//    _timeImageView.alpha = 0.0;
//    [_locationLabel addSubview:_timeImageView];
    

    //地址贴纸2
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 420, self.view.frame.size.width, 300)];
    [self.view addSubview:_contentView];
    
    self.triangleLeftView = [UIImageView new];
    self.triangleRightView = [UIImageView new];
    
    CGFloat imageW = 19 / 2.0;
    CGFloat imageH = 37 / 2.0;
    
    _triangleRightView.backgroundColor = [UIColor clearColor];
    _triangleLeftView.backgroundColor = [UIColor clearColor];
    
    _triangleRightView.alpha = 0.0;
    _triangleLeftView.alpha = 0.0;
    
    _triangleLeftView.frame = CGRectMake(_contentView.frame.size.width / 2.0 - imageW, _contentView.frame.size.height - 37, imageW, imageH);
    _triangleRightView.frame = CGRectMake(_contentView.frame.size.width / 2.0, _contentView.frame.size.height - 37, imageW, imageH);
    
    _triangleRightView.image = [UIImage imageNamed:@"triangle"];
    _triangleLeftView.image = [UIImage imageNamed:@"triangle"];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, -1, 1);
    _triangleLeftView.transform = transform;
    
    [_contentView addSubview:_triangleRightView];
    [_contentView addSubview:_triangleLeftView];
    
    self.drawImageView = [UIImageView new];
    _drawImageView.center = CGPointMake(_triangleRightView.frame.origin.x, _triangleRightView.center.y - 72);
    _drawImageView.clipsToBounds = YES;
    _drawImageView.contentMode =  UIViewContentModeCenter;
    [_contentView addSubview:_drawImageView];
}

- (void) runAnimation
{
    needStopFrist = NO;
    self.displaylink.paused = NO;
    startTime = CFAbsoluteTimeGetCurrent();
    
    //地址贴纸1
//    _locationLabel.alpha = 0.0;
//    _timeImageView.alpha = 0.0;
//
//    fontJianju = 0.5;
//    CGSize size = [@"SHANGRL-LA" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24], NSKernAttributeName:@(fontJianju)}];
//    CGFloat imageW = 17;
//    imageX = (_locationLabel.frame.size.width - size.width - imageW) / 2.0 - 7;
    
    
    //地址贴纸2
    CGFloat imageW = 19 / 2.0;
    CGFloat imageH = 37 / 2.0;
    
    _triangleRightView.alpha = 0.0;
    _triangleLeftView.alpha = 0.0;
    
    _triangleLeftView.frame = CGRectMake(_contentView.frame.size.width / 2.0 - imageW, _contentView.frame.size.height - 37, imageW, imageH);
    _triangleRightView.frame = CGRectMake(_contentView.frame.size.width / 2.0, _contentView.frame.size.height - 37, imageW, imageH);
    
    NSString* ChaniseText = @"深圳市";
    NSString* EngleseText = @"SHENZHEN";
    
    CGSize sizeChanise = [ChaniseText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:25]}];
    CGSize sizeEnglese = [EngleseText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSKernAttributeName:@(3)}];
    
    _drawImageView.frame = CGRectMake(0, 0, 0, sizeChanise.height + sizeEnglese.height + 3.5);
    _drawImageView.center = CGPointMake(_triangleRightView.frame.origin.x, _triangleRightView.center.y - 72);
    
    imageMaxX = (_contentView.frame.size.width - (sizeChanise.width > sizeEnglese.width ? sizeChanise.width : sizeEnglese.width)) / 2.0 - imageW;
}

- (void)updateAnimation
{
    CFAbsoluteTime nowTime = CFAbsoluteTimeGetCurrent() - startTime;
    
    //地址贴纸1
//    if(nowTime >= 1.85 || nowTime < 0.18)
//    {
//        if(nowTime >= 1.85)
//            _displaylink.paused = YES;
//
//        return;
//    }
//
//    if(NO == needStopFrist)
//    {
//        fontJianju = fontJianju + 0.06 / nowTime;  //0.06 就是反比例的K值
//        if (fontJianju - 3.5 > 0)
//        {
//            needStopFrist = YES;
//            fontJianju = 3.5;
//        }
//
//
//        _locationLabel.attributedText = [[NSAttributedString alloc] initWithString:@"SHANGRL-LA" attributes:@{NSKernAttributeName:@(fontJianju)}];
//        imageX = imageX - 0.4 / nowTime;
//        _timeImageView.center = CGPointMake(imageX, _timeImageView.center.y);
//    }
//
//    _locationLabel.alpha = _locationLabel.alpha + 0.015 / nowTime;
//    _timeImageView.alpha = _timeImageView.alpha + 0.015 / nowTime;
    
    //地址贴纸2
    if(NO == needStopFrist)
    {
        CGFloat yValue = 0.3 / nowTime;
        if(yValue > 10.0)
            return;
        
        CGFloat newCenterY = _triangleRightView.center.y - (10 - yValue);
        CGFloat xiandingzhi = (_contentView.frame.size.height - 37 / 2.0) - 72;
        if (newCenterY - xiandingzhi < 0)
        {
            newCenterY = xiandingzhi;
            static int tempInt = 0;
            if(nowTime > 0.8)
            {
                needStopFrist = YES;
                if(nil == _drawImage)
                {
                    [self createSubtitleItemImage];
                    _drawImageView.image = _drawImage;
                }
                
                CGPoint tempPoint = _drawImageView.center;
                _drawImageView.frame = CGRectMake(0, 0, _drawImageView.frame.size.width + 36, _drawImageView.frame.size.height);
                _drawImageView.center = tempPoint;
                _triangleRightView.frame = CGRectMake(_triangleRightView.frame.origin.x + 18, _triangleRightView.frame.origin.y, _triangleRightView.frame.size.width, _triangleRightView.frame.size.height);
                _triangleLeftView.frame = CGRectMake(_triangleLeftView.frame.origin.x - 18, _triangleLeftView.frame.origin.y, _triangleLeftView.frame.size.width, _triangleLeftView.frame.size.height);
            }
            else
            {
                BOOL run = tempInt % 10 == 0;
                if(run)
                {
                    newCenterY += ((0 == (tempInt / 10) % 2) ? 1 : -1);
                }
                tempInt++;
            }
        }
        
        _triangleRightView.center = CGPointMake(_triangleRightView.center.x, newCenterY);
        _triangleLeftView.center = CGPointMake(_triangleLeftView.center.x, newCenterY);
        _drawImageView.center = CGPointMake(_drawImageView.center.x, newCenterY);

        _triangleRightView.alpha += 0.25;
        _triangleLeftView.alpha += 0.25;
    }
    else
    {
        CGFloat speed = 3.6;
        
        CGPoint tempCenter = _drawImageView.center;
        _drawImageView.frame = CGRectMake(0, 0, _drawImageView.frame.size.width + speed * 2, _drawImageView.frame.size.height);
        _drawImageView.center = tempCenter;
        
        if(_drawImageView.frame.origin.x >= imageMaxX)
        {
            _triangleRightView.frame = CGRectMake(_triangleRightView.frame.origin.x + speed, _triangleRightView.frame.origin.y, _triangleRightView.frame.size.width, _triangleRightView.frame.size.height);
            _triangleLeftView.frame = CGRectMake(_triangleLeftView.frame.origin.x - speed, _triangleLeftView.frame.origin.y, _triangleLeftView.frame.size.width, _triangleLeftView.frame.size.height);
            _displaylink.paused = YES;
            return;
        }
    }
}

-(void) createSubtitleItemImage
{
    NSString* ChaniseText = @"深圳市";
    NSString* EngleseText = @"SHENZHEN";
    
    CGSize sizeChanise = [ChaniseText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:25]}];
    CGSize sizeEnglese = [EngleseText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSKernAttributeName:@(3)}];
    
    CGSize size = CGSizeMake(sizeChanise.width > sizeEnglese.width ? sizeChanise.width : sizeEnglese.width, sizeChanise.height + sizeEnglese.height + 3.5);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [ChaniseText drawAtPoint:CGPointMake((size.width - sizeChanise.width) / 2.0, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:25],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    [EngleseText drawAtPoint:CGPointMake((size.width - sizeEnglese.width) / 2.0, sizeChanise.height + 3.5) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSKernAttributeName:@(3), NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
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

- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(int)sampeleRate
{
    self.audioData = [NSMutableData new];
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    //设置采样率，这里先获取系统默认的测试下 //TODO:
    //采样率的意思是每秒需要采集的帧数
    _recordFormat.mSampleRate = sampeleRate;//[[AVAudioSession sharedInstance] sampleRate];
    //设置通道数,这里先使用系统的测试下 //TODO:
    _recordFormat.mChannelsPerFrame = 1;//(UInt32)[[AVAudioSession sharedInstance] inputNumberOfChannels];
    //    NSLog(@"sampleRate:%f,通道数:%d",_recordFormat.mSampleRate,_recordFormat.mChannelsPerFrame);
    //设置format，怎么称呼不知道。
        _recordFormat.mFormatID = inFormatID;
    if (inFormatID == kAudioFormatLinearPCM){
        //这个屌属性不知道干啥的。，//要看看是不是这里属性设置问题
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
    }
}

-(void)startRecording
{
    NSError *error = nil;
    //设置audio session的category
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];//注意，这里选的是AVAudioSessionCategoryPlayAndRecord参数，如果只需要录音，就选择Record就可以了，如果需要录音和播放，则选择PlayAndRecord，这个很重要
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }
_recordFormat.mSampleRate = self.sampleRate;//设置采样率
//初始化音频输入队列
    AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);//inputBufferHandler这个是回调函数名
//计算估算的缓存区大小
    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);//返回大于或者等于指定表达式的最小整数
    int bufferByteSize = frames * _recordFormat.mBytesPerFrame;//缓冲区大小在这里设置，这个很重要，在这里设置的缓冲区有多大，那么在回调函数的时候得到的inbuffer的大小就是多大。
    NSLog(@"缓冲区大小:%d",bufferByteSize);
//创建缓冲器
    for (int i = 0; i < kNumberAudioQueueBuffers; i++){
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);//将 _audioBuffers[i]添加到队列中
    }
// 开始录音
    AudioQueueStart(_audioQueue, NULL);
self.isRecording = YES;
}

void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{

    fengchiweiViewController* delegetVC = (__bridge fengchiweiViewController*) inUserData;
    if (inNumPackets > 0) {
        NSLog(@"in the callback the current thread is %@\n",[NSThread currentThread]);
        
        NSMutableData* tempData = [NSMutableData new];
        [tempData appendBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        
        //tempData = [delegetVC converTo16000Rate:tempData sampleRate:kDefaultSampleRate];
        [delegetVC.audioData appendBytes:tempData.bytes length:tempData.length];
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

-(NSMutableData*) converTo16000Rate:(NSData*)srcData sampleRate:(int) sampleRate
{
    {
        short* input_samples = (short*)srcData.bytes;
        int in_samples = (int)(srcData.length / 2);
        short* output_samples = (short*)malloc(in_samples * 2 * 16000 / sampleRate);
        int out_samples = in_samples * 16000 /sampleRate;
        
        int osample;
        /* 16+16 fixed point math */
        uint32_t isample = 0;
        uint32_t istep = ((in_samples-2) << 16)/(out_samples-2);
        
        for (osample = 0; osample < out_samples - 1; osample++) {
            int s1;
            int s2;
            int16_t os;
            uint32_t t = isample&0xffff;
            
            s1 = input_samples[(isample >> 16)];
            s2 = input_samples[(isample >> 16)+1];
            
            os = (s1 * (0x10000-t)+ s2 * t) >> 16;
            output_samples[osample] = os;
            
            isample += istep;
        }
        output_samples[out_samples-1] = input_samples[in_samples-1];
        
        NSMutableData* outputData = [NSMutableData dataWithBytes:output_samples length:out_samples * 2];
        free(output_samples);
        return outputData;
    }
}


-(void)stopRecording
{
    NSLog(@"stop recording out\n");//为什么没有显示
    if (self.isRecording)
    {
        self.isRecording = NO;
        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);//移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        NSString *wavFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fengchiwei.wav"];
        [[NSFileManager defaultManager] removeItemAtPath:wavFilePath error:nil];
        [self writeWaveHeader:wavFilePath data:_audioData];
        
        [_audioData resetBytesInRange:NSMakeRange(0, _audioData.length)];
        [_audioData setLength:0];
    }
}

-(void) writeWaveHeader:(NSString*)wavFile data:(NSData*) encodedMutableData
{
    FILE* fpwave = NULL;
    const char *waveFile = [wavFile UTF8String];

    fpwave = fopen(waveFile,"wb");

    int32_t long_temp;
    int16_t short_temp;
    int16_t BlockAlign;
    int bits=16;
    int32_t fileSize;
    int32_t audioDataSize;
    
    audioDataSize = (int32_t)[encodedMutableData length];
    fileSize=audioDataSize+36;

    fwrite("RIFF",sizeof(char),4,fpwave);
    fwrite(&fileSize,sizeof(int32_t),1,fpwave);
    fwrite("WAVE",sizeof(char),4,fpwave);
    fwrite("fmt ",sizeof(char),4,fpwave);

    long_temp=16;
    fwrite(&long_temp,sizeof(int32_t),1,fpwave);

    short_temp=0x01;
    fwrite(&short_temp,sizeof(int16_t),1,fpwave);

    short_temp=1;
    fwrite(&short_temp,sizeof(int16_t),1,fpwave);

    long_temp=NewkDefaultSampleRate;
    fwrite(&long_temp,sizeof(int32_t),1,fpwave);

    long_temp=(bits/8)*1*NewkDefaultSampleRate;
    fwrite(&long_temp,sizeof(int32_t),1,fpwave);

    BlockAlign=2;;
    fwrite(&BlockAlign,sizeof(int16_t),1,fpwave);

    short_temp=(bits);
    fwrite(&short_temp,sizeof(int16_t),1,fpwave);

    fwrite("data",sizeof(char),4,fpwave);
    fwrite(&audioDataSize,sizeof(int32_t),1,fpwave);

    fseek(fpwave,44,SEEK_SET);
    
    char *pcmdata = (char*)[encodedMutableData bytes];
    fwrite(pcmdata,sizeof(char),audioDataSize,fpwave);

    fclose(fpwave);
}

-(void) playAudio
{
    //定义URl，要播放的音乐文件是fengchiwei.wav
    NSString *wavFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fengchiwei.wav"];
    NSURL * audioPath = [NSURL fileURLWithPath:wavFilePath];

    //NSURL *audioPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]pathForResource:@"fengchiwei" ofType:@"wav"]];
    //定义SystemSoundID
    SystemSoundID soundId;
    //C语言的方法调用
    //注册服务
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &soundId);
    //增添回调方法
    AudioServicesAddSystemSoundCompletion(soundId,NULL, NULL, completionCallback,NULL);
    //开始播放
    AudioServicesPlaySystemSound(soundId);
}

- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fengchiwei.wav"];
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/linzeyun.mp3"];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;

        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;//8192
        const int MP3_SIZE = 8192;//8192
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 7500.0);//采样播音速度，值越大播报速度越快，反之。
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSError *playerError;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:mp3FilePath] error:&playerError];
        self.player = audioPlayer;
        _player.volume = 3.0f;
        if (_player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        else
        {
            [_player play];
        }
    }
}

void AmplifyPCMData(Byte* pData, int nLen, float multiple)
{
    int nCur = 0;
    while (nCur < nLen)
    {
        short* volum = (short*)(pData + nCur);
        
        short newValue = 0;
        long dwData = (*volum) * multiple;
        if (dwData < -0x8000)
        {
            newValue = -0x8000;
        }
        else if (dwData > SHRT_MAX)//爆音的处理
        {
            newValue = SHRT_MAX;
        }
        else
        {
            newValue = (*volum) * multiple;
        }
        
        *(short*)(pData + nCur) = newValue;
        nCur += 2;
    }
}

@end
