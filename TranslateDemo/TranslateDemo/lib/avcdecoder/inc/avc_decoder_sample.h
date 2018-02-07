//
//  avc_decoder_sample.h
//  AVC_Decoder
//
//  Created by Airoha Technology on 2017/11/29.
//  Copyright © 2017年 Airoha Technology. All rights reserved.
//

#ifndef avc_decoder_sample_h
#define avc_decoder_sample_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
    /**
     avc_decode_init, invoke avc_decode_init before started decode
     
     return 0 is susccess
     
     return -1 is create AVC mode fail
     
     return -2 is create AVC decoder fail
     */
    int avc_decode_init();
    
    /**
     airohadec_enc_to_pcm, input 80 bytes (at least) data to decode at one time
     
     - parameter pIn: input data
     
     - parameter InLen: input length 
     
     - pOut: output data
     
     - OutLen: output length
     */
    int airohadec_enc_to_pcm(unsigned char *pIn, unsigned int InLen, unsigned char *pOut, unsigned int *OutLen );
    
    
    /**
     avc_decode_destory, invoke avc_decode_destory after finished decode
     */
    void avc_decode_destory();
    
#ifdef __cplusplus
}
#endif


#endif /* avc_decoder_sample_h */
