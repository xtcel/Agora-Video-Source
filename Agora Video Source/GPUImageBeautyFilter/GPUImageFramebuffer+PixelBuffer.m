//
//  GPUImageFramebuffer+PixelBuffer.m
//  Agora Video Source
//
//  Created by xyhg on 2017/7/23.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "GPUImageFramebuffer+PixelBuffer.h"

@implementation GPUImageFramebuffer (PixelBuffer)

- (CVPixelBufferRef )pixelBuffer
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    return self.renderTarget;
#else
    return NULL; // TODO: do more with this on the non-texture-cache side
#endif
}

@end

