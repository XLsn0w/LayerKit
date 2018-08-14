//
//  UIView+RoundCorner.m
//  LayerKit
//
//  Created by HL on 2018/8/14.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "UIView+RoundCorner.h"

@implementation UIView (RoundCorner)

- (void)drawRoundCornerWithStrokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.bounds;
    //  mask.path = [UIBezierPath bezierPathWithRoundedRect:shapeLayerRect cornerRadius:shapeLayerRect.size.width/2].CGPath;//设置圆角
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:self.bounds.size];///cornerRadii 圆角半径
    mask.path = bezierPath.CGPath;/// CGPathRef
    self.layer.mask = mask;
    
    CAShapeLayer *stroke = [CAShapeLayer layer];
    stroke.frame = self.bounds;
    stroke.lineWidth = lineWidth;
    stroke.strokeColor = strokeColor.CGColor;
    stroke.fillColor = [UIColor clearColor].CGColor;
    stroke.path = bezierPath.CGPath;
    [self.layer addSublayer:stroke];
}

@end
