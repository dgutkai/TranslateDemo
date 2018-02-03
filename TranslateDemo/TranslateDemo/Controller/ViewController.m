//
//  ViewController.m
//  TranslateDemo
//
//  Created by lanmi on 2018/1/24.
//  Copyright © 2018年 com.qcymail. All rights reserved.
//

#import "ViewController.h"
#import "iflyMSC/IFlyMSC.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"
#import "AudioRecoder.h"

@interface ViewController ()<IFlySpeechSynthesizerDelegate, IFlySpeechRecognizerDelegate, AudioRecoderDelegate>
{
    AudioRecoder *recoder;
}
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
//不带界面的识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) NSString * result;
@property (nonatomic, strong) NSString * resultString;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    recoder = [[AudioRecoder alloc] init];
    recoder.delegate = self;
    [recoder start];
    //创建语音识别对象
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    //设置音频源为音频流（-1）
    [self.iFlySpeechRecognizer setParameter:@"-1" forKey:@"audio_source"];
//    //设置识别参数
//    //设置为听写模式
//    [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
//    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
//    [_iFlySpeechRecognizer setParameter:nil forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
//    [_iFlySpeechRecognizer setParameter: @"1" forKey: [IFlySpeechConstant ASR_SCH]];
//    [_iFlySpeechRecognizer setParameter: @"translate" forKey: @"addcap"];
//    //中文转英文
//    [_iFlySpeechRecognizer setParameter: @"zh" forKey: @"orilang"];
//    [_iFlySpeechRecognizer setParameter: @"en" forKey: @"translang"];
    
    [_iFlySpeechRecognizer setDelegate:self];
    //启动识别服务
    [_iFlySpeechRecognizer startListening];
    _resultString = @"";
    
}


- (void) ttsSpeakForString: (NSString *)string Delegate: (id<IFlySpeechSynthesizerDelegate>)delegate{
    //获取语音合成单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    //设置协议委托对象
    _iFlySpeechSynthesizer.delegate = delegate;
    //设置合成参数
    //设置在线工作方式
    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
                                  forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //设置音量，取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50"
                                  forKey: [IFlySpeechConstant VOLUME]];
    //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
    [_iFlySpeechSynthesizer setParameter:@" xiaoyan "
                                  forKey: [IFlySpeechConstant VOICE_NAME]];
    //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
//    [_iFlySpeechSynthesizer setParameter:@" tts.pcm"
//                                  forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    //启动合成会话
    [_iFlySpeechSynthesizer startSpeaking: string];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IFlySpeechSynthesizerDelegate协议实现
//合成结束
- (void) onCompleted:(IFlySpeechError *) error {
    
}
//合成开始
- (void) onSpeakBegin {
    
}
//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg {
    
}
//合成播放进度
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos {
    
}

#pragma mark - IFlySpeechRecognizerDelegate协议实现
//识别结果返回代理
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    _result =[NSString stringWithFormat:@"%@%@", _resultString,resultString];
    
    NSString * resultFromJson =  nil;
    
    if([IATConfig sharedInstance].isTranslate){
        
        NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //The result type must be utf8, otherwise an unknown error will happen.
                                    [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(resultDic != nil){
            NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
            
            if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]){
                NSString *dst = [trans_result objectForKey:@"dst"];
                NSLog(@"dst=%@",dst);
                resultFromJson = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
            }
            else{
                NSString *src = [trans_result objectForKey:@"src"];
                NSLog(@"src=%@",src);
                resultFromJson = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
            }
        }
    }
    else{
        resultFromJson = [ISRDataHelper stringFromJson:resultString];
    }
    
    _resultString = [NSString stringWithFormat:@"%@%@", _resultString,resultFromJson];
    
    if (isLast){
        NSLog(@"ISR Results(json)：%@",  _resultString);
        [recoder stop];
        [self.iFlySpeechRecognizer stopListening];//音频数据写入完成，进入等待状态
        [self ttsSpeakForString:_resultString Delegate:self];
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_resultText.text);
}
//识别会话结束返回代理
- (void)onError: (IFlySpeechError *) error{
    [recoder stop];
    [self.iFlySpeechRecognizer stopListening];//音频数据写入完成，进入等待状态
}
//停止录音回调
- (void) onEndOfSpeech{}
//开始录音回调
- (void) onBeginOfSpeech{}
//音量回调函数
- (void) onVolumeChanged: (int)volume{}
//会话取消回调
- (void) onCancel{}

#pragma mark - AudioRecoderDelegate
- (void)audioRecoderData:(NSData *)audioData{
        NSLog(@"录音回调%@", audioData);
    [self.iFlySpeechRecognizer writeAudio:audioData];//写入音频，让SDK识别。建议将音频数据分段写入。
}
@end
