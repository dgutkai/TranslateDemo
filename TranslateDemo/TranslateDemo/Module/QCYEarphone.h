//
//  QCYEarphone.h
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"
#import "QCYDeviceProtocol.h"
typedef NS_ENUM(NSInteger, EarphoneState) {
    EarphoneStateDisconnected = 0,
    EarphoneStateConnecting,
    EarphoneStateConnected,
    EarphoneStateDisconnecting,
};

@interface QCYEarphone : NSObject<QCYDeviceProtocol>
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *readCharacteristic;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
- (instancetype) initWithPeripheral: (CBPeripheral *)peripheral;
- (void) connect;
- (void) disConnect;
- (void) writeData: (NSData *)data;
- (void) writeString: (NSString *)string;
@end
