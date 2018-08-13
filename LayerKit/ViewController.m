//
//  ViewController.m
//  LayerKit
//
//  Created by HL on 2018/8/8.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "ViewController.h"
#import "CAShapeLayer+RoundCorner.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *rectView;

@property (weak, nonatomic) IBOutlet UIImageView *img;

@end

@implementation ViewController


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

    CAShapeLayer* mask = [CAShapeLayer drawRoundCornerWithRect:_img.bounds];
    _img.layer.mask = mask;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(175, 100)];
    
    [path addArcWithCenter:CGPointMake(150, 100) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(150, 125)];
    [path addLineToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(125, 225)];
    [path moveToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(175, 225)];
    [path moveToPoint:CGPointMake(100, 150)];
    [path addLineToPoint:CGPointMake(200, 150)];
    
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
    //add it to our view
    [self.view.layer addSublayer:shapeLayer];
    
    
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;///这行代码指定了阴影路径，如果没有手动指定，Core Animation会去自动计算，这就会触发离屏渲染。如果人为指定了阴影路径，就可以免去计算，从而避免产生离屏渲染。
    
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


@end
