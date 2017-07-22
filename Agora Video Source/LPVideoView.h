//
//  LPVideoView.h
//  VideoTime
//
//  Created by yong on 2017/7/21.
//  Copyright © 2017年 tcpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LPVideoView : UIView

- (void)insertCaptureVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end
