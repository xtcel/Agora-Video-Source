//
//  GPUImageFramebuffer+PixelBuffer.h
//  Agora Video Source
//
//  Created by xyhg on 2017/7/23.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "GPUImageFramebuffer.h"

@interface GPUImageFramebuffer (PixelBuffer)

- (CVPixelBufferRef )pixelBuffer;

@end
