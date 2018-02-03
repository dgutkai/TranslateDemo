//
//  AudioRecoder.h
//  BDDureOS_OC
//
//  Created by lanmi on 2017/9/28.
//  Copyright © 2017年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
@protocol AudioRecoderDelegate <NSObject>
- (void) audioRecoderData: (NSData *)audioData;
@end


// Audio Settings
#define kNumberBuffers      3

#define t_sample             SInt16

#define kSamplingRate       16000
#define kNumberChannels     1
#define kBitsPerChannels    (sizeof(t_sample) * 8)
#define kBytesPerFrame      (kNumberChannels * sizeof(t_sample))
//#define kFrameSize          (kSamplingRate * sizeof(t_sample))
#define kFrameSize          1000
typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
} AQCallbackStruct;


@interface AudioRecoder : NSObject{
    AVAudioSession *audioSession;
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    NSMutableData *audioData;
}
- (id) init;
- (void) start;
- (void) stop;
- (void) pause;

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (strong, nonatomic) id<AudioRecoderDelegate> delegate;
@end

extern AudioRecoder* audioRecoder;
