//
//  ViewController.m
//  Agora Video Source
//
//  Created by xyhg on 2017/7/22.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "VideoChatViewController.h"
#import "LPVideoView.h"
#import "LPVideoCapture.h"

//获取当前屏幕高
#define  SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//获取当前屏幕宽
#define  SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

static NSString *appID = @"421e6f7210e84f0eb2a690c6d630b84f";

@interface VideoChatViewController ()<AgoraRtcEngineDelegate, LPVideoCaptureDelegate>

@property (nonatomic, weak) IBOutlet LPVideoView *localVideo;
@property (nonatomic, weak) IBOutlet UIView *remoteVideo;
@property (nonatomic, weak) IBOutlet UIView *controlButtons;
@property (nonatomic, weak) IBOutlet UIImageView *remoteVideoMutedIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *localVideoMutedBg;
@property (nonatomic, weak) IBOutlet UIImageView *localVideoMutedIndicator;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) LPVideoCapture *videoCapture;

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideVideoMuted];
    [self initializeAgoraEngine];
    [self setupVideo];
    [self startVideoCapture];
    [self joinChannel];
}

- (void)initializeAgoraEngine {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appID delegate:self];
}

- (void)setupVideo {
    [self.agoraKit setExternalVideoSource:YES useTexture:YES pushMode:YES];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_720P swapWidthAndHeight: false];
}

- (void)startVideoCapture {
    self.videoCapture = [[LPVideoCapture alloc] initDelegate:self videoView:self.localVideo];
    [self.videoCapture startCaptureOfCamera:CameraFront];
}

- (void)joinChannel {
    [self.agoraKit joinChannelByKey:nil channelName:@"demoChannel" info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        [self.agoraKit setEnableSpeakerphone:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }];
}

- (void)leaveChannel {
    [self.videoCapture stopCapture];
    [self.agoraKit leaveChannel:nil];
    
    [self hideControlButtons];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.remoteVideo removeFromSuperview];
    [self.localVideo removeFromSuperview];
    
    self.agoraKit = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EventResponse

- (void)didClickHangUpButton:(UIButton *)sender {
    [self leaveChannel];
}

- (void)hideControlButtons {
    self.controlButtons.hidden = true;
}

- (void)didClickMuteButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self.agoraKit muteLocalAudioStream:sender.isSelected];
}

- (void)didClickVideoMuteButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self.agoraKit muteLocalVideoStream:sender.isSelected];
    
    _localVideo.hidden = sender.isSelected;
    self.localVideoMutedBg.hidden = !sender.isSelected;
    self.localVideoMutedIndicator.hidden = !sender.isSelected;
}

- (void)hideVideoMuted {
    self.remoteVideoMutedIndicator.hidden = true;
    self.localVideoMutedBg.hidden = true;
    self.localVideoMutedIndicator.hidden = true;
}

- (void)didClickSwitchCameraButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [self.videoCapture switchCamera];
}

#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    if (self.remoteVideo.isHidden) {
        self.remoteVideo.hidden = false;
    }
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = self.remoteVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Adaptive;
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    self.remoteVideo.hidden = true;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    self.remoteVideo.hidden = muted;
    self.remoteVideoMutedIndicator.hidden = !muted;
}

#pragma mark - LPVideoCaptureDelegate

- (void)videoCapture:(LPVideoCapture *)capture didOutputSampleBuffer:(CVPixelBufferRef)sampleBuffer rotation:(int)ratation timeStamp:(int64_t)timeStamp {
    
    AgoraVideoFrame *videoFrame = [[AgoraVideoFrame alloc] init];
    videoFrame.format = 12;
    videoFrame.textureBuf = sampleBuffer;
    videoFrame.timeStamp = timeStamp;
    videoFrame.rotation = (int32_t)ratation;
    
    [self.agoraKit pushExternalVideoFrame:videoFrame];
}

@end

