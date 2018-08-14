//
//  DrawView.m
//  Draw
//
//  Created by HL on 2018/8/7.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

//- (void)drawRect:(CGRect)rect {
//    NSString *text = @"devZhang is an iOS developer.iOS开发者 iOS开发者 iOS开发者 iOS开发者 iOS开发者";
//    // 文本段落样式
//    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
//    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
//    textStyle.alignment = NSTextAlignmentLeft; //（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
//    textStyle.lineSpacing = 5; // 字体的行间距
//    textStyle.firstLineHeadIndent = 5.0; // 首行缩进
//    textStyle.headIndent = 0.0; // 整体缩进(首行除外)
//    textStyle.tailIndent = 0.0; //
//    textStyle.minimumLineHeight = 20.0; // 最低行高
//    textStyle.maximumLineHeight = 20.0; // 最大行高
//    textStyle.paragraphSpacing = 15; // 段与段之间的间距
//    textStyle.paragraphSpacingBefore = 22.0f; // 段首行空白空间/* Distance between the bottom of the PRevious paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
//    textStyle.baseWritingDirection = NSWritingDirectionLeftToRight; // 从左到右的书写方向（一共➡️三种）
//    textStyle.lineHeightMultiple = 15; /* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
//    textStyle.hyphenationFactor = 1; //连字属性 在iOS，唯一支持的值分别为0和1
//    // 文本属性
//    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
//    // NSParagraphStyleAttributeName 段落样式
//    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
//    // NSFontAttributeName 字体名称和大小
//    [textAttributes setValue:[UIFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
//    // NSForegroundColorAttributeNam 颜色
//    [textAttributes setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];
//    // 绘制文字
//    [text drawInRect:rect withAttributes:textAttributes];
//}

// 绘制图片
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 保存初始状态
    CGContextSaveGState(context);
    // 图形上下文移动{x,y}
    CGContextTranslateCTM(context, 50.0, 30.0);
    // 图形上下文缩放{x,y}
    CGContextScaleCTM(context, 0.8, 0.8);
    // 旋转
//    CGContextRotateCTM(context, M_PI_4 / 4);
    
    // 绘制图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"contents" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    

    // 圆角图片设置
    //    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0); // 开始图形上下文
    //    CGContextRef ctx = UIGraphicsGetCurrentContext(); // 获得图形上下文
    //    CGRect rectNew = CGRectMake(0, 0, rect.size.width, rect.size.height); // 设置一个范围
    //    CGContextAddEllipseInRect(ctx, rect); // 根据一个rect创建一个椭圆
    //    CGContextClip(ctx); // 裁剪
    //    [image drawInRect:rectNew]; // 将原照片画到图形上下文
    //    image = UIGraphicsGetImageFromCurrentImageContext(); // 从上下文上获取剪裁后的照片
    //    UIGraphicsEndImageContext(); // 关闭上下文
    
    // 绘制图片
    // 1 图片可能显示不完整
    //    [image drawAtPoint:CGPointMake(0, 0)];
    
    // 2 在rect范围内完整显示图片-正常使用
    [image drawInRect:rect];
    
    // 3 图片上下颠倒了
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextDrawImage(context, rectImage, image.CGImage);
    
    // 4 图片上下颠倒了-n个显示
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextDrawTiledImage(context, rectImage, image.CGImage);
    
    // 恢复到初始状态
    CGContextRestoreGState(context);
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextClip(context);
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    CGFloat colors[] = {
//        204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
//        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
//        0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
//    };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors) / (sizeof(colors[0]) * 4));
//    CGColorSpaceRelease(rgb);
//    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0,0.0), CGPointMake(0.0, rect.size.height),
//                                kCGGradientDrawsBeforeStartLocation);
}

//这是是用drawRect绘图
- (void)drawRect3:(CGRect)rect2 {
    
    //    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //
    //    CGContextSaveGState(ctx);
    //    [[UIColor brownColor] set];
    //    CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    //    CGContextRestoreGState(ctx);
    //
    //    CGContextSaveGState(ctx);
    //    [[UIColor whiteColor] set];
    //    CGContextFillRect(ctx, CGRectMake(self.frame.size.width / 2 - 25, self.frame.size.height / 2 - 25, 50, 50));
    //    CGContextRestoreGState(ctx);
}

//这是是用专有图层CAShapeLayer
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        CAShapeLayer * brownRectLayer = [CAShapeLayer layer];
//        brownRectLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        brownRectLayer.path = path.CGPath;
//        brownRectLayer.fillColor = [UIColor brownColor].CGColor;
//        [self.layer addSublayer:brownRectLayer];
//
//        CAShapeLayer * whiteRectLayer = [CAShapeLayer layer];
//        whiteRectLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        UIBezierPath * path1 = [UIBezierPath bezierPathWithRect:CGRectMake(frame.size.width / 2 - 25, frame.size.height / 2 - 25, 50, 50)];
//        whiteRectLayer.path = path1.CGPath;
//        whiteRectLayer.fillColor = [UIColor whiteColor].CGColor;
//        [self.layer addSublayer:whiteRectLayer];
//
//    }
//    return self;
//}



@end
