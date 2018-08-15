//
//  ViewController.m
//  LayerKit
//
//  Created by HL on 2018/8/8.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "ViewController.h"
#import "CAShapeLayer+RoundCorner.h"
#import "UIControl+RepeatTimeInterval.h"
#import "UIView+RoundCorner.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *rectView;

@property (weak, nonatomic) IBOutlet UIImageView *img;

@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (IBAction)btnSEL:(id)sender {
    NSLog(@"---");
}

//避免图层混合
//
//确保控件的opaque属性设置为true，确保backgroundColor和父视图颜色一致且不透明。
//如无特殊需要，不要设置低于1的alpha值。
//确保UIImage没有alpha通道。


//避免临时转换
//
//确保图片大小和frame一致，不要在滑动时缩放图片。
//确保图片颜色格式被GPU支持，避免劳烦CPU转换。
//慎用离屏渲染


//绝大多数时候离屏渲染会影响性能。

//重写drawRect方法，设置圆角、阴影、模糊效果，光栅化都会导致离屏渲染。
//设置阴影效果是加上阴影路径。
//滑动时若需要圆角效果，开启光栅化。

- (void)viewDidLoad {
    [super viewDidLoad];

    [_img drawRoundCornerWithStrokeColor:UIColor.redColor lineWidth:5];
    
    
//    centerX _rectView.center.x;

    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(175, 100)];
    
    [bezierPath addArcWithCenter:CGPointMake(150, 100) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bezierPath moveToPoint:CGPointMake(150, 125)];
    [bezierPath addLineToPoint:CGPointMake(150, 175)];
    [bezierPath addLineToPoint:CGPointMake(125, 225)];
    [bezierPath moveToPoint:CGPointMake(150, 175)];
    [bezierPath addLineToPoint:CGPointMake(175, 225)];
    [bezierPath moveToPoint:CGPointMake(100, 150)];
    [bezierPath addLineToPoint:CGPointMake(200, 150)];
    
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = bezierPath.CGPath;
    //add it to our view
    [self.view.layer addSublayer:shapeLayer];
    
    
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;///这行代码指定了阴影路径，如果没有手动指定，Core Animation会去自动计算，这就会触发离屏渲染。如果人为指定了阴影路径，就可以免去计算，从而避免产生离屏渲染。
    
    
    _btn.repeatTimeInterval = 3;
    
    
    
    
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    imageView.image = [UIImage imageNamed:@"1"];
    
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    //使用贝塞尔曲线画出一个圆形图
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:imageView.frame.size.width] addClip];
    [imageView drawRect:imageView.bounds];
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //结束画图
    UIGraphicsEndImageContext();
    [self.view addSubview:imageView];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)func {
    UIImage* image=[UIImage imageNamed:@"1.jpg"];
    

    /// url
    NSURL *url=[NSURL URLWithString:@"http://attach.bbs.miui.com/forum/201203/20/170226n5qcwdpusnjdsswy.jpg"];
    UIImage *imgFromUrl =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    
    //读取本地图片非resource
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(), @"test"];
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    
    //    4.从现有的context中获得图像
    //add ImageIO.framework and #import
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGImageRef img= CGImageSourceCreateImageAtIndex(source,0,NULL);
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    //transformCTM的2种方式
    //CGContextConcatCTM(ctx, CGAffineTransformMakeScale(.2, -0.2));
    //CGContextScaleCTM(ctx,1,-1);
    //注意坐标要反下,用ctx来作为图片源
    CGImageRef capture=CGBitmapContextCreateImage(ctx);
    CGContextDrawImage(ctx, CGRectMake(160, 0, 160, 230), [image CGImage]);
    CGContextDrawImage(ctx, CGRectMake(160, 230, 160, 230), img);
    CGImageRef capture2=CGBitmapContextCreateImage(ctx);
    
    //    5.用Quartz的CGImageSourceRef来读取图片
    CGImageSourceRef source1 = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGImageRef img_ref = CGImageSourceCreateImageAtIndex(source1, 0, NULL);
    
    //保存图片 2种获取路径都可以
    //NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString*documentsDirectory=[paths objectAtIndex:0];
    //NSString*aPath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"test"]];
    NSString *aPath=[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),@"test"];
    NSData *imgData = UIImageJPEGRepresentation(imgFromUrl,0);
    [imgData writeToFile:aPath atomically:YES];
    
    //    2.用Quartz的CGImageDestinationRef来输出图片，这个方式不常见，所以不做介绍，详细可以看apple文档Quartz 2D Programming Guide
    
    
    //    三.绘制图(draw|painting)
    //    1.UIImageView方式加入到UIView层
    
    
    //    2.[img drawAtPoint]系列方法
    UIImage* image4;
    [image4 drawAtPoint:CGPointMake(100, 0)];
    
    //    3.CGContextDrawImage
    
    CGContextDrawImage(ctx, CGRectMake(160, 0, 160, 230), [image CGImage]);
    
    //    4.CGLayer
    //    这个是apple推荐的一种offscreen的绘制方法，相比bitmapContext更好，因为它似乎会利用iphone硬件(drawing-card)加速
    
    CGLayerRef cg=CGLayerCreateWithContext(ctx, CGSizeMake(320, 480), NULL);
    //需要将CGLayerContext来作为缓存context，这个是必须的
    CGContextRef layerContext=CGLayerGetContext(cg);
    CGContextDrawImage(layerContext, CGRectMake(160, 230, 160, 230), img);
    CGContextDrawLayerAtPoint(ctx, CGPointMake(0, 0), cg);
    
    //    5.CALayer的contents
    UIImage* contents=[UIImage imageNamed:@"1.jpg"];
    CALayer *ly=[CALayer layer];
    ly.frame=CGRectMake(0, 0, 320, 460);
    ly.contents=(__bridge id _Nullable)([contents CGImage]);
    //    [self.layer addSublayer:ly];
    
    
    //    1.CGImage和UIImage互换
    //    这样就可以随时切换UIKit和Quartz之间类型，并且选择您熟悉的方式来处理图片.
    //    CGImage cgImage=[uiImage CGImage];
    //    UIImage* uiImage=[UIImage imageWithCGImage:cgImage];
}







