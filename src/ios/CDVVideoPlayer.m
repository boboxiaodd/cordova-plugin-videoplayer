#import <Cordova/CDV.h>
#import "CDVVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"
#import <AVKit/AVKit.h>

@interface CDVVideoPlayer ()
@property (nonatomic,strong) CDVInvokedUrlCommand * videoplayer_command;
//@property (nonatomic,strong) UIView * videoView;
@property (nonatomic,strong) AVPlayer* videoPlayer;
@end

@implementation CDVVideoPlayer
-(void) prepare_play_video:(CDVInvokedUrlCommand *)command
{
    _videoplayer_command = command;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    _videoPlayer = [[AVPlayer alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self send_event:_videoplayer_command withMessage:@{@"status":@"init"} Alive:YES State:YES];

}

-(void) end_play_video:(CDVInvokedUrlCommand *)command
{
    _videoplayer_command = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_videoPlayer replaceCurrentItemWithPlayerItem:nil];
    _videoPlayer = nil;
}

-(void) play_video:(CDVInvokedUrlCommand *)command
{
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    NSString *videoURL = [options valueForKey:@"videoURL"];
    NSURL *url =  [NSURL URLWithString:videoURL];
    AVPlayerItem * movie  =  [AVPlayerItem playerItemWithURL:url];
    [movie addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_videoPlayer replaceCurrentItemWithPlayerItem:movie];
}
-(void) start_play:(CDVInvokedUrlCommand *)command
{
    if(!_videoPlayer) return;
    [_videoPlayer play];
}
-(void) pause_video:(CDVInvokedUrlCommand *)command
{
    if(!_videoPlayer) return;
    [_videoPlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void) resume_video:(CDVInvokedUrlCommand *)command
{
    if(!_videoPlayer) return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_videoPlayer play];
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

- (void) videoPlayBackDidFinish:(NSNotification*)notification {
    NSLog(@"videoPlayBackDidFinish");
    if(_videoPlayer){
        CMTime time = CMTimeMakeWithSeconds(0, 1);
        [_videoPlayer seekToTime: time];
        [_videoPlayer play];
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
