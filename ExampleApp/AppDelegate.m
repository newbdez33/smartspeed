//
//  AppDelegate.m
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//

#import "AppDelegate.h"
#import "STKAudioPlayer.h"
#import "AudioPlayerView.h"
#import "STKAutoRecoveringHTTPDataSource.h"
#import "SampleQueueId.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate()
{
    STKAudioPlayer* audioPlayer;
    NSTimer *timer;
    
}
@end

@implementation AppDelegate

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
	[[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    Float32 bufferLength = 0.1;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferLength), &bufferLength);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    
	self.window.backgroundColor = [UIColor whiteColor];
    
	audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    
	audioPlayer.meteringEnabled = YES;
    audioPlayer.equalizerEnabled = NO;
	audioPlayer.volume = 1;
    
    CGRect f = self.window.bounds;
    f.size.height = 2000;
	self.audioPlayerView = [[AudioPlayerView alloc] initWithFrame:f andAudioPlayer:audioPlayer];
    
	self.audioPlayerView.delegate = self;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
    [self.window makeKeyAndVisible];
    
    UIScrollView * scv = [[UIScrollView alloc] initWithFrame:self.window.bounds];
    scv.contentSize = self.audioPlayerView.frame.size;
    [scv addSubview:self.audioPlayerView];
    [self.window.rootViewController.view addSubview:scv];
	
    return YES;
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(void) audioPlayerViewPlayFromHTTPSelected:(AudioPlayerView*)audioPlayerView
{
    NSURL* url = [NSURL URLWithString:audioPlayerView.textField.text];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer* t) {
        float peak = [audioPlayer peakPowerInDecibelsForChannel:0];
        float newRate = 1.0;
        
        float silentPower = -40;
        if ( peak < silentPower ) {
            float k = 0.06;
            newRate = 1 + MIN( (silentPower - peak)*k, 1 );
        }
        //NSLog(@"s:%@, p:%@, new rate:%@", @(silentPower), @(peak), @(newRate));
        [audioPlayer setplaybackbackspeed:(AudioUnitParameterValue) newRate];
        

        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.audioPlayerView.playbackspeedlabel.text = [[NSString alloc] initWithFormat:@"%0.3fx", newRate];
    }];

}

-(void) audioPlayerViewPlayFromIcecastSelected:(AudioPlayerView *)audioPlayerView
{
    NSURL* url = [NSURL URLWithString:@"http://shoutmedia.abc.net.au:10326"];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewQueueShortFileSelected:(AudioPlayerView*)audioPlayerView
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"airplane" ofType:@"aac"];
	NSURL* url = [NSURL fileURLWithPath:path];
	
	STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewPlayFromLocalFileSelected:(AudioPlayerView*)audioPlayerView
{
	NSString* path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"];
	NSURL* url = [NSURL fileURLWithPath:path];
	
	STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
	
	[audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void) audioPlayerViewQueuePcmWaveFileSelected:(AudioPlayerView*)audioPlayerView
{
	NSURL* url = [NSURL URLWithString:@"http://www.abstractpath.com/files/audiosamples/perfectly.wav"];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
	[audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

@end
