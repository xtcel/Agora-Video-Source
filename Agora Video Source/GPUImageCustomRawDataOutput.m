//
//  GPUImageCustomRawDataOutput.m
//  Agora Video Source
//
//  Created by xyhg on 2017/7/23.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "GPUImageCustomRawDataOutput.h"

@implementation GPUImageCustomRawDataOutput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    
    if (_newFrameAvailableBlockWithTime != NULL)
    {
        _newFrameAvailableBlockWithTime(frameTime);
    }
}

@end
