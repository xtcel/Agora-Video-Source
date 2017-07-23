//
//  VideoGenerator.h
//  Lizap
//
//  Created by FUJIKI TAKESHI on 2015/06/13.
//  Copyright (c) 2015年 Takeshi Fujiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "GPUImageRawDataOutput.h"

@interface VideoGenerator : NSObject

+ (CMSampleBufferRef)copySampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (void)sampleBufferFromRawData:(GPUImageRawDataOutput *)output frametime:(CMTime)frametime block:(void (^)(CMSampleBufferRef))block;

@end
