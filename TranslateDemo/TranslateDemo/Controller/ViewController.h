//
//  ViewController.h
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController{

    Byte *pcmDataBuffer;//pcm的读文件数据区
    FILE *file;//pcm源文件
}
@property (strong, nonatomic) CBPeripheral *mPeripheral;


@end

