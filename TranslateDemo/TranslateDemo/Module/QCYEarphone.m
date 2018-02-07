//
//  QCYEarphone.m
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "QCYEarphone.h"
#import "PCMPlayer.h"
#import "AVCDecoder.h"
@interface QCYEarphone()
{
    BabyBluetooth *_babyBluetooth;
    long sizecount;
    long time;
    NSMutableData *_dataBuff;
    PCMPlayer *player;
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
        _dataBuff = [[NSMutableData alloc] initWithCapacity:480];
        player = [[PCMPlayer alloc] init];
    }
    return self;
}

- (void) pushData: (NSData *)data{
    @synchronized(self) {
        [_dataBuff appendData:data];
    }
}

- (NSData *) popDataWithLen: (int)len{
    @synchronized(self){
        NSData *popData;
        if ([_dataBuff length] >= len) {
            popData = [_dataBuff subdataWithRange:NSMakeRange(0, len)];
            [_dataBuff setData:[_dataBuff subdataWithRange:NSMakeRange(len, [_dataBuff length] - len)]];
        }else if ([_dataBuff length] > 0){
            popData = [[NSData alloc] initWithData:_dataBuff];
            [_dataBuff setData:[[NSData alloc] init]];
        }else{
            return nil;
        }
        return popData;
    }
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
//    [self pushData:data];
    NSLog(@"QCYEarphone.data= %@", data);
    NSData *audioData = [AVCDecoder enc2PCMWithByte:(Byte *)[data bytes] Len:(int)[data length]];
    [player pushData:audioData];
}

- (void) onConnected{
    
    [player start];
    NSLog(@"QCYEarphone.data= onConnected");
}
- (void) onDisconnected{
    
    [player stop];
}
@end
