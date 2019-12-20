//
//  Header.h
//  LayerKit
//
//  Created by mac on 2019/12/20.
//  Copyright © 2019 XL. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define SNOW_IMAGENAME         @"snow"

// MainScreen Height&Width
#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width

#define IMAGE_X                arc4random()%(int)Main_Screen_Width
#define IMAGE_ALPHA            ((float)(arc4random()%10))/10
#define IMAGE_WIDTH            arc4random()%20 + 10
#define PLUS_HEIGHT            Main_Screen_Height/25

#define MWColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define kScreenSize    [UIScreen mainScreen].bounds.size

#import "ViewController.h"
#import "ZYAnimationLayer.h"
#import "MAPlayer.h"

#endif /* Header_h */
