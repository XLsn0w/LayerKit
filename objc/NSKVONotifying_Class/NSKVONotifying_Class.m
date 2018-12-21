
//
//  NSKVONotifying_Class.m
//  LayerKit
//
//  Created by TimeForest on 2018/12/20.
//  Copyright © 2018 XL. All rights reserved.
//

#import "NSKVONotifying_Class.h"

@implementation NSKVONotifying_Class

@end


/*XLsn0w*
 
 1.Apple 使用了 isa 混写（isa-swizzling）来实现 KVO 。
 当观察对象A时，KVO机制动态创建一个新的名为：?NSKVONotifying_A的新类，该类继承自对象A的本类，且KVO为NSKVONotifying_A重写观察属性的setter?方法，setter?方法会负责在调用原?setter?方法之前和之后，通知所有观察对象属性值的更改情况。
 
 2.NSKVONotifying_A类剖析：在这个过程，被观察对象的 isa 指针从指向原来的A类，被KVO机制修改为指向系统新创建的子类 NSKVONotifying_A类，来实现当前类属性值改变的监听；
 
 3.所以当我们从应用层面上看来，完全没有意识到有新的类出现，这是系统“隐瞒”了对KVO的底层实现过程，让我们误以为还是原来的类。但是此时如果我们创建一个新的名为“NSKVONotifying_A”的类()，就会发现系统运行到注册KVO的那段代码时程序就崩溃，因为系统在注册监听的时候动态创建了名为NSKVONotifying_A的中间类，并指向这个中间类了。
 
 4.（isa 指针的作用：每个对象都有isa 指针，指向该对象的类，它告诉 Runtime 系统这个对象的类是什么。所以对象注册为观察者时，isa指针指向新子类，那么这个被观察的对象就神奇地变成新子类的对象（或实例）了。）?因而在该对象上对 setter 的调用就会调用已重写的 setter，从而激活键值通知机制。
 
 5.子类setter方法剖析：KVO的键值观察通知依赖于 NSObject 的两个方法:willChangeValueForKey:和 didChangevlueForKey:，在存取数值的前后分别调用2个方法： 被观察属性发生改变之前，willChangeValueForKey:被调用，通知系统该 keyPath?的属性值即将变更；当改变发生后， didChangeValueForKey: 被调用，通知系统该 keyPath?的属性值已经变更；之后，?observeValueForKey:ofObject:change:context: 也会被调用。且重写观察属性的setter?方法这种继承方式的注入是在运行时而不是编译时实现的。
 
 */
