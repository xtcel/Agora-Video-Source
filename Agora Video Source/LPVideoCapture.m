//
//  LPVideoCapture.m
//  VideoTime
//
//  Created by yong on 2017/7/21.
//  Copyright © 2017年 tcpan. All rights reserved.
//

#import "LPVideoCapture.h"
#import "LFGPUImageBeautyFilter.h"
#import "LFGPUImageEmptyFilter.h"
#import "VideoGenerator.h"
#import "GPUImageCustomRawDataOutput.h"

@interface LPVideoCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate, GPUImageVideoCameraDelegate>

@property (nonatomic, strong) LPVideoView *videoView;
@property (nonatomic, assign) Camera currentCamera;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (nonatomic, strong) AVCaptureVideoDataOutput *currentOutput;

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) LFGPUImageBeautyFilter *leveBeautyFilter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filterOutput;

@end

@implementation LPVideoCapture

- (instancetype)initDelegate:(id<LPVideoCaptureDelegate>)delegate videoView:(LPVideoView *)videoView {
    self = [super init];
    if (self) {
        // origin videoCamera
//        self.captureSession = [[AVCaptureSession alloc] init];
//        self.captureSession.usesApplicationAudioSession = NO;
//        
//        self.currentOutput = [[AVCaptureVideoDataOutput alloc] init];
//        
//        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
//                                        nil];
//        self.currentOutput.videoSettings = setcapSettings;
//        
//        if ([self.captureSession canAddOutput:self.currentOutput]) {
//            [self.captureSession addOutput:self.currentOutput];
//        }
//        
//        self.captureQueue = dispatch_queue_create("MyCaptureQueue", NULL);
//        
//        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
//        [videoView insertCaptureVideoPreviewLayer:previewLayer];

        [self.leveBeautyFilter removeAllTargets];
        [self.videoCamera removeAllTargets];
        [self.filterOutput removeAllTargets];
        
        //GPUImage
        GPUImageView *g = [[GPUImageView alloc] init];
        [g setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        g.frame = videoView.bounds;
        [videoView addSubview:g];
        
        CGSize outputSize = {720, 1280};
        GPUImageCustomRawDataOutput *rawDataOutput = [[GPUImageCustomRawDataOutput alloc] initWithImageSize:outputSize resultsInBGRAFormat:NO];
        
        [self.videoCamera addTarget:self.leveBeautyFilter];
        [self.leveBeautyFilter addTarget:self.filterOutput];
        [self.filterOutput addTarget:g];
        
        [self.leveBeautyFilter addTarget:rawDataOutput];

//        [self.leveBeautyFilter forceProcessingAtSize:outputSize];
//        [rawDataOutput forceProcessingAtSize:videoView.bounds.size];
        
        // 输出数据
//        __weak typeof(self) _self = self;
//        [self.filterOutput setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//            [_self processVideo:output];
//        }];

        
        __weak GPUImageCustomRawDataOutput *weakOutput = rawDataOutput;
        __weak typeof(self) weakSelf = self;

        [rawDataOutput setNewFrameAvailableBlockWithTime:^(CMTime frametime) {
            __strong GPUImageCustomRawDataOutput *strongOutput = weakOutput;

            [VideoGenerator sampleBufferFromRawData:strongOutput frametime:frametime block:^(CMSampleBufferRef sampleBuffer) {
                CVPixelBufferRef aSampleBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
                if (!aSampleBufferRef) {
                    return;
                }
                
                __weak typeof(self) ws = self;
                //    dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate videoCapture:self didOutputSampleBuffer:aSampleBufferRef rotation:0  timeStamp:(int64_t)((CACurrentMediaTime()*1000))];
                //    });
            }];
        }];
        
        self.delegate = delegate;
        //        self.videoCamera.delegate = self;
    }
    
    return self;
}

#pragma mark -- Custom Method
- (void)processVideo:(GPUImageOutput *)output {
    __weak typeof(self) _self = self;
    @autoreleasepool {
        GPUImageFramebuffer *imageFramebuffer = output.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFramebuffer pixelBuffer];
        
        if (pixelBuffer && _self.delegate && [_self.delegate respondsToSelector:@selector(videoCapture:didOutputSampleBuffer:rotation:timeStamp:)]) {
            [_self.delegate videoCapture:_self didOutputSampleBuffer:pixelBuffer rotation:90 timeStamp:(int64_t)((CACurrentMediaTime()*1000))];
        }
    }
}

