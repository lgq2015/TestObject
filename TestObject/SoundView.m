//
//  SoundView.m
//  Sound
//
//  Created by jiayi on 13-4-10.
//  Copyright (c) 2013年 jiayi. All rights reserved.
//

#import "SoundView.h"
#import "lame.h"

@implementation SoundViewF
@synthesize player;
@synthesize recordedFile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
        
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    
    
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
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 16000);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            NSMutableData* data = [NSMutableData new];
            [data appendBytes:mp3_buffer length:write];
            
            NSData* dataEx = [self converTo16000Rate:data sampleRate:44100];
            fwrite(dataEx.bytes, dataEx.length, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [playButton setEnabled:YES];
        NSError *playerError;
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:mp3FilePath] error:&playerError];
        self.player = audioPlayer;
        player.volume = 1.0f;
        if (player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        player.delegate = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *makeSoundButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 200, 100, 50)];
    makeSoundButton.backgroundColor = [UIColor blueColor];
    [makeSoundButton setTitle:@"按下录音" forState:UIControlStateNormal];
    [makeSoundButton setTitle:@"松开录制完成" forState:UIControlStateHighlighted];
    [makeSoundButton addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [makeSoundButton addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 50)];
    playButton = pButton;
    [playButton setEnabled:NO];
    playButton.backgroundColor = [UIColor blueColor];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    UIButton *zButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 350, 100, 50)];
    zButton.backgroundColor = [UIColor blueColor];
    [zButton setTitle:@"转mp3" forState:UIControlStateNormal];
    [zButton addTarget:self action:@selector(audio_PCMtoMP3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zButton];
    
    
    
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    NSLog(@"%@",path);
    self.recordedFile = [[NSURL alloc] initFileURLWithPath:path];
    NSLog(@"%@",recordedFile);
    
    
	// Do any additional setup after loading the view.
}
- (void)playPause
{
    //If the track is playing, pause and achange playButton text to "Play"
    if([player isPlaying])
    {
        [player pause];
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    //If the track is not player, play the track and change the play button to "Pause"
    else
    {
        [player play];
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

-(void)touchDown
{
    [playButton setEnabled:NO];
    NSLog(@"==%@==",recordedFile);
    
    session = [AVAudioSession sharedInstance];
    session.delegate = self;
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    /*
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                                        [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                         [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                                        nil];
     */
    //录音设置
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:16000] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:nil];
    [recorder prepareToRecord];
    [recorder record];
}
-(void)touchUp
{
    [recorder stop];
    
    if(recorder)
    {
        recorder = nil;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
}
@end
