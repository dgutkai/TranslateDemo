//
//  AVCDecoder.m
//  TranslateDemo
//
//  Created by lanmi on 2018/2/7.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "AVCDecoder.h"
#import "avc_decoder_sample.h"
@implementation AVCDecoder

+ (instancetype) shareQCYBle {
    
    static AVCDecoder * avcDecoder = nil;
    //添加线程锁
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        avcDecoder = [[AVCDecoder alloc] init];
    });
    return avcDecoder;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void) initAVCDecoder{
    if (avc_decode_init() != 0) {
        NSLog(@"avc decode init fail");
    }
}

+ (void) destoryDecoder{
    avc_decode_destory();
}

+ (NSData *)enc2PCMWithByte: (Byte *)bytedata Len: (int)len{
    unsigned int outlen = 0;
    Byte *pOut = (Byte *)alloca(640);
    int result = airohadec_enc_to_pcm(bytedata, len, pOut, &outlen);
    if (result < 0) {
        NSLog(@"decode fail");
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBytes:pOut length:outlen];
    return data;
}
@end
