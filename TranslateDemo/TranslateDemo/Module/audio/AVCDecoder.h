//
//  AVCDecoder.h
//  TranslateDemo
//
//  Created by lanmi on 2018/2/7.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVCDecoder : NSObject
+ (instancetype) shareQCYBle;
+ (void) destoryDecoder;
+ (void) initAVCDecoder;
+ (NSData *)enc2PCMWithByte: (Byte *)bytedata Len: (int)len;
@end
