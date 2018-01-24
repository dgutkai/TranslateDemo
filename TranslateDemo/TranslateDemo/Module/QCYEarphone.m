//
//  QCYEarphone.m
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "QCYEarphone.h"

@interface QCYEarphone()
{
    BabyBluetooth *_babyBluetooth;
    CBCharacteristic *_readCharacteristic;
    CBCharacteristic *_writeCharacteristic;
    
    long sizecount;
    long time;
}
@end
@implementation QCYEarphone


- (instancetype)initWithPeripheral: (CBPeripheral *)peripheral{
    self = [super init];
    if (self) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
        self.peripheral = peripheral;
        sizecount = 0;
        time = [[NSDate date] timeIntervalSince1970]*1000;
    }
    return self;
}

- (void) connect{
    if (self.peripheral.state == CBPeripheralStateDisconnected){
       _babyBluetooth.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
}

- (void) disConnect{
    if (self.peripheral.state == CBPeripheralStateConnected || self.peripheral.state == CBPeripheralStateConnecting ){
        [_babyBluetooth cancelPeripheralConnection:self.peripheral];
    }
}

- (void) writeString: (NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self writeData:data];
}
- (void) writeData: (NSData *)data{
    if (_writeCharacteristic == nil) {
        return;
    }
    [self.peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) onNotificationWithData: (NSData *)data{
    sizecount += data.length;
    long current = [[NSDate date] timeIntervalSince1970]*1000;
    int dx = current - time;
//    NSLog(@"QCYEarphone.current= %d, time = %d", current, time);
    if (dx >= 3000) {
        float px = (sizecount * 1.0f) / dx;
        NSLog(@"QCYEarphone.Data.speed = %f", px);
        sizecount = 0;
        time = current;
    }
    
}
@end