- (void)buttonAction:(UIButton *)b {
    UIImage *image = [UIImage imageNamed:@"lena"];
    UIImage *img = [self dealImage:image cornerRadius:100];
    // 使用方法：只需把 - (UIImage *)dealImage:(UIImage *)img cornerRadius:(CGFloat)c;
    // 把这个方法的代码复制到对应项目中就可用了，暂时没封装成库，以后方法多起来会封装的。
}

// ------------------ 以下是速度测试 ---------------------
static int count = 10000;               // 1万次调用测试
static NSString *imgName = @"lena";     // 512 * 512, RGBA 的实验图像
static CGFloat radius = 100;             // 圆角大小，单位是像素点

- (void)buttonActionCk:(UIButton *)b {
    UIImage *image = [UIImage imageNamed:imgName];
    
    NSLog(@"---start");
    time_t t1 = clock();
    for (int i=0; i<count; i++) {
        [self dealImage:image cornerRadius:radius];
    }
    time_t t2 = clock();
    NSLog(@"my裁剪用时：%.3f 秒", ((float)(t2 - t1)) / CLOCKS_PER_SEC);
}

- (void)buttonActionCG:(UIButton *)b {
    UIImage *image = [UIImage imageNamed:imgName];
    
    NSLog(@"---start");
    time_t t1 = clock();
    for (int i=0; i<count; i++) {
        [self CGContextClip:image cornerRadius:radius];
    }
    time_t t2 = clock();
    NSLog(@"CGContext裁剪用时：%.3f 秒", ((float)(t2 - t1)) / CLOCKS_PER_SEC);
}

- (void)buttonActionBe:(UIButton *)b {
    UIImage *image = [UIImage imageNamed:imgName];
    
    NSLog(@"---start");
    time_t t1 = clock();
    for (int i=0; i<count; i++) {
        [self UIBezierPathClip:image cornerRadius:radius];
    }
    time_t t2 = clock();
    NSLog(@"贝塞尔裁剪用时：%.3f 秒", ((float)(t2 - t1)) / CLOCKS_PER_SEC);
}

