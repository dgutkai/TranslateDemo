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
    if (data == nil) {
        return;
    }
    [self.peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) onNotificationWithData: (NSData *)data{

    NSLog(@"QCYEarphone.data= %@", data);
    
    
}
@end
