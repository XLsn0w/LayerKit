
#import <UIKit/UIKit.h>

@interface UIControl (RepeatTimeInterval)

@property (nonatomic, assign) NSTimeInterval repeatTimeInterval; // 点击事件时间间隔

@property (nonatomic, assign) BOOL isRespond;                   // 是否忽略点击事件

@end