// CGContext 裁剪
- (UIImage *)CGContextClip:(UIImage *)img cornerRadius:(CGFloat)c {
    int w = img.size.width * img.scale;
    int h = img.size.height * img.scale;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, c);
    CGContextAddArcToPoint(context, 0, 0, c, 0, c);
    CGContextAddLineToPoint(context, w-c, 0);
    CGContextAddArcToPoint(context, w, 0, w, c, c);
    CGContextAddLineToPoint(context, w, h-c);
    CGContextAddArcToPoint(context, w, h, w-c, h, c);
    CGContextAddLineToPoint(context, c, h);
    CGContextAddArcToPoint(context, 0, h, 0, h-c, c);
    CGContextAddLineToPoint(context, 0, c);
    CGContextClosePath(context);
    
    CGContextClip(context);     // 先裁剪 context，再画图，就会在裁剪后的 path 中画
    [img drawInRect:CGRectMake(0, 0, w, h)];       // 画图
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

// UIBezierPath 裁剪
- (UIImage *)UIBezierPathClip:(UIImage *)img cornerRadius:(CGFloat)c {
    int w = img.size.width * img.scale;
    int h = img.size.height * img.scale;
    CGRect rect = CGRectMake(0, 0, w, h);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:c] addClip];
    [img drawInRect:rect];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

/////////////////////


// ------------------------------------------------------------------
// --------------------- 以下是自定义图像处理部分 -----------------------
// ------------------------------------------------------------------

// 自定义裁剪算法
- (UIImage *)dealImage:(UIImage *)img cornerRadius:(CGFloat)c {
    // 1.CGDataProviderRef 把 CGImage 转 二进制流
    CGDataProviderRef provider = CGImageGetDataProvider(img.CGImage);
    void *imgData = (void *)CFDataGetBytePtr(CGDataProviderCopyData(provider));
    int width = img.size.width * img.scale;
    int height = img.size.height * img.scale;
    
    // 2.处理 imgData
    //    dealImage(imgData, width, height);
    cornerImage(imgData, width, height, c);
    
    // 3.CGDataProviderRef 把 二进制流 转 CGImage
    CGDataProviderRef pv = CGDataProviderCreateWithData(NULL, imgData, width * height * 4, releaseData);
    CGImageRef content = CGImageCreate(width , height, 8, 32, 4 * width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, pv, NULL, true, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:content];
    CGDataProviderRelease(pv);      // 释放空间
    CGImageRelease(content);
    
    return result;
}

void releaseData(void *info, const void *data, size_t size) {
    free((void *)data);
}

// 在 img 上处理图片, 测试用
void dealImage(UInt32 *img, int w, int h) {
    int num = w * h;
    UInt32 *cur = img;
    for (int i=0; i<num; i++, cur++) {
        UInt8 *p = (UInt8 *)cur;
        // RGBA 排列
        // f(x) = 255 - g(x) 求负片
        p[0] = 255 - p[0];
        p[1] = 255 - p[1];
        p[2] = 255 - p[2];
        p[3] = 255;
    }
}

// 裁剪圆角
void cornerImage(UInt32 *const img, int w, int h, CGFloat cornerRadius) {
    CGFloat c = cornerRadius;
    CGFloat min = w > h ? h : w;
    
    if (c < 0) { c = 0; }
    if (c > min * 0.5) { c = min * 0.5; }
    
    // 左上 y:[0, c), x:[x, c-y)
    for (int y=0; y<c; y++) {
        for (int x=0; x<c-y; x++) {
            UInt32 *p = img + y * w + x;    // p 32位指针，RGBA排列，各8位
            if (isCircle(c, c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 右上 y:[0, c), x:[w-c+y, w)
    int tmp = w-c;
    for (int y=0; y<c; y++) {
        for (int x=tmp+y; x<w; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(w-c, c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 左下 y:[h-c, h), x:[0, y-h+c)
    tmp = h-c;
    for (int y=h-c; y<h; y++) {
        for (int x=0; x<y-tmp; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(c, h-c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 右下 y~[h-c, h), x~[w-c+h-y, w)
    tmp = w-c+h;
    for (int y=h-c; y<h; y++) {
        for (int x=tmp-y; x<w; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(w-c, h-c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
}

// 判断点 (px, py) 在不在圆心 (cx, cy) 半径 r 的圆内
static inline bool isCircle(float cx, float cy, float r, float px, float py) {
    if ((px-cx) * (px-cx) + (py-cy) * (py-cy) > r * r) {
        return false;
    }
    return true;
}

// 其他图像效果可以自己写函数，然后在 dealImage: 中调用 otherImage 即可
void otherImage(UInt32 *const img, int w, int h) {
    // 自定义处理
}


@end
