//
//  QCYDeviceProtocol.h
//  TranslateDemo
//
//  Created by lanmi on 2018/2/7.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QCYDeviceProtocol <NSObject>
- (void) onNotificationWithData: (NSData *)data;
- (void) onConnected;
- (void) onDisconnected;
- (void) onFailToConnect;
@end
