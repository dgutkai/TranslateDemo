//
//  QCYBle.h
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCYEarphone.h"
#import "BabyBluetooth.h"

#define SERVICE_MAIN @"CAA1" // 主服务UUID(新版本的耳机协议均使用该服务)
#define CHARACTERISTIC_WRITE @"2A06" // 写指令
#define CHARACTERISTIC_NOTIFY @"CAB2" // 消息通知

@protocol QCYDelegate
- (void) onConnected: (QCYEarphone *)earphone;
- (void) onDisconnected: (QCYEarphone *)earphone;
- (void) onFailToConnect: (QCYEarphone *)earphone;

- (void) onNotification: (QCYEarphone *)earphone;
- (void) onDiscoverToPeripherals: (QCYEarphone *)earphone;

@end

@interface QCYBle : NSObject
@property (strong, nonatomic) NSMutableDictionary *earphones;
@property (strong, nonatomic) id<QCYDelegate> delegate;
+ (instancetype) shareQCYBle;
- (void) startScan;
@end


