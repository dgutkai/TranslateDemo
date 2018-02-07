//
//  PCMPlayer.m
//  TranslateDemo
//
//  Created by lanmi on 2018/2/7.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "PCMPlayer.h"

@implementation PCMPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        synlock = [[NSLock alloc] init];
        self.playState = PLAYERE_STATE_STOP;
    }
    return self;
}
-(void)start{
    if (self.playState == PLAYERE_STATE_PLING) {
        return;
    }
    [self initAudio];
    AudioQueueStart(audioQueue, NULL);
    for(int i=0;i<QUEUE_BUFFER_SIZE;i++)
    {
        [self readPCMAndPlay:audioQueue buffer:audioQueueBuffers[i]];
    }
    /*
     audioQueue使用的是驱动回调方式，即通过AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);传入一个buff去播放，播放完buffer区后通过回调通知用户,
     用户得到通知后再重新初始化buff去播放，周而复始,当然，可以使用多个buff提高效率(测试发现使用单个buff会小卡)
     */
    self.playState = PLAYERE_STATE_PLING;
}

- (void)stop{
    if (self.playState == PLAYERE_STATE_STOP) {
        return;
    }
    AudioQueueStop(audioQueue, true);
    self.playState = PLAYERE_STATE_STOP;
}
-(void)initAudio
{
    ///设置音频参数
    audioDescription.mSampleRate = 16000;//采样率8000或16000
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioDescription.mChannelsPerFrame = 1;///单声道
    audioDescription.mFramesPerPacket = 1;//每一个packet一侦数据
    audioDescription.mBitsPerChannel = 16;//每个采样点16bit量化
    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel/8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame ;
    ///创建一个新的从audioqueue到硬件层的通道
    //    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &audioQueue);///使用当前线程播
    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, CFBridgingRetain(self), nil, nil, 0, &audioQueue);//使用player的内部线程播
    ////添加buffer区
    for(int i=0;i<QUEUE_BUFFER_SIZE;i++)
    {
        int result =  AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
        NSLog(@"AudioQueueAllocateBuffer i = %d,result = %d",i,result);
    }
    [self clearData];
}

#pragma mark -
#pragma mark player call back
/*
 试了下其实可以不用静态函数，但是c写法的函数内是无法调用[self ***]这种格式的写法，所以还是用静态函数通过void *input来获取原类指针
 这个回调存在的意义是为了重用缓冲buffer区，当通过AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);函数放入queue里面的音频文件播放完以后，通过这个函数通知
 调用者，这样可以重新再使用回调传回的AudioQueueBufferRef
 */
static void AudioPlayerAQInputCallback(void *input, AudioQueueRef outQ, AudioQueueBufferRef outQB)
{
    NSLog(@"AudioPlayerAQInputCallback");
    PCMPlayer *player = (__bridge PCMPlayer *)input;
    [player checkUsedQueueBuffer:outQB];
    [player readPCMAndPlay:outQ buffer:outQB];
}

-(void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB
{
    NSData *firshData = [self popData];
    Byte *pcmDataBuffer = (Byte *)[firshData bytes];
    
    int readLength = (int)[firshData length];
    NSLog(@"read raw data size = %d",readLength);
    outQB->mAudioDataByteSize = readLength;
    Byte *audiodata = (Byte *)outQB->mAudioData;
    for(int i=0;i<readLength;i++)
    {
        audiodata[i] = pcmDataBuffer[i];
    }
    /*
     将创建的buffer区添加到audioqueue里播放
     AudioQueueBufferRef用来缓存待播放的数据区，AudioQueueBufferRef有两个比较重要的参数，AudioQueueBufferRef->mAudioDataByteSize用来指示数据区大小，AudioQueueBufferRef->mAudioData用来保存数据区
     */
    AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);
    
}

-(void)checkUsedQueueBuffer:(AudioQueueBufferRef) qbuf
{
    if(qbuf == audioQueueBuffers[0])
    {
        NSLog(@"AudioPlayerAQInputCallback,bufferindex = 0");
    }
    if(qbuf == audioQueueBuffers[1])
    {
        NSLog(@"AudioPlayerAQInputCallback,bufferindex = 1");
    }
    if(qbuf == audioQueueBuffers[2])
    {
        NSLog(@"AudioPlayerAQInputCallback,bufferindex = 2");
    }
    if(qbuf == audioQueueBuffers[3])
    {
        NSLog(@"AudioPlayerAQInputCallback,bufferindex = 3");
    }
}

-(void)pushData: (NSData *)data{
    [synlock lock];
    if (audioDataBuff == nil) {
        audioDataBuff = [[NSMutableArray alloc] initWithCapacity:100];
    }
    [audioDataBuff addObject:data];
    [synlock unlock];
}
-(void)clearData{
    [synlock lock];
    if (audioDataBuff != nil) {
        [audioDataBuff removeAllObjects];
    }
    [synlock unlock];
}
-(NSData *)popData{
    [synlock lock];
    if (audioDataBuff == nil || [audioDataBuff count] <= 0) {
        Byte *nullByte = (Byte *) alloca(EVERY_READ_LENGTH);
        memset(nullByte, 0, EVERY_READ_LENGTH);
        [synlock unlock];
        return [[NSData alloc] initWithBytes:nullByte length:EVERY_READ_LENGTH];
    }
    NSData *firstData = audioDataBuff[0];
    [audioDataBuff removeObjectAtIndex:0];
    [synlock unlock];
    return firstData;
}

@end
