//
//  GPUImageCustomRawDataOutput.h
//  Agora Video Source
//
//  Created by xyhg on 2017/7/23.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "GPUImageRawDataOutput.h"

@interface GPUImageCustomRawDataOutput : GPUImageRawDataOutput

@property(nonatomic, copy) void(^newFrameAvailableBlockWithTime)(CMTime frameTime);

@end
