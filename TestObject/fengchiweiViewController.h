//
//  fengchiweiViewController.h
//  TestObject
//
//  Created by 冯驰伟 on 2017/12/25.
//  Copyright © 2017年 冯驰伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kNumberAudioQueueBuffers 3  //定义了三个缓冲区

@interface fengchiweiViewController : UIViewController
{
    AudioStreamBasicDescription _recordFormat;///音频参数
    AudioQueueRef _audioQueue;//音频播放队列
    AudioQueueBufferRef _audioBuffers[kNumberAudioQueueBuffers];
}

@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) double bufferDurationSeconds;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSMutableData* audioData;
@property (nonatomic, strong) AVAudioPlayer *player;

-(NSMutableData*) converTo16000Rate:(NSData*)srcData sampleRate:(int) sampleRate;

@end
