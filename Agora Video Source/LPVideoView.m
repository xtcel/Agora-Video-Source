//
//  LPVideoView.m
//  VideoTime
//
//  Created by yong on 2017/7/21.
//  Copyright © 2017年 tcpan. All rights reserved.
//

#import "LPVideoView.h"

@interface LPVideoView ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation LPVideoView

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    self.previewLayer.frame = self.bounds;
}

- (void)insertCaptureVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    [self.previewLayer removeFromSuperlayer];
    
    self.previewLayer.frame = self.bounds;
    
    [self.layer insertSublayer:previewLayer below:[self.layer.sublayers firstObject]];
    
    self.previewLayer = previewLayer;
}

@end
