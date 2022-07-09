#import <Cordova/CDV.h>
#import "CDVVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation CDVPicker
-(void) prepare_play_video:(CDVInvokedUrlCommand *)command
{
    _videoplayer_command = command;
    _videoView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [_rootVC.view insertSubview:_videoView belowSubview: _rootVC.webView];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    AVPlayer *player = [[AVPlayer alloc] init];
    _videoPlayer = [AVPlayerLayer playerLayerWithPlayer: player];
    _videoPlayer.frame = _videoView.frame;
    _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_videoView.layer addSublayer: _videoPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self send_event:_videoplayer_command withMessage:@{@"status":@"init"} Alive:YES State:YES];

}
-(void) filish_play_video:(CDVInvokedUrlCommand *)command
{
    _videoplayer_command = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_videoPlayer.player replaceCurrentItemWithPlayerItem:nil];
    [_videoPlayer removeFromSuperlayer];
    [_videoView removeFromSuperview];
    _videoPlayer = nil;
    _videoView = nil;
}

-(void) play_video:(CDVInvokedUrlCommand *)command
{
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    NSString *videoURL = [options valueForKey:@"videoURL"];
    NSURL *url =  [NSURL URLWithString:videoURL];
    AVPlayerItem * movie  =  [AVPlayerItem playerItemWithURL:url];
    [movie addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_videoPlayer.player replaceCurrentItemWithPlayerItem:movie];
    [_videoPlayer.player play];
}
-(void) pause_video:(CDVInvokedUrlCommand *)command
{
    [_videoView setHidden:YES];
    [_videoPlayer.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void) resume_video:(CDVInvokedUrlCommand *)command
{
    [_videoView setHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_videoPlayer.player play];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if(item.status == AVPlayerItemStatusReadyToPlay) {
        [self send_event:_videoplayer_command withMessage:@{@"status":@"ready"} Alive:YES State:YES];
    }
    if(item.status == AVPlayerItemStatusFailed){
        [self send_event:_videoplayer_command withMessage:@{@"status":@"fail"} Alive:YES State:YES];
    }
}

#pragma mark 公共方法

- (void)send_event:(CDVInvokedUrlCommand *)command withMessage:(NSDictionary *)message Alive:(BOOL)alive State:(BOOL)state{
    if(!command) return;
    CDVPluginResult* res = [CDVPluginResult resultWithStatus: (state ? CDVCommandStatus_OK : CDVCommandStatus_ERROR) messageAsDictionary:message];
    if(alive) [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult: res callbackId: command.callbackId];
}

@end
