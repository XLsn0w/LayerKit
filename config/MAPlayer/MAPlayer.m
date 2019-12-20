//
//  MAPlayer.m
//  ma
//
//  Created by admin on 15/6/17.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "MAPlayer.h"
#import "MANowPlayingControl.h"


@interface MAPlayer()<KFNowPlayingControlDelegate>{
    NSDateFormatter *_dateFormatter;
    // music是否已经加载完毕
    BOOL _isReady;
    NSString *_title;
    NSString *_albumTitle;
    NSString *_artist;
    NSNumber *_totalTimeSecond; // 秒数
}

@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation MAPlayer

static MAPlayer *_instance;
+(instancetype)sharedMAPlayer
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
        
#warning 注册后台播放事件
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if(![[AVAudioSession sharedInstance] setActive:YES error:nil])
        {
            NSLog(@"Failed to set up a session.");
        }
        
        // 添加代理
        [MANowPlayingControl sharedKFNowPlayingControl].delegate = _instance;
    });
    return _instance;
}

- (void)loadMusicWithMusicURL:(NSString *)musicUrlStr
{
    if (_musicURLStr && [musicUrlStr isEqualToString:_musicURLStr]) {
        if (!_isPlaying) [self play];
        if ([self.delegate respondsToSelector:@selector(playerStatusReadyToPlayWithMAPlayer:totalTime:)]) {
            [self.delegate playerStatusReadyToPlayWithMAPlayer:self totalTime:_totalTime];
        }
    }else{
        if (self.player && self.playerItem) {
            [self removeNotification];
        }
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:musicUrlStr]];
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
        
        [self setupNote];
        _musicURLStr = musicUrlStr;
    }
}

#pragma mark - 添加监听
- (void)setupNote
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性

    // 添加播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

#pragma mark - KVO 监听缓冲状态和时间状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            // 准备好可以播放
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            // 获取视频总长度
            CMTime duration = self.playerItem.duration;
            
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTimeSecond = @((int)totalSecond);
            
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            if ([self.delegate respondsToSelector:@selector(playerStatusReadyToPlayWithMAPlayer:totalTime:)]) {
                [self.delegate playerStatusReadyToPlayWithMAPlayer:self totalTime:_totalTime];
            }
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
            
            // 记录状态
            _isReady = YES;
            if (_isPlaying) {
                [self nowplaySetting];
            }
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(playerStatusFailedWithMAPlayer:)]) {
                [self.delegate playerStatusFailedWithMAPlayer:self];
            }
            _isReady = NO;
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        // 缓冲的百分比
        CGFloat progress = timeInterval / totalDuration;
//        NSLog(@"缓存进度---%f",progress);
    }
}
#pragma mark - 监听播放,刷新播放时间
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value / playerItem.currentTime.timescale;// 计算当前在第几秒
        
        NSString *timeString = [weakSelf convertTime:currentSecond];
        
        if ([weakSelf.delegate respondsToSelector:@selector(playerWithCurrentTimeRefreshWithMAPlayer:currentTimeStr:)]) {
            [weakSelf.delegate playerWithCurrentTimeRefreshWithMAPlayer:weakSelf currentTimeStr:timeString];
        }
    }];
}
#pragma mark - 播放完成的通知
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    self.isPlaying = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if ([weakSelf.delegate respondsToSelector:@selector(playerWithPlayEndWithMAPlayer:)]) {
            [weakSelf.delegate playerWithPlayEndWithMAPlayer:self];
        }
    }];
}

#pragma mark - nowPlaying的代理方法
- (void)nowPlayingControlWithPlay:(MANowPlayingControl *)nowPlayingControl
{
    [self play];
}
- (void)nowPlayingControlWithPause:(MANowPlayingControl *)nowPlayingControl
{
    [self pause];
}

#pragma mark - 私有方法
// 计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

// 将秒转化为具体时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)play
{
    self.isPlaying = YES;
    [self.player play];
    if (_isReady) {
        [self nowplaySetting];
    }
}
- (void)pause
{
    self.isPlaying = NO;
    [self.player pause];
}

- (void)nowplaySetting
{
    CGFloat currentSecond = _playerItem.currentTime.value / _playerItem.currentTime.timescale;// 计算当前在第几秒
    [[MANowPlayingControl sharedKFNowPlayingControl]setTitle:_title  artist:_artist albumTitle:_albumTitle totalDuration:_totalTimeSecond currentTime:@((int)currentSecond)];
}

#pragma mark 设置music的信息
- (void)setTitle:(NSString *)title artist:(NSString *)artist albumTitle:(NSString *)albumTitle
{
    _title = [title copy];
    _albumTitle = [albumTitle copy];
    _artist = [artist copy];
}

- (void)dealloc {
    [self removeNotification];
    NSLog(@"%s",__func__);
}

- (void)removeNotification
{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeTimeObserver:self.playbackTimeObserver];
}

@end
