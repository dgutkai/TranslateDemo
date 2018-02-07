//
//  QCYBle.m
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "QCYBle.h"
#import "AVCDecoder.h"
@interface QCYBle()
{
    
}

@property BabyBluetooth *baby;
@end
@implementation QCYBle

+ (instancetype) shareQCYBle {
    
    static QCYBle * qcyBle = nil;
    //添加线程锁
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        qcyBle = [[QCYBle alloc] init];
        [AVCDecoder initAVCDecoder];
    });
    return qcyBle;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化BabyBluetooth 蓝牙库
        self.baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        self.earphones = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}
- (void) startScan{
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    self.baby.scanForPeripherals().begin();

}
- (QCYEarphone *) getEarphoneWithPeripheral: (CBPeripheral *)peripheral{
    return (QCYEarphone *)self.earphones[peripheral.identifier.UUIDString];
}
//设置蓝牙委托
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    void (^notificationBlock)(CBPeripheral*, CBCharacteristic*, NSError*) = ^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        for (NSString *ekey in weakSelf.earphones) {
            QCYEarphone *e = (QCYEarphone *)weakSelf.earphones[ekey];
            if (![e.peripheral isEqual:peripheral]) {
                [e writeData:characteristics.value];
            }
        }
        QCYEarphone *earphone = [self getEarphoneWithPeripheral:peripheral];
        if (earphone != nil) {
            [earphone onNotificationWithData:characteristics.value];
            if (weakSelf.delegate != nil) {
                [weakSelf.delegate onNotification:earphone];
            }
        }
        NSLog(@"characteristics.value = %@", characteristics.value);
    };
    //设置扫描到设备的委托
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        QCYEarphone *earphone = [[QCYEarphone alloc] initWithPeripheral:peripheral];
        if (self.earphones[peripheral.identifier.UUIDString] == nil) {
            [weakSelf.earphones setValue:earphone forKey:peripheral.identifier.UUIDString];
            if (weakSelf.delegate != nil){
                [weakSelf.delegate onDiscoverToPeripherals:earphone];
            }
        }
    }];
    
    //过滤器
    //设置查找设备的过滤器
    [self.baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
        //if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //    return YES;
        //}
        //return NO;
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
        if (peripheralName.length >1) {
            return YES;
        }
        return NO;
    }];
    
    [self.baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            NSLog(@"设备打开成功，开始扫描设备");
        }else{
            NSLog(@"设备关闭，关闭扫描设备");
        }
    }];
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象
    [self.baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        if (self.delegate != nil) {
            QCYEarphone *earphone = [weakSelf getEarphoneWithPeripheral:peripheral];
            if (earphone != nil) {
                [earphone onConnected];
                [weakSelf.delegate onConnected:earphone];
            }
        }
    }];
    
    //设置设备连接失败的委托
    [self.baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        if (self.delegate != nil) {
            QCYEarphone *earphone = [weakSelf getEarphoneWithPeripheral:peripheral];
            if (earphone != nil) {
                [earphone onFailToConnect];
                [weakSelf.delegate onFailToConnect:earphone];
            }
        }
    }];
    
    //设置设备断开连接的委托
    [self.baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        if (self.delegate != nil) {
            QCYEarphone *earphone = [weakSelf getEarphoneWithPeripheral:peripheral];
            if (earphone != nil) {
                [earphone onDisconnected];
                [weakSelf.delegate onDisconnected:earphone];
            }
        }
    }];
    
    //设置发现设备的Services的委托
    [self.baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        
        [rhythm beats];
    }];
    
    //设置读取characteristics的委托
    [self.baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    [self.baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"setBlockOnReadValueForDescriptors name:value is:%@",descriptor.UUID);
    }];
    //设置发现设service的Characteristics的委托
    [self.baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_MAIN]]){
            CBCharacteristic *characteristic_tmp;
            for (characteristic_tmp in service.characteristics) {
                NSLog(@"search Characteristic name:%@", characteristic_tmp.UUID.UUIDString);
                // 设置通知监听
                if ([characteristic_tmp.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY]]){
                    QCYEarphone *earphone = (QCYEarphone *)weakSelf.earphones[peripheral.identifier.UUIDString];
                    earphone.readCharacteristic = characteristic_tmp;
                    [weakSelf.baby notify:peripheral characteristic:characteristic_tmp block: notificationBlock];
                }
                if ([characteristic_tmp.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE]]){
                    QCYEarphone *earphone = (QCYEarphone *)weakSelf.earphones[peripheral.identifier.UUIDString];
                    earphone.writeCharacteristic = characteristic_tmp;
                }
            }
        }
    }];
    
    [self.baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        
        
    }];
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
}
@end
