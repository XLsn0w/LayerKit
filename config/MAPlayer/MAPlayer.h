//
//  MAMusic.h
//  ma
//
//  Created by admin on 15/6/17.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MAPlayer;
@protocol MAPlayerDelegate <NSObject>

@optional

// 刷新播放时间
- (void)playerWithCurrentTimeRefreshWithMAPlayer:(MAPlayer *)player currentTimeStr:(NSString *)currentTimeStr;

// 播放结束
- (void)playerWithPlayEndWithMAPlayer:(MAPlayer *)player;

// music加载成功,获取到总时间
- (void)playerStatusReadyToPlayWithMAPlayer:(MAPlayer *)player totalTime:(NSString *)totalTime;

// music加载失败
- (void)playerStatusFailedWithMAPlayer:(MAPlayer *)player;

@end

@interface MAPlayer : NSObject

@property (nonatomic, copy) NSString *musicURLStr;

@property (nonatomic, weak) id<MAPlayerDelegate> delegate;

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@property (nonatomic, copy) NSString *totalTime;

@property (nonatomic, assign) BOOL isPlaying;// 点击了播放按钮，就算是正在播放

+ (instancetype)sharedMAPlayer;

- (void)loadMusicWithMusicURL:(NSString *)musicUrlStr;

- (void)play;

- (void)pause;
// 
- (void)setTitle:(NSString *)title artist:(NSString *)artist albumTitle:(NSString *)albumTitle;

@end
