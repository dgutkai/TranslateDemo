//
//  PCMPlayer.h
//  TranslateDemo
//
//  Created by lanmi on 2018/2/7.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#define QUEUE_BUFFER_SIZE 4 //队列缓冲个数
#define EVERY_READ_LENGTH 640 //每次从文件读取的长度
#define MIN_SIZE_PER_FRAME 2000 //每侦最小数据长度

typedef NS_ENUM(NSInteger, PlayerState){
    PLAYERE_STATE_PLING = 0,
    PLAYERE_STATE_STOP
};
@interface PCMPlayer : NSObject{
    NSLock *synlock ;///同步控制
    AudioStreamBasicDescription audioDescription;///音频参数
    AudioQueueRef audioQueue;//音频播放队列
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];//音频缓存
    NSMutableArray *audioDataBuff; // 音频数据缓存
    
}
@property (assign, nonatomic) PlayerState playState;
static void AudioPlayerAQInputCallback(void *input, AudioQueueRef inQ, AudioQueueBufferRef outQB);
-(void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB;
-(void)checkUsedQueueBuffer:(AudioQueueBufferRef) qbuf;
- (void)stop;
-(void)start;
-(void)pushData: (NSData *)data;
@end
