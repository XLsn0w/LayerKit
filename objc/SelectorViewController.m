//
//  SelectorViewController.m
//  LargeImage
//
//  Created by HL on 2018/8/6.
//

#import "SelectorViewController.h"

@interface SelectorViewController ()

@end

@implementation SelectorViewController

//performSelectorOnMainThread:@selector() withObjects:object waitUntilDone:YES
//这个函数表示在主线程上执行方法，YES表示需要阻塞主线程，知道主线程将我们的代码块执行完毕。

/// apple不允许程序员在主线程以外的线程中对ui进行操作，此时我们必须调用performSelectorOnMainThread函数在主线程中完成UI的更新。

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SelectorNoParameter];
    [self performSelector:@selector(xl)];
    
    NSArray *objectArray = @[@{@"methodName":@"DynamicParameterString:",@"value":@"String"}, @{@"methodName":@"DynamicParameterNumber:",@"value":@2}];
    for (NSDictionary *dic in objectArray) {
        [self performSelector:NSSelectorFromString([dic objectForKey:@"methodName"]) withObject:[dic objectForKey:@"value"]];
    }
}

- (void)DynamicParameterString:(NSString *)string {
    NSLog(@"DynamicParameterString: %@",string);
}

- (void)DynamicParameterNumber:(NSNumber *)number{
    NSLog(@"DynamicParameterNumber: %@",number);
}

//- (BOOL)respondsToSelector:(SEL)aSelector {
//    
//}

- (void)SelectorNoParameter {
    NSLog(@"SelectorNoParameter");
}

//performSelector: withObject:是在iOS中的一种方法调用方式。他可以向一个对象传递任何消息，而不需要在编译的时候声明这些方法。所以这也是runtime的一种应用方式.所以performSelector和直接调用方法的区别就在与runtime。
//直接调用 编译器是会自动校验。如果方法不存在，那么直接调用 在编译时候就能够发现，编译器会直接报错。
//但是使用performSelector的话一定是在运行时候才能发现，如果此方法不存在就会崩溃。所以如果使用performSelector的话他就会有个最佳伴侣- (BOOL)respondsToSelector:(SEL)aSelector;来在运行时判断对象是否响应此方法。

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
