
#import "UIControl+RepeatTimeInterval.h"
#import <objc/runtime.h>

@implementation UIControl (RepeatTimeInterval)

static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

static const char *UIControl_ingoreEvent = "UIControl_ingoreEvent";

- (NSTimeInterval)repeatTimeInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval)doubleValue];
}

- (void)setRepeatTimeInterval:(NSTimeInterval)repeatTimeInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval,@(repeatTimeInterval),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)JQ_ignoreEvent
{
    return [objc_getAssociatedObject(self, UIControl_ingoreEvent)boolValue];
}

- (void)setJQ_ignoreEvent:(BOOL)JQ_ignoreEvent
{
    objc_setAssociatedObject(self, UIControl_ingoreEvent, @(JQ_ignoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load
{
    Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self, @selector(__JQ_sendAction:to:forEvent:));
    method_exchangeImplementations(a, b);
}

- (void)__JQ_sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event
{
    if (self.JQ_ignoreEvent)return;
    if (self.JQ_acceptEventInterval > 0) {
        self.JQ_ignoreEvent = YES;
        [self performSelector:@selector(setJQ_ignoreEvent:) withObject:@(NO) afterDelay:self.JQ_acceptEventInterval];
    }
    [self __JQ_sendAction:action to:target forEvent:event];
}

@end
