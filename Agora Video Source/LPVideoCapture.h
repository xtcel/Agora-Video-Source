//
//  LPVideoCapture.h
//  VideoTime
//
//  Created by yong on 2017/7/21.
//  Copyright © 2017年 tcpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <VideoToolbox/VideoToolbox.h>
#import "LPVideoView.h"

typedef NS_ENUM(NSInteger, Camera) {
    CameraBack = 0,
    CameraFront = 1,
};

@protocol LPVideoCaptureDelegate;

@interface LPVideoCapture : NSObject

@property (nonatomic, strong) id<LPVideoCaptureDelegate> delegate;

- (instancetype)initDelegate:(id<LPVideoCaptureDelegate>)delegate videoView:(LPVideoView *)videoView;

- (void)startCaptureOfCamera:(Camera)camera;

- (void)stopCapture;

- (void)switchCamera;

@end

@protocol LPVideoCaptureDelegate <NSObject>

- (void)videoCapture:(LPVideoCapture *)capture didOutputSampleBuffer:(CVPixelBufferRef)sampleBuffer rotation:(int)ratation timeStamp:(int64_t)timeStamp;

@end
