
#import "UIControl+RepeatTimeInterval.h"
#import <objc/runtime.h>

@implementation UIControl (RepeatTimeInterval)

///添加属性  属性必须是对象  double->NSNumber
static const char *key_repeatTimeInterval = "repeatTimeIntervalKey";
- (NSTimeInterval)repeatTimeInterval {
    return [objc_getAssociatedObject(self, key_repeatTimeInterval) doubleValue];
}

- (void)setRepeatTimeInterval:(NSTimeInterval)repeatTimeInterval {
    objc_setAssociatedObject(self, key_repeatTimeInterval,@(repeatTimeInterval),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *key_isRespond = "isRespondKey";
- (BOOL)isRespond {
    return [objc_getAssociatedObject(self, key_isRespond) boolValue];
}

- (void)setIsRespond:(BOOL)isRespond {
    objc_setAssociatedObject(self, key_isRespond, @(isRespond), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    Method appleMethod = class_getInstanceMethod(self,  @selector(sendAction:to:forEvent:));
    Method customMethod = class_getInstanceMethod(self, @selector(hook_sendAction:to:forEvent:));
    method_exchangeImplementations(appleMethod, customMethod);
}

- (void)hook_sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event {
    if (self.isRespond) return;
    if (self.repeatTimeInterval > 0) {
        self.isRespond = true;
        [self performSelector:@selector(setIsRespond:) withObject:@(false) afterDelay:self.repeatTimeInterval];
    }
    [self hook_sendAction:action to:target forEvent:event];
}

@end
