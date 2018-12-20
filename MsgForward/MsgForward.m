//
//  MsgForward.m
//  LayerKit
//
//  Created by TimeForest on 2018/12/20.
//  Copyright © 2018 XL. All rights reserved.
//

#import "MsgForward.h"
#import <objc/runtime.h>

@implementation MsgForward

void functionForMethod(id self, SEL _cmd) {
    NSLog(@"Hello!");
}

Class functionForClassMethod(id self, SEL _cmd) {
    NSLog(@"Hi!");
    return [self class];
}

//1、动态方法解析
+ (BOOL)resolveClassMethod:(SEL)sel {
    NSLog(@"resolveClassMethod");
    NSString *selString = NSStringFromSelector(sel);
    if ([selString isEqualToString:@"hi"])
    {
        Class metaClass = objc_getMetaClass("HelloClass");
        class_addMethod(metaClass, @selector(hi), (IMP)functionForClassMethod, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"resolveInstanceMethod");
    NSString* selString = NSStringFromSelector(sel);
    if ([selString isEqualToString:@"hello"])
    {
        class_addMethod(self, @selector(hello), (IMP)functionForMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}


//2、备用接受者
//动态方法解析无法处理消息，则会走备用接受者。这个备用接受者只能是一个新的对象，不能是self本身，否则就会出现无限循环。如果我们没有指定相应的对象来处理aSelector，则应该调用父类的实现来返回结果。

- (instancetype)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorString = NSStringFromSelector(aSelector);
    // 将消息交给_helper来处理? ?
    if ([selectorString isEqualToString:@"hello"]) {
         return _helper;
    }
    return [super forwardingTargetForSelector:aSelector];
}


//3、完整转发

@end
