//
//  CAMediaTimingViewController.m
//  LayerKit
//
//  Created by HL on 2018/8/22.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "CAMediaTimingViewController.h"

@interface CAMediaTimingViewController () <CAMediaTiming>

///CAMediaTiming协议定义了在一段动画内用来控制逝去时间的属性的集合，CALayer和CAAnimation都实现了这个协议，所以时间可以被任意基于一个图层或者一段动画的类控制。

@end

@implementation CAMediaTimingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@synthesize autoreverses;

@synthesize beginTime;

@synthesize duration;

@synthesize fillMode;

@synthesize repeatCount;

@synthesize repeatDuration;

@synthesize speed;

@synthesize timeOffset;

@end