- (void)dealloc {
    [self.captureSession stopRunning];
}

#pragma mark - public

- (void)startCaptureOfCamera:(Camera)camera {
    // GUPIMAGE videoCamera
    [self.videoCamera startCameraCapture];

     //origin videoCamera
//    if (!self.currentOutput) {
//        return;
//    }
//    
//    self.currentCamera = camera;
//    [self.currentOutput setSampleBufferDelegate:self queue:self.captureQueue];
//    
//    __weak typeof(self) ws = self;
//    dispatch_async(self.captureQueue, ^{
//        [ws changeCaptureDeviceToIndex:camera ofSession:ws.captureSession];
//        
//        [ws.captureSession beginConfiguration];
//        [ws.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480];
//        
//        [ws.captureSession commitConfiguration];
//        [ws.captureSession startRunning];
//    });
}

- (void)stopCapture {
    // GUPIMAGE videoCamera
    [self.videoCamera stopCameraCapture];
    self.videoCamera.delegate = nil;
    
//    [self.currentOutput setSampleBufferDelegate:nil queue:nil];
//    __weak typeof(self) ws = self;
//    dispatch_async(self.captureQueue, ^{
//        [ws.captureSession stopRunning];
//    });
}

- (void)switchCamera {
    [self stopCapture];
    
    if (self.currentCamera == CameraBack) {
        self.currentCamera = CameraFront;
    } else if (self.currentCamera == CameraFront) {
        self.currentCamera = CameraBack;
    }
    
    [self startCaptureOfCamera:self.currentCamera];
}

#pragma mark - extension

- (void)changeCaptureDeviceToIndex:(NSInteger)index ofSession:(AVCaptureSession *)captureSession {
    AVCaptureDevice *captureDevice = [self captureDeviceAtIndex:index];
    if (!captureDevice) {
        return;
    }
    
    NSArray<AVCaptureDeviceInput *> *currentInputs = captureSession.inputs;
    AVCaptureDeviceInput *currentInput = [currentInputs firstObject];
    
    NSString *currentInputName = currentInput.device.localizedName;
    if (currentInputName == captureDevice.uniqueID) {
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        return;
    }
    
    [self.captureSession beginConfiguration];
    
    if (currentInput) {
        [captureSession removeInput:currentInput];
    }
    
    if ([captureSession canAddInput:newInput]) {
        [captureSession addInput:newInput];
    }
    [captureSession commitConfiguration];
}

- (AVCaptureDevice *)captureDeviceAtIndex:(NSInteger)index {
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (!devices) {
        return nil;
    }
    
    NSInteger count = devices.count;
    if ((index < 0) || (count <= 0)) {
        return nil;
    }
    
    AVCaptureDevice *device = nil;
    if (index >= count) {
        device = [devices lastObject];
    } else {
        device = devices[index];
    }
    
    return device;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    __block CVPixelBufferRef aSampleBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (!aSampleBufferRef) {
        return;
    }
    
    __weak typeof(self) ws = self;
        [ws.delegate videoCapture:ws didOutputSampleBuffer:aSampleBufferRef rotation:90 timeStamp:(CACurrentMediaTime()*1000)];
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef aSampleBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (!aSampleBufferRef) {
        return;
    }
    
    __weak typeof(self) ws = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate videoCapture:self didOutputSampleBuffer:aSampleBufferRef rotation:90 timeStamp:(int64_t)((CACurrentMediaTime()*1000))];
//    });
    
}

- (void)encodeWithCVPixelBufferRef:(CVPixelBufferRef)sampleBuffer {
    [self.delegate videoCapture:self didOutputSampleBuffer:sampleBuffer rotation:90 timeStamp:(int64_t)((CACurrentMediaTime()*1000))];
}

#pragma mark - Getter

- (GPUImageStillCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        
//        _videoCamera.outputImageOrientation = _configuration.outputImageOrientation;
//        _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
//        _videoCamera.horizontallyMirrorRearFacingCamera = NO;
//        _videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
    }
    return _videoCamera;
}


- (LFGPUImageBeautyFilter *)leveBeautyFilter {
    if (!_leveBeautyFilter) {
        _leveBeautyFilter = [[LFGPUImageBeautyFilter alloc] init];
    }
    return _leveBeautyFilter;
}

- (GPUImageOutput<GPUImageInput> *)filterOutput {
    if (!_filterOutput) {
        _filterOutput = [[LFGPUImageEmptyFilter alloc] init];
    }
    
    return _filterOutput;
}
@end

