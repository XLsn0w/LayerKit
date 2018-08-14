
#import "UIControl+RepeatTimeInterval.h"
#import <objc/runtime.h>

@implementation UIControl (RepeatTimeInterval)

static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

static const char *UIControl_ingoreEvent = "UIControl_ingoreEvent";

- (NSTimeInterval)repeatTimeInterval {
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval)doubleValue];
}

- (void)setRepeatTimeInterval:(NSTimeInterval)repeatTimeInterval {
    objc_setAssociatedObject(self, UIControl_acceptEventInterval,@(repeatTimeInterval),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRespond {
    return [objc_getAssociatedObject(self, UIControl_ingoreEvent) boolValue];
}

- (void)setIsRespond:(BOOL)isRespond {
    objc_setAssociatedObject(self, UIControl_ingoreEvent, @(isRespond), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
