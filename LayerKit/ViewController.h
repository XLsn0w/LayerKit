//
//  ViewController.h
//  LayerKit
//
//  Created by HL on 2018/8/8.
//  Copyright © 2018年 XL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@interface ViewController : UIViewController <MAPlayerDelegate>

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *textArray;

@property (nonatomic, strong) NSTimer *time;

@property (nonatomic, assign) BOOL isStop;

@end
