//
//  KFNowPlayingInfo.h
//  ma
//
//  Created by admin on 15/6/17.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MANowPlayingControl;
@protocol KFNowPlayingControlDelegate <NSObject>

@optional
- (void)nowPlayingControlWithPlay:(MANowPlayingControl *)nowPlayingControl;

- (void)nowPlayingControlWithPause:(MANowPlayingControl *)nowPlayingControl;

- (void)nowPlayingControlWithForward:(MANowPlayingControl *)nowPlayingControl;

- (void)nowPlayingControlWithBackWard:(MANowPlayingControl *)nowPlayingControl;

@end

@interface MANowPlayingControl : NSObject

+ (instancetype)sharedKFNowPlayingControl;

@property (nonatomic, weak) id<KFNowPlayingControlDelegate> delegate;

/*
 * 当前播放时间
 */
@property (nonatomic, strong) NSNumber *backTime;
/*
 * 播放进度0-1之间
 */
@property (nonatomic, strong) NSNumber *backRate;
/*
 * 设置标题,歌名,总时间等
 */
- (void)setTitle:(NSString *)title artist:(NSString *)artist albumTitle:(NSString *)albumTitle totalDuration:(NSNumber *)totalDuration currentTime:(NSNumber *)currentTime;

@end
