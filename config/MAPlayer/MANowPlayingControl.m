//
//  KFNowPlayingInfo.m
//  ma
//
//  Created by admin on 15/6/17.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "MANowPlayingControl.h"
#import "MANotifications.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>

#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

@interface MANowPlayingControl ()

@property (nonatomic, strong) NSMutableDictionary *nowPlayingInfo;

@end

@implementation MANowPlayingControl

static MANowPlayingControl *_instance;

+ (MANowPlayingControl *)sharedKFNowPlayingControl
{
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
#warning 注册远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlPlayButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlPauseButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlStopButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlForwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlBackwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:remoteControlOtherButtonTapped object:nil];
    }
    return self;
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:remoteControlPlayButtonTapped]) {
        if ([self.delegate respondsToSelector:@selector(nowPlayingControlWithPlay:)]) {
            [self.delegate nowPlayingControlWithPlay:self];
        }
        NSLog(@"play");
        
    } else  if ([notification.name isEqualToString:remoteControlPauseButtonTapped]) {
        if ([self.delegate respondsToSelector:@selector(nowPlayingControlWithPause:)]) {
            [self.delegate nowPlayingControlWithPause:self];
        }
        NSLog(@"pause");
        
    } else if ([notification.name isEqualToString:remoteControlStopButtonTapped]) {
        
        NSLog(@"stop");
        
    } else if ([notification.name isEqualToString:remoteControlForwardButtonTapped]) {
        if ([self.delegate respondsToSelector:@selector(nowPlayingControlWithForward:)]) {
            [self.delegate nowPlayingControlWithForward:self];
        }
        NSLog(@"forward");
        
    } else if ([notification.name isEqualToString:remoteControlBackwardButtonTapped]) {
        if ([self.delegate respondsToSelector:@selector(nowPlayingControlWithBackWard:)]) {
            [self.delegate nowPlayingControlWithBackWard:self];
        }
        NSLog(@"backward");
        
    }else {
        
        NSLog(@"other");
        
    }  
}

- (void)setTitle:(NSString *)title artist:(NSString *)artist albumTitle:(NSString *)albumTitle totalDuration:(NSNumber *)totalDuration currentTime:(NSNumber *)currentTime
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    if (albumTitle) {
        dict[MPMediaItemPropertyAlbumTitle] = albumTitle;
    }
    if (title) {
        dict[MPMediaItemPropertyTitle] = title;
    }
    if (artist) {
        dict[MPMediaItemPropertyArtist] = artist;
    }
    if (totalDuration) {
        dict[MPMediaItemPropertyPlaybackDuration] = totalDuration;
    }
    if (!currentTime) {
        currentTime = @(0);
    }
    dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime;
    if (iOS8) {
        dict[MPNowPlayingInfoPropertyDefaultPlaybackRate] = @1.0;
    }

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict;
}

- (void)setBackRate:(NSNumber *)backRate
{
    if (iOS8) {
        if (!backRate) {
            backRate = @(1);
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
        dict[MPNowPlayingInfoPropertyDefaultPlaybackRate] = backRate;
        
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict;
    }

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
