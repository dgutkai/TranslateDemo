//
//  AudioRecoder.m
//  BDDureOS_OC
//
//  Created by lanmi on 2017/9/28.
//  Copyright © 2017年 com.qcymail. All rights reserved.
//

#import "AudioRecoder.h"

AudioRecoder* audioRecoder;

@implementation AudioRecoder

@synthesize aqc;

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    
    AudioRecoder * engine = (__bridge AudioRecoder *) inUserData;
    if (inNumPackets > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if (engine.aqc.run)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self initRecoder];
//        int status = AudioQueueStart(aqc.queue, NULL);
        
//        NSLog(@"AudioQueueStart = %d", status);
    }
    
    return self;
}

- (void) initRecoder{
    aqc.mDataFormat.mSampleRate = 16000;//采样率8000或16000
    aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    aqc.mDataFormat.mChannelsPerFrame = 1;///单声道
    aqc.mDataFormat.mFramesPerPacket = 1;//每一个packet一侦数据
    aqc.mDataFormat.mBitsPerChannel = 16;//每个采样点16bit量化
    aqc.mDataFormat.mBytesPerFrame = (aqc.mDataFormat.mBitsPerChannel/8) * aqc.mDataFormat.mChannelsPerFrame;
    aqc.mDataFormat.mBytesPerPacket = aqc.mDataFormat.mBytesPerFrame ;
    aqc.frameSize = kFrameSize;
    
    AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void * _Nullable)(self), NULL, kCFRunLoopCommonModes, 0, &aqc.queue);
    
    for (int i=0;i<kNumberBuffers;i++)
    {
        AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
        AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
    }
}
- (void) dealloc
{
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
    
}


- (void) start{
    aqc.recPtr = 0;
    aqc.run = 1;
    [audioData setData:[[NSData alloc] init]];
    
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop{
    AudioQueueStop(aqc.queue, true);
}

- (void) pause{
    AudioQueuePause(aqc.queue);
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue{
    long size = buffer->mAudioDataByteSize / aqc.mDataFormat.mBytesPerPacket;
    Byte *data = (Byte *) buffer->mAudioData;
    if (audioData){
        [audioData appendBytes:data length: buffer->mAudioDataByteSize];
    }else{
        audioData = [NSMutableData dataWithBytes:data length: buffer->mAudioDataByteSize];
    }
    
    if ([audioData length] > 640){
        if (self.delegate){
            NSData *d = [NSData dataWithBytes:audioData.bytes length:audioData.length];
//            [audioData setData:[[NSData alloc] init]];
//            NSLog(@"processAudioData :%@", audioData);
            [self.delegate audioRecoderData:[audioData copy]];
            [audioData setData:[[NSData alloc] init]];
//            [self stop];
        }
    }
    //NSLog(@"processAudioData :%ld", buffer->mAudioDataByteSize);
    
}
@end
