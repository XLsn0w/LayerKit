
//
//  TextLayerLabel.m
//  LayerKit
//
//  Created by HL on 2018/8/16.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "TextLayerLabel.h"

@implementation TextLayerLabel

+ (Class)layerClass {
    return [CATextLayer class];
}

- (CATextLayer *)textLayer {
    return (CATextLayer *)self.layer;
}

- (void)setUp {
    //set defaults from UILabel settings
    self.text = self.text;
    self.textColor = self.textColor;
    self.font = self.font;
    
    _textLayer = (CATextLayer *)self.layer;
    _textLayer.frame = self.bounds;
    [self.layer addSublayer:_textLayer];
    
    //set text attributes
    _textLayer.foregroundColor = [UIColor blackColor].CGColor;
    _textLayer.alignmentMode = kCAAlignmentJustified;
    _textLayer.wrapped = YES;
    
    [self.layer display];
}

- (instancetype)initWithFrame:(CGRect)frame {
    //called when creating label programmatically
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setText:(NSString *)text {
    super.text = text;
    /// set layer text
    [self textLayer].string = text;
}

- (void)setTextColor:(UIColor *)textColor {
    super.textColor = textColor;
    //set layer text color
    [self textLayer].foregroundColor = textColor.CGColor;
}

- (void)setFont:(UIFont *)font {
    super.font = font;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    _textLayer.font = fontRef;
    _textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
}

@end
