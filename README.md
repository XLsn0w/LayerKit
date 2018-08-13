# LayerKit

# 图层的树状结构

>巨妖有图层，洋葱也有图层，你懂吗？我们都有图层 -- 史莱克

Core Animation其实是一个令人误解的命名。你可能认为它只是用来做动画的，但实际上它是从一个叫做*Layer Kit*这么一个不怎么和动画有关的名字演变而来，所以做动画这只是Core Animation特性的冰山一角。

Core Animation是一个*复合引擎*，它的职责就是尽可能快地组合屏幕上不同的可视内容，这个内容是被分解成独立的*图层*，存储在一个叫做*图层树*的体系之中。于是这个树形成了**UIKit**以及在iOS应用程序当中你所能在屏幕上看见的一切的基础。

在我们讨论动画之前，我们将从图层树开始，涉及一下Core Animation的*静态*组合以及布局特性。

## 图层和视图
如果你曾经在iOS或者Mac OS平台上写过应用程序，你可能会对*视图*的概念比较熟悉。一个视图就是在屏幕上显示的一个矩形块（比如图片，文字或者视频），它能够拦截类似于鼠标点击或者触摸手势等用户输入。视图在层级关系中可以互相嵌套，一个视图可以管理它的所有子视图的位置。图1.1显示了一种典型的视图层级关系

<img src="./1.1.jpeg" alt="图1.1" title="图1.1" width="700"/>

图1.1 一种典型的iOS屏幕（左边）和形成视图的层级关系（右边）

在iOS当中，所有的视图都从一个叫做`UIVIew`的基类派生而来，`UIView`可以处理触摸事件，可以支持基于*Core Graphics*绘图，可以做仿射变换（例如旋转或者缩放），或者简单的类似于滑动或者渐变的动画。

### CALayer
`CALayer`类在概念上和`UIView`类似，同样也是一些被层级关系树管理的矩形块，同样也可以包含一些内容（像图片，文本或者背景色），管理子图层的位置。它们有一些方法和属性用来做动画和变换。和`UIView`最大的不同是`CALayer`不处理用户的交互。

`CALayer`并不清楚具体的*响应链*（iOS通过视图层级关系用来传送触摸事件的机制），于是它并不能够响应事件，即使它提供了一些方法来判断是否一个触点在图层的范围之内（具体见第三章，“图层的几何学”）

### 平行的层级关系
每一个`UIview`都有一个`CALayer`实例的图层属性，也就是所谓的*backing layer*，视图的职责就是创建并管理这个图层，以确保当子视图在层级关系中添加或者被移除的时候，他们关联的图层也同样对应在层级关系树当中有相同的操作（见图1.2）。

<img src="./1.2.jpeg" alt="图1.2" title="图1.2" width="700"/>

图1.2 图层的树状结构（左边）以及对应的视图层级（右边）

实际上这些背后关联的图层才是真正用来在屏幕上显示和做动画，`UIView`仅仅是对它的一个封装，提供了一些iOS类似于处理触摸的具体功能，以及Core Animation底层方法的高级接口。

但是为什么iOS要基于`UIView`和`CALayer`提供两个平行的层级关系呢？为什么不用一个简单的层级来处理所有事情呢？原因在于要做职责分离，这样也能避免很多重复代码。在iOS和Mac OS两个平台上，事件和用户交互有很多地方的不同，基于多点触控的用户界面和基于鼠标键盘有着本质的区别，这就是为什么iOS有UIKit和`UIView`，但是Mac OS有AppKit和`NSView`的原因。他们功能上很相似，但是在实现上有着显著的区别。

绘图，布局和动画，相比之下就是类似Mac笔记本和桌面系列一样应用于iPhone和iPad触屏的概念。把这种功能的逻辑分开并应用到独立的Core Animation框架，苹果就能够在iOS和Mac OS之间共享代码，使得对苹果自己的OS开发团队和第三方开发者去开发两个平台的应用更加便捷。

实际上，这里并不是两个层级关系，而是四个，每一个都扮演不同的角色，除了视图层级和图层树之外，还存在*呈现树*和*渲染树*，将在第七章“隐式动画”和第十二章“性能调优”分别讨论。

##图层的能力
如果说`CALayer`是`UIView`内部实现细节，那我们为什么要全面地了解它呢？苹果当然为我们提供了优美简洁的`UIView`接口，那么我们是否就没必要直接去处理Core Animation的细节了呢？

某种意义上说的确是这样，对一些简单的需求来说，我们确实没必要处理`CALayer`，因为苹果已经通过`UIView`的高级API间接地使得动画变得很简单。

但是这种简单会不可避免地带来一些灵活上的缺陷。如果你略微想在底层做一些改变，或者使用一些苹果没有在`UIView`上实现的接口功能，这时除了介入Core Animation底层之外别无选择。

我们已经证实了图层不能像视图那样处理触摸事件，那么他能做哪些视图不能做的呢？这里有一些`UIView`没有暴露出来的CALayer的功能：

* 阴影，圆角，带颜色的边框
* 3D变换
* 非矩形范围
* 透明遮罩
* 多级非线性动画

我们将会在后续章节中探索这些功能，首先我们要关注一下在应用程序当中`CALayer`是怎样被利用起来的。

## 使用图层
首先我们来创建一个简单的项目，来操纵一些`layer`的属性。打开Xcode，使用*Single View Application*模板创建一个工程。

在屏幕中央创建一个小视图（大约200 X 200的尺寸），当然你可以手工编码，或者使用Interface Builder（随你方便）。确保你的视图控制器要添加一个视图的属性以便可以直接访问它。我们把它称作`layerView`。

运行项目，应该能在浅灰色屏幕背景中看见一个白色方块（图1.3），如果没看见，可能需要调整一下背景window或者view的颜色

<img src="./1.3.jpeg" alt="图1.3" title="图1.3" width="700"/>

图1.3 灰色背景上的一个白色`UIView`

这并没有什么令人激动的地方，我们来添加一个色块，在白色方块中间添加一个小的蓝色块。

我们当然可以简单地在已经存在的`UIView`上添加一个子视图（随意用代码或者IB），但这不能真正学到任何关于图层的东西。

于是我们来创建一个`CALayer`，并且把它作为我们视图相关图层的子图层。尽管`UIView`类的接口中暴露了图层属性，但是标准的Xcode项目模板并没有包含Core Animation相关头文件。所以如果我们不给项目添加合适的库，是不能够使用任何图层相关的方法或者访问它的属性。所以首先需要添加QuartzCore框架到Build Phases标签（图1.4），然后在vc的.m文件中引入<QuartzCore/QuartzCore.h>库。

<img src="./1.4.jpeg" alt="图1.4" title="图1.4" width="700"/>

图1.4 把QuartzCore库添加到项目

之后就可以在代码中直接引用`CALayer`的属性和方法。在清单1.1中，我们用创建了一个`CALayer`，设置了它的`backgroundColor`属性，然后添加到`layerView`背后相关图层的子图层（这段代码的前提是通过IB创建了`layerView`并做好了连接），图1.5显示了结果。

清单1.1 给视图添加一个蓝色子图层
``` objective-c    
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView;
￼
@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//create sublayer
CALayer *blueLayer = [CALayer layer];
blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
blueLayer.backgroundColor = [UIColor blueColor].CGColor;
//add it to our view
[self.layerView.layer addSublayer:blueLayer];
}
@end
```    
<img src="./1.5.jpeg" alt="图1.5" title="图1.5" width="700"/>

图1.5 白色`UIView`内部嵌套的蓝色`CALayer`

一个视图只有一个相关联的图层（自动创建），同时它也可以支持添加无数多个子图层，从清单1.1可以看出，你可以显示创建一个单独的图层，并且把它直接添加到视图关联图层的子图层。尽管可以这样添加图层，但往往我们只是见简单地处理视图，他们关联的图层并不需要额外地手动添加子图层。

在Mac OS平台，10.8版本之前，一个显著的性能缺陷就是由于用了视图层级而不是单独在一个视图内使用`CALayer`树状层级。但是在iOS平台，使用轻量级的`UIView`类并没有显著的性能影响（当然在Mac OS 10.8之后，`NSView`的性能同样也得到很大程度的提高）。

使用图层关联的视图而不是`CALayer`的好处在于，你能在使用所有`CALayer`底层特性的同时，也可以使用`UIView`的高级API（比如自动排版，布局和事件处理）。

然而，当满足以下条件的时候，你可能更需要使用`CALayer`而不是`UIView`

* 开发同时可以在Mac OS上运行的跨平台应用
* 使用多种`CALayer`的子类（见第六章，“特殊的图层“），并且不想创建额外的`UIView`去包封装它们所有
* 做一些对性能特别挑剔的工作，比如对`UIView`一些可忽略不计的操作都会引起显著的不同（尽管在这种情况下，你可能会想直接使用OpenGL来绘图）


但是这些例子都很少见，总的来说，处理视图会比单独处理图层更加方便。

## 总结
这一章阐述了图层的树状结构，说明了如何在iOS中由`UIView`的层级关系形成的一种平行的`CALayer`层级关系，在后面的实验中，我们创建了自己的`CALayer`，并把它添加到图层树中。

在第二章，“图层关联的图片”，我们将要研究一下`CALayer`关联的图片，以及Core Animation提供的操作显示的一些特性。


# 寄宿图
>图片胜过千言万语，界面抵得上千图片  ——Ben Shneiderman

我们在第一章『图层树』中介绍了CALayer类并创建了一个简单的有蓝色背景的图层。背景颜色还好啦，但是如果它仅仅是展现了一个单调的颜色未免也太无聊了。事实上CALayer类能够包含一张你喜欢的图片，这一章节我们将来探索CALayer的寄宿图（即图层中包含的图）。

## contents属性
CALayer 有一个属性叫做`contents`，这个属性的类型被定义为id，意味着它可以是任何类型的对象。在这种情况下，你可以给`contents`属性赋任何值，你的app都能够编译通过。但是，在实践中，如果你给`contents`赋的不是CGImage，那么你得到的图层将是空白的。

`contents`这个奇怪的表现是由Mac OS的历史原因造成的。它之所以被定义为id类型，是因为在Mac OS系统上，这个属性对CGImage和NSImage类型的值都起作用。如果你试图在iOS平台上将UIImage的值赋给它，只能得到一个空白的图层。一些初识Core Animation的iOS开发者可能会对这个感到困惑。

头疼的不仅仅是我们刚才提到的这个问题。事实上，你真正要赋值的类型应该是CGImageRef，它是一个指向CGImage结构的指针。UIImage有一个CGImage属性，它返回一个"CGImageRef",如果你想把这个值直接赋值给CALayer的`contents`，那你将会得到一个编译错误。因为CGImageRef并不是一个真正的Cocoa对象，而是一个Core Foundation类型。

尽管Core Foundation类型跟Cocoa对象在运行时貌似很像（被称作toll-free bridging），它们并不是类型兼容的，不过你可以通过bridged关键字转换。如果要给图层的寄宿图赋值，你可以按照以下这个方法：

``` objective-c
layer.contents = (__bridge id)image.CGImage;
```

如果你没有使用ARC（自动引用计数），你就不需要__bridge这部分。但是，你干嘛不用ARC？！

让我们来继续修改我们在第一章新建的工程，以便能够展示一张图片而不仅仅是一个背景色。我们已经用代码的方式建立一个图层，那我们就不需要额外的图层了。那么我们就直接把layerView的宿主图层的`contents`属性设置成图片。

清单2.1 更新后的代码。

``` objective-c
@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad]; //load an image
UIImage *image = [UIImage imageNamed:@"Snowman.png"];

//add it directly to our view's layer
self.layerView.layer.contents = (__bridge id)image.CGImage;
}
@end
```

图表2.1 在UIView的宿主图层中显示一张图片

![图2.1](./2.1.png)

我们用这些简单的代码做了一件很有趣的事情：我们利用CALayer在一个普通的UIView中显示了一张图片。这不是一个UIImageView，它不是我们通常用来展示图片的方法。通过直接操作图层，我们使用了一些新的函数，使得UIView更加有趣了。

**contentGravity**

你可能已经注意到了我们的雪人看起来有点。。。胖 ＝＝！ 我们加载的图片并不刚好是一个方的，为了适应这个视图，它有一点点被拉伸了。在使用UIImageView的时候遇到过同样的问题，解决方法就是把`contentMode`属性设置成更合适的值，像这样：

```objective-c
view.contentMode = UIViewContentModeScaleAspectFit;
```
这个方法基本和我们遇到的情况的解决方法已经接近了（你可以试一下 :) ），不过UIView大多数视觉相关的属性比如`contentMode`，对这些属性的操作其实是对对应图层的操作。

CALayer与`contentMode`对应的属性叫做`contentsGravity`，但是它是一个NSString类型，而不是像对应的UIKit部分，那里面的值是枚举。`contentsGravity`可选的常量值有以下一些：

* kCAGravityCenter
* kCAGravityTop
* kCAGravityBottom
* kCAGravityLeft
* kCAGravityRight
* kCAGravityTopLeft
* kCAGravityTopRight
* kCAGravityBottomLeft
* kCAGravityBottomRight
* kCAGravityResize
* kCAGravityResizeAspect
* kCAGravityResizeAspectFill

和`cotentMode`一样，`contentsGravity`的目的是为了决定内容在图层的边界中怎么对齐，我们将使用kCAGravityResizeAspect，它的效果等同于UIViewContentModeScaleAspectFit， 同时它还能在图层中等比例拉伸以适应图层的边界。

```objective-c
self.layerView.layer.contentsGravity = kCAGravityResizeAspect;
```

图2.2 可以看到结果

![image](./2.2.png)

图2.2 正确地设置`contentsGravity`的值

##contentsScale

`contentsScale`属性定义了寄宿图的像素尺寸和视图大小的比例，默认情况下它是一个值为1.0的浮点数。

`contentsScale`的目的并不是那么明显。它并不是总会对屏幕上的寄宿图有影响。如果你尝试对我们的例子设置不同的值，你就会发现根本没任何影响。因为`contents`由于设置了`contentsGravity`属性，所以它已经被拉伸以适应图层的边界。

如果你只是单纯地想放大图层的`contents`图片，你可以通过使用图层的`transform`和`affineTransform`属性来达到这个目的（见第五章『Transforms』，里面对此有解释），但放大也不是`contentsScale`的目的所在.

`contentsScale`属性其实属于支持高分辨率（又称Hi-DPI或Retina）屏幕机制的一部分。它用来判断在绘制图层的时候应该为寄宿图创建的空间大小，和需要显示的图片的拉伸度（假设并没有设置`contentsGravity`属性）。UIView有一个类似功能但是非常少用到的`contentScaleFactor`属性。

如果`contentsScale`设置为1.0，将会以每个点1个像素绘制图片，如果设置为2.0，则会以每个点2个像素绘制图片，这就是我们熟知的Retina屏幕。（如果你对像素和点的概念不是很清楚的话，这个章节的后面部分将会对此做出解释）。

这并不会对我们在使用kCAGravityResizeAspect时产生任何影响，因为它就是拉伸图片以适应图层而已，根本不会考虑到分辨率问题。但是如果我们把`contentsGravity`设置为kCAGravityCenter（这个值并不会拉伸图片），那将会有很明显的变化（如图2.3）

![图2.3](./2.3.png)

图2.3 用错误的`contentsScale`属性显示Retina图片

如你所见，我们的雪人不仅有点大还有点像素的颗粒感。那是因为和UIImage不同，CGImage没有拉伸的概念。当我们使用UIImage类去读取我们的雪人图片的时候，它读取了高质量的Retina版本的图片。但是当我们用CGImage来设置我们的图层的内容时，拉伸这个因素在转换的时候就丢失了。不过我们可以通过手动设置`contentsScale`来修复这个问题（如2.2清单），图2.4是结果

```objective-c
@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad]; //load an image
UIImage *image = [UIImage imageNamed:@"Snowman.png"]; //add it directly to our view's layer
self.layerView.layer.contents = (__bridge id)image.CGImage; //center the image
self.layerView.layer.contentsGravity = kCAGravityCenter;

//set the contentsScale to match image
self.layerView.layer.contentsScale = image.scale;
}

@end
```

![图2.4](./2.4.png)

图2.4 同样的Retina图片设置了正确的`contentsScale`之后

当用代码的方式来处理寄宿图的时候，一定要记住要手动的设置图层的`contentsScale`属性，否则，你的图片在Retina设备上就显示得不正确啦。代码如下：

```objective-c
layer.contentsScale = [UIScreen mainScreen].scale;
```

## maskToBounds

现在我们的雪人总算是显示了正确的大小，不过你也许已经发现了另外一些事情：它超出了视图的边界。默认情况下，UIView仍然会绘制超过边界的内容或是子视图，在CALayer下也是这样的。

UIView有一个叫做`clipsToBounds`的属性可以用来决定是否显示超出边界的内容，CALayer对应的属性叫做`masksToBounds`，把它设置为YES，雪人就在边界里啦～（如图2.5）

![图2.5](./2.5.png)

图2.5 使用`masksToBounds`来修建图层内容

## contentsRect

CALayer的`contentsRect`属性允许我们在图层边框里显示寄宿图的一个子域。这涉及到图片是如何显示和拉伸的，所以要比`contentsGravity`灵活多了

和`bounds`，`frame`不同，`contentsRect`不是按点来计算的，它使用了*单位坐标*，单位坐标指定在0到1之间，是一个相对值（而像素和点是绝对值）。所以它们是相对于寄宿图的尺寸的。iOS使用了以下的坐标系统：

* 点 —— 在iOS和Mac OS中最常见的坐标体系。点就像是虚拟的像素，也被称作逻辑像素。在标准清晰度的设备上，一个点就是一个像素，但是在Retina设备上，一个点等于2*2个像素。iOS用点作为屏幕的坐标测算体系就是为了在Retina设备和普通设备上能有一致的视觉效果。
* 像素 —— 物理像素坐标并不会用来屏幕布局，但是它们在处理图片时仍然是相关的。UIImage可以识别屏幕分辨，并以点为单位指定其大小。但是一些底层的图片表示如CGImage就会使用像素，所以你要清楚在Retina设备和普通设备上，它们表现出来了不同的大小。
* 单位 —— 对于与图片大小或是图层边界相关的显示，单位坐标是一个方便的度量方式， 当大小改变的时候，也不需要再次调整。单位坐标在OpenGL这种纹理坐标系统中用得很多，Core Animation中也用到了单位坐标。

默认的`contentsRect`是{0, 0, 1, 1}，这意味着整个寄宿图默认都是可见的，如果我们指定一个小一点的矩形，图片就会被裁剪（如图2.6）

![图2.6](./2.6.png)

图2.6 一个自定义的`contentsRect`（左）和之前显示的内容（右）

事实上给`contentsRect`设置一个负数的原点或是大于{1, 1}的尺寸也是可以的。这种情况下，最外面的像素会被拉伸以填充剩下的区域。

`contentsRect`最有趣的用处之一是它能够使用*image sprites*（图片拼合）。如果你有游戏编程的经验，那么你一定对图片拼合的概念很熟悉，图片能够在屏幕上独立地变更位置。抛开游戏编程不谈，这个技术常用来指代载入拼合的图片，跟移动图片一点关系也没有。

通常，多张图片可以拼合后打包整合到一张大图上一次性载入。相比多次载入不同的图片，这样做能够带来很多方面的好处：内存使用，载入时间，渲染性能等等

2D游戏引擎比如Cocos2D使用了拼合技术，它使用OpenGL来显示图片。不过我们可以使用拼合在一个普通的UIKit应用中，对！就是使用`contentsRect`

首先，我们需要一个拼合后的图表 —— 一个包含小一些的拼合图的大图片。如图2.7所示：

![图2.7](./2.7.png)

接下来，我们要在app中载入并显示这些拼合图。规则很简单：像平常一样载入我们的大图，然后把它赋值给四个独立的图层的`contents`，然后设置每个图层的`contentsRect`来去掉我们不想显示的部分。

我们的工程中需要一些额外的视图。（为了避免太多代码。我们将使用Interface Builder来访问它们的位置，如果你愿意还是可以用代码的方式来实现的）。清单2.3有需要的代码，图2.8展示了结果

```objective-c

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *coneView;
@property (nonatomic, weak) IBOutlet UIView *shipView;
@property (nonatomic, weak) IBOutlet UIView *iglooView;
@property (nonatomic, weak) IBOutlet UIView *anchorView;
@end

@implementation ViewController

- (void)addSpriteImage:(UIImage *)image withContentRect:(CGRect)rect ￼toLayer:(CALayer *)layer //set image
{
layer.contents = (__bridge id)image.CGImage;

//scale contents to fit
layer.contentsGravity = kCAGravityResizeAspect;

//set contentsRect
layer.contentsRect = rect;
}

- (void)viewDidLoad 
{
[super viewDidLoad]; //load sprite sheet
UIImage *image = [UIImage imageNamed:@"Sprites.png"];
//set igloo sprite
[self addSpriteImage:image withContentRect:CGRectMake(0, 0, 0.5, 0.5) toLayer:self.iglooView.layer];
//set cone sprite
[self addSpriteImage:image withContentRect:CGRectMake(0.5, 0, 0.5, 0.5) toLayer:self.coneView.layer];
//set anchor sprite
[self addSpriteImage:image withContentRect:CGRectMake(0, 0.5, 0.5, 0.5) toLayer:self.anchorView.layer];
//set spaceship sprite
[self addSpriteImage:image withContentRect:CGRectMake(0.5, 0.5, 0.5, 0.5) toLayer:self.shipView.layer];
}
@end
```
![图2.8](./2.8.png)

拼合不仅减小了应用程序的大小，还有效地提高了载入性能（单张大图比多张小图载入得更快），但是手动排列可能很麻烦，如果你需要在一个已经创建好的拼合图上做一些尺寸上的修改或者其他变动，无疑是比较麻烦的。

Mac上有一些商业软件可以为你自动拼合图片，这些工具自动生成一个包含拼合后的坐标的XML或者plist文件，拼合图片的使用大大简化。这个文件可以和图片一同载入，并给每个拼合的图层设置`contentsRect`，这样开发者就不用手动写代码来摆放位置了。

这些文件通常在OpenGL游戏中使用，不过呢，你要是有兴趣在一些常见的app中使用拼合技术的话，有一个叫做LayerSprites的开源库（[https://github.com/nicklockwood/LayerSprites](https://github.com/nicklockwood/LayerSprites))，它能够读取Cocos2D格式中的拼合图并在普通的Core Animation层中显示出来。

## contentsCenter

本章我们介绍的最后一个和内容有关的属性是`contentsCenter`，看名字你可能会以为它可能跟图片的位置有关，不过这名字着实误导了你。`contentsCenter`其实是一个CGRect，它定义了图层中的可拉伸区域和一个固定的边框。 改变`contentsCenter`的值并不会影响到寄宿图的显示，除非这个图层的大小改变了，你才看得到效果。

默认情况下，`contentsCenter`是{0, 0, 1, 1}，这意味着如果layer的大小改变了，那么寄宿图将会根据 contentsGravity 均匀地拉伸开。但是如果我们增加原点的值并减小尺寸。我们会在图片的周围创造一个边框。图2.9展示了`contentsCenter`设置为{0.25, 0.25, 0.5, 0.5}的效果。

![图2.9](./2.9.png)

图2.9 `contentsCenter`的例子

这意味着我们可以随意重设尺寸，边框仍然会是连续的。它工作起来的效果和UIImage里的-resizableImageWithCapInsets: 方法效果非常类似，但是它可以运用到任何寄宿图，甚至包括在Core Graphics运行时绘制的图形（本章稍后会讲到）。

![图2.10](./2.10.png)

图2.10 同一图片使用不同的`contentsCenter`

清单2.4 演示了如何编写这些可拉伸视图。不过，contentsCenter的另一个很酷的特性就是，它可以在Interface Builder里面配置，根本不用写代码。如图2.11

清单2.4 用`contentsCenter`设置可拉伸视图

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *button1;
@property (nonatomic, weak) IBOutlet UIView *button2;

@end

@implementation ViewController

- (void)addStretchableImage:(UIImage *)image withContentCenter:(CGRect)rect toLayer:(CALayer *)layer
{  
//set image
layer.contents = (__bridge id)image.CGImage;

//set contentsCenter
layer.contentsCenter = rect;
}

- (void)viewDidLoad
{
[super viewDidLoad]; //load button image
UIImage *image = [UIImage imageNamed:@"Button.png"];

//set button 1
[self addStretchableImage:image withContentCenter:CGRectMake(0.25, 0.25, 0.5, 0.5) toLayer:self.button1.layer];

//set button 2
[self addStretchableImage:image withContentCenter:CGRectMake(0.25, 0.25, 0.5, 0.5) toLayer:self.button2.layer];
}

@end
```
![图2.11](./2.11.png)

图2.11 用Interface Builder 探测窗口控制`contentsCenter`属性

##Custome Drawing

给`contents`赋CGImage的值不是唯一的设置寄宿图的方法。我们也可以直接用Core Graphics直接绘制寄宿图。能够通过继承UIView并实现`-drawRect:`方法来自定义绘制。

`-drawRect:` 方法没有默认的实现，因为对UIView来说，寄宿图并不是必须的，它不在意那到底是单调的颜色还是有一个图片的实例。如果UIView检测到`-drawRect:` 方法被调用了，它就会为视图分配一个寄宿图，这个寄宿图的像素尺寸等于视图大小乘以 `contentsScale`的值。

如果你不需要寄宿图，那就不要创建这个方法了，这会造成CPU资源和内存的浪费，这也是为什么苹果建议：如果没有自定义绘制的任务就不要在子类中写一个空的-drawRect:方法。

当视图在屏幕上出现的时候 `-drawRect:`方法就会被自动调用。`-drawRect:`方法里面的代码利用Core Graphics去绘制一个寄宿图，然后内容就会被缓存起来直到它需要被更新（通常是因为开发者调用了`-setNeedsDisplay`方法，尽管影响到表现效果的属性值被更改时，一些视图类型会被自动重绘，如`bounds`属性）。虽然`-drawRect:`方法是一个UIView方法，事实上都是底层的CALayer安排了重绘工作和保存了因此产生的图片。

CALayer有一个可选的`delegate`属性，实现了`CALayerDelegate`协议，当CALayer需要一个内容特定的信息时，就会从协议中请求。CALayerDelegate是一个非正式协议，其实就是说没有CALayerDelegate @protocol可以让你在类里面引用啦。你只需要调用你想调用的方法，CALayer会帮你做剩下的。（`delegate`属性被声明为id类型，所有的代理方法都是可选的）。

当需要被重绘时，CALayer会请求它的代理给它一个寄宿图来显示。它通过调用下面这个方法做到的:

```objective-c
(void)displayLayer:(CALayer *)layer;
```

趁着这个机会，如果代理想直接设置`contents`属性的话，它就可以这么做，不然没有别的方法可以调用了。如果代理不实现`-displayLayer:`方法，CALayer就会转而尝试调用下面这个方法：

```objective-c
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
```

在调用这个方法之前，CALayer创建了一个合适尺寸的空寄宿图（尺寸由`bounds`和`contentsScale`决定）和一个Core Graphics的绘制上下文环境，为绘制寄宿图做准备，它作为ctx参数传入。

让我们来继续第一章的项目让它实现CALayerDelegate并做一些绘图工作吧（见清单2.5）.图2.12是它的结果

清单2.5 实现CALayerDelegate

```objective-c
@implementation ViewController
- (void)viewDidLoad
{
[super viewDidLoad];
￼
//create sublayer
CALayer *blueLayer = [CALayer layer];
blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
blueLayer.backgroundColor = [UIColor blueColor].CGColor;

//set controller as layer delegate
blueLayer.delegate = self;

//ensure that layer backing image uses correct scale
blueLayer.contentsScale = [UIScreen mainScreen].scale; //add layer to our view
[self.layerView.layer addSublayer:blueLayer];

//force layer to redraw
[blueLayer display];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
//draw a thick red circle
CGContextSetLineWidth(ctx, 10.0f); 
CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
CGContextStrokeEllipseInRect(ctx, layer.bounds);
}
@end
```

![图2.12](./2.12.png)

图2.12 实现CALayerDelegate来绘制图层

注意一下一些有趣的事情：

* 我们在blueLayer上显式地调用了`-display`。不同于UIView，当图层显示在屏幕上时，CALayer不会自动重绘它的内容。它把重绘的决定权交给了开发者。
* 尽管我们没有用`masksToBounds`属性，绘制的那个圆仍然沿边界被裁剪了。这是因为当你使用CALayerDelegate绘制寄宿图的时候，并没有对超出边界外的内容提供绘制支持。

现在你理解了CALayerDelegate，并知道怎么使用它。但是除非你创建了一个单独的图层，你几乎没有机会用到CALayerDelegate协议。因为当UIView创建了它的宿主图层时，它就会自动地把图层的delegate设置为它自己，并提供了一个`-displayLayer:`的实现，那所有的问题就都没了。

当使用寄宿了视图的图层的时候，你也不必实现`-displayLayer:`和`-drawLayer:inContext:`方法来绘制你的寄宿图。通常做法是实现UIView的`-drawRect:`方法，UIView就会帮你做完剩下的工作，包括在需要重绘的时候调用`-display`方法。

## 总结

本章介绍了寄宿图和一些相关的属性。你学到了如何显示和放置图片， 使用拼合技术来显示， 以及用CALayerDelegate和Core Graphics来绘制图层内容。

在第三章，"图层几何学"中，我们将会探讨一下图层的几何，观察它们是如何放置和改变相互的尺寸的。



# 图层几何学
>*不熟悉几何学的人就不要来这里了* --柏拉图学院入口的签名

在第二章里面，我们介绍了图层背后的图片，和一些控制图层坐标和旋转的属性。在这一章中，我们将要看一看图层内部是如何根据父图层和兄弟图层来控制位置和尺寸的。另外我们也会涉及如何管理图层的几何结构，以及它是如何被自动调整和自动布局影响的。

## 布局
`UIView`有三个比较重要的布局属性：`frame`，`bounds`和`center`，`CALayer`对应地叫做`frame`，`bounds`和`position`。为了能清楚区分，图层用了“position”，视图用了“center”，但是他们都代表同样的值。

`frame`代表了图层的外部坐标（也就是在父图层上占据的空间），`bounds`是内部坐标（{0, 0}通常是图层的左上角），`center`和`position`都代表了相对于父图层`anchorPoint`所在的位置。`anchorPoint`的属性将会在后续介绍到，现在把它想成图层的中心点就好了。图3.1显示了这些属性是如何相互依赖的。

<img src="./3.1.jpeg" alt="图3.1" title="图3.1" width="700"/>

图3.1 `UIView`和`CALayer`的坐标系

视图的`frame`，`bounds`和`center`属性仅仅是*存取方法*，当操纵视图的`frame`，实际上是在改变位于视图下方`CALayer`的`frame`，不能够独立于图层之外改变视图的`frame`。

对于视图或者图层来说，`frame`并不是一个非常清晰的属性，它其实是一个虚拟属性，是根据`bounds`，`position`和`transform`计算而来，所以当其中任何一个值发生改变，frame都会变化。相反，改变frame的值同样会影响到他们当中的值

记住当对图层做变换的时候，比如旋转或者缩放，`frame`实际上代表了覆盖在图层旋转之后的整个轴对齐的矩形区域，也就是说`frame`的宽高可能和`bounds`的宽高不再一致了（图3.2）

<img src="./3.2.jpeg" alt="图3.2" title="图3.2" width="700"/>

图3.2 旋转一个视图或者图层之后的`frame`属性


## 锚点
之前提到过，视图的`center`属性和图层的`position`属性都指定了`anchorPoint`相对于父图层的位置。图层的`anchorPoint`通过`position`来控制它的`frame`的位置，你可以认为`anchorPoint`是用来移动图层的*把柄*。

默认来说，`anchorPoint`位于图层的中点，所以图层的将会以这个点为中心放置。`anchorPoint`属性并没有被`UIView`接口暴露出来，这也是视图的position属性被叫做“center”的原因。但是图层的`anchorPoint`可以被移动，比如你可以把它置于图层`frame`的左上角，于是图层的内容将会向右下角的`position`方向移动（图3.3），而不是居中了。

<img src="./3.3.jpeg" alt="图3.3" title="图3.3" width="700"/>

图3.3 改变`anchorPoint`的效果

和第二章提到的`contentsRect`和`contentsCenter`属性类似，`anchorPoint`用*单位坐标*来描述，也就是图层的相对坐标，图层左上角是{0, 0}，右下角是{1, 1}，因此默认坐标是{0.5, 0.5}。`anchorPoint`可以通过指定x和y值小于0或者大于1，使它放置在图层范围之外。

注意在图3.3中，当改变了`anchorPoint`，`position`属性保持固定的值并没有发生改变，但是`frame`却移动了。

那在什么场合需要改变`anchorPoint`呢？既然我们可以随意改变图层位置，那改变`anchorPoint`不会造成困惑么？为了举例说明，我们来举一个实用的例子，创建一个模拟闹钟的项目。

钟面和钟表由四张图片组成（图3.4），为了简单说明，我们还是用传统的方式来装载和加载图片，使用四个`UIImageView`实例（当然你也可以用正常的视图，设置他们图层的`contents`图片）。

<img src="./3.4.jpeg" alt="图3.4" title="图3.4" width="700"/>

图3.4 组成钟面和钟表的四张图片

闹钟的组件通过IB来排列（图3.5），这些图片视图嵌套在一个容器视图之内，并且自动调整和自动布局都被禁用了。这是因为自动调整会影响到视图的`frame`，而根据图3.2的演示，当视图旋转的时候，`frame`是会发生改变的，这将会导致一些布局上的失灵。

我们用`NSTimer`来更新闹钟，使用视图的`transform`属性来旋转钟表（如果你对这个属性不太熟悉，不要着急，我们将会在第5章“变换”当中详细说明），具体代码见清单3.1

<img src="./3.5.jpeg" alt="图3.5" title="图3.5" width="700"/>

图3.5 在Interface Builder中布局闹钟视图

清单3.1 **Clock**
```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *hourHand;
@property (nonatomic, weak) IBOutlet UIImageView *minuteHand;
@property (nonatomic, weak) IBOutlet UIImageView *secondHand;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//start timer
self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
￼
//set initial hand positions
[self tick];
}

- (void)tick
{
//convert time to hours, minutes and seconds
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
CGFloat hoursAngle = (components.hour / 12.0) * M_PI * 2.0;
//calculate hour hand angle //calculate minute hand angle
CGFloat minsAngle = (components.minute / 60.0) * M_PI * 2.0;
//calculate second hand angle
CGFloat secsAngle = (components.second / 60.0) * M_PI * 2.0;
//rotate hands
self.hourHand.transform = CGAffineTransformMakeRotation(hoursAngle);
self.minuteHand.transform = CGAffineTransformMakeRotation(minsAngle);
self.secondHand.transform = CGAffineTransformMakeRotation(secsAngle);
}

@end
```

运行项目，看起来有点奇怪（图3.6），因为钟表的图片在围绕着中心旋转，这并不是我们期待的一个支点。

<img src="./3.6.jpeg" alt="图3.6" title="图3.6" width="700"/>

图3.6 钟面，和不对齐的钟指针

你也许会认为可以在Interface Builder当中调整指针图片的位置来解决，但其实并不能达到目的，因为如果不放在钟面中间的话，同样不能正确的旋转。

也许在图片末尾添加一个透明空间也是个解决方案，但这样会让图片变大，也会消耗更多的内存，这样并不优雅。

更好的方案是使用`anchorPoint`属性，我们来在`-viewDidLoad`方法中添加几行代码来给每个钟指针的`anchorPoint`做一些平移（清单3.2），图3.7显示了正确的结果。

清单3.2
```objective-c
- (void)viewDidLoad 
{
[super viewDidLoad];
// adjust anchor points

self.secondHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f); 
self.minuteHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f); 
self.hourHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);


// start timer
} 
```

<img src="./3.7.jpeg" alt="图3.7" title="图3.7" width="700"/>

图3.7 钟面，和正确对齐的钟指针

## 坐标系
和视图一样，图层在图层树当中也是相对于父图层按层级关系放置，一个图层的`position`依赖于它父图层的`bounds`，如果父图层发生了移动，它的所有子图层也会跟着移动。

这样对于放置图层会更加方便，因为你可以通过移动根图层来将它的子图层作为一个整体来移动，但是有时候你需要知道一个图层的*绝对*位置，或者是相对于另一个图层的位置，而不是它当前父图层的位置。

`CALayer`给不同坐标系之间的图层转换提供了一些工具类方法：

- (CGPoint)convertPoint:(CGPoint)point fromLayer:(CALayer *)layer; 
- (CGPoint)convertPoint:(CGPoint)point toLayer:(CALayer *)layer; 
- (CGRect)convertRect:(CGRect)rect fromLayer:(CALayer *)layer;
- (CGRect)convertRect:(CGRect)rect toLayer:(CALayer *)layer;

这些方法可以把定义在一个图层坐标系下的点或者矩形转换成另一个图层坐标系下的点或者矩形

### 翻转的几何结构

常规说来，在iOS上，一个图层的`position`位于父图层的左上角，但是在Mac OS上，通常是位于左下角。Core Animation可以通过`geometryFlipped`属性来适配这两种情况，它决定了一个图层的坐标是否相对于父图层垂直翻转，是一个`BOOL`类型。在iOS上通过设置它为`YES`意味着它的子图层将会被垂直翻转，也就是将会沿着底部排版而不是通常的顶部（它的所有子图层也同理，除非把它们的`geometryFlipped`属性也设为`YES`）。

### Z坐标轴

和`UIView`严格的二维坐标系不同，`CALayer`存在于一个三维空间当中。除了我们已经讨论过的`position`和`anchorPoint`属性之外，`CALayer`还有另外两个属性，`zPosition`和`anchorPointZ`，二者都是在Z轴上描述图层位置的浮点类型。

注意这里并没有更*深*的属性来描述由宽和高做成的`bounds`了，图层是一个完全扁平的对象，你可以把它们想象成类似于一页二维的坚硬的纸片，用胶水粘成一个空洞，就像三维结构的折纸一样。

`zPosition`属性在大多数情况下其实并不常用。在第五章，我们将会涉及`CATransform3D`，你会知道如何在三维空间移动和旋转图层，除了做变换之外，`zPosition`最实用的功能就是改变图层的*显示顺序*了。

通常，图层是根据它们子图层的`sublayers`出现的顺序来类绘制的，这就是所谓的*画家的算法*--就像一个画家在墙上作画--后被绘制上的图层将会遮盖住之前的图层，但是通过增加图层的`zPosition`，就可以把图层向相机方向*前置*，于是它就在所有其他图层的*前面*了（或者至少是小于它的`zPosition`值的图层的前面）。

这里所谓的“相机”实际上是相对于用户是视角，这里和iPhone背后的内置相机没任何关系。

图3.8显示了在Interface Builder内的一对视图，正如你所见，首先出现在视图层级绿色的视图被绘制在红色视图的后面。

<img src="./3.8.jpeg" alt="图3.8" title="图3.8" width="700"/>

图3.8 在视图层级中绿色视图被绘制在红色视图的后面

我们希望在真实的应用中也能显示出绘图的顺序，同样地，如果我们提高绿色视图的`zPosition`（清单3.3），我们会发现顺序就反了（图3.9）。其实并不需要增加太多，视图都非常地薄，所以给`zPosition`提高一个像素就可以让绿色视图前置，当然0.1或者0.0001也能够做到，但是最好不要这样，因为浮点类型四舍五入的计算可能会造成一些不便的麻烦。

清单3.3

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *greenView;
@property (nonatomic, weak) IBOutlet UIView *redView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
￼
//move the green view zPosition nearer to the camera
self.greenView.layer.zPosition = 1.0f;
}
@end
```

<img src="./3.9.jpeg" alt="图3.9" title="图3.9" width="700"/>

图3.9 绿色视图被绘制在红色视图的前面

##Hit Testing
第一章“图层树”证实了最好使用图层相关视图，而不是创建独立的图层关系。其中一个原因就是要处理额外复杂的触摸事件。

`CALayer`对响应链一无所知，所以它不能直接处理触摸事件或者手势。但是它有一系列的方法帮你处理事件：`-containsPoint:`和`-hitTest:`。

` -containsPoint: `接受一个在本图层坐标系下的`CGPoint`，如果这个点在图层`frame`范围内就返回`YES`。如清单3.4所示第一章的项目的另一个合适的版本，也就是使用`-containsPoint:`方法来判断到底是白色还是蓝色的图层被触摸了
（图3.10）。这需要把触摸坐标转换成每个图层坐标系下的坐标，结果很不方便。

清单3.4 使用containsPoint判断被点击的图层

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView;
@property (nonatomic, weak) CALayer *blueLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//create sublayer
self.blueLayer = [CALayer layer];
self.blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
self.blueLayer.backgroundColor = [UIColor blueColor].CGColor;
//add it to our view
[self.layerView.layer addSublayer:self.blueLayer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//get touch position relative to main view
CGPoint point = [[touches anyObject] locationInView:self.view];
//convert point to the white layer's coordinates
point = [self.layerView.layer convertPoint:point fromLayer:self.view.layer];
//get layer using containsPoint:
if ([self.layerView.layer containsPoint:point]) {
//convert point to blueLayer’s coordinates
point = [self.blueLayer convertPoint:point fromLayer:self.layerView.layer];
if ([self.blueLayer containsPoint:point]) {
[[[UIAlertView alloc] initWithTitle:@"Inside Blue Layer" 
message:nil
delegate:nil 
cancelButtonTitle:@"OK"
otherButtonTitles:nil] show];
} else {
[[[UIAlertView alloc] initWithTitle:@"Inside White Layer"
message:nil 
delegate:nil
cancelButtonTitle:@"OK"
otherButtonTitles:nil] show];
}
}
}

@end
```

<img src="./3.10.jpeg" alt="图3.10" title="图3.10" width="700"/>

图3.10 点击图层被正确标识

`-hitTest:`方法同样接受一个`CGPoint`类型参数，而不是`BOOL`类型，它返回图层本身，或者包含这个坐标点的叶子节点图层。这意味着不再需要像使用`-containsPoint:`那样，人工地在每个子图层变换或者测试点击的坐标。如果这个点在最外面图层的范围之外，则返回nil。具体使用`-hitTest:`方法被点击图层的代码如清单3.5所示。

清单3.5 使用hitTest判断被点击的图层

```objective-c
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//get touch position
CGPoint point = [[touches anyObject] locationInView:self.view];
//get touched layer
CALayer *layer = [self.layerView.layer hitTest:point];
//get layer using hitTest
if (layer == self.blueLayer) {
[[[UIAlertView alloc] initWithTitle:@"Inside Blue Layer"
message:nil
delegate:nil
cancelButtonTitle:@"OK"
otherButtonTitles:nil] show];
} else if (layer == self.layerView.layer) {
[[[UIAlertView alloc] initWithTitle:@"Inside White Layer"
message:nil
delegate:nil
cancelButtonTitle:@"OK"
otherButtonTitles:nil] show];
}
}
```

注意当调用图层的`-hitTest:`方法时，测算的顺序严格依赖于图层树当中的图层顺序（和UIView处理事件类似）。之前提到的`zPosition`属性可以明显改变屏幕上图层的顺序，但不能改变触摸事件被处理的顺序。

这意味着如果改变了图层的z轴顺序，你会发现将不能够检测到最前方的视图点击事件，这是因为被另一个图层遮盖住了，虽然它的`zPosition`值较小，但是在图层树中的顺序靠前。我们将在第五章详细讨论这个问题。

## 自动布局

你可能用过`UIViewAutoresizingMask`类型的一些常量，应用于当父视图改变尺寸的时候，相应`UIView`的`frame`也跟着更新的场景（通常用于横竖屏切换）。

在iOS6中，苹果介绍了*自动布局*机制，它和自动调整不同，并且更加复杂，它通过指定组合形成线性方程组和不等式的约束，定义视图的位置和大小。

在Mac OS平台，`CALayer`有一个叫做`layoutManager`的属性可以通过`CALayoutManager`协议和`CAConstraintLayoutManager`类来实现自动排版的机制。但由于某些原因，这在iOS上并不适用。

当使用视图的时候，可以充分利用`UIView`类接口暴露出来的`UIViewAutoresizingMask`和`NSLayoutConstraint`API，但如果想随意控制`CALayer`的布局，就需要手工操作。最简单的方法就是使用`CALayerDelegate`如下函数：

- (void)layoutSublayersOfLayer:(CALayer *)layer;

当图层的`bounds`发生改变，或者图层的`-setNeedsLayout`方法被调用的时候，这个函数将会被执行。这使得你可以手动地重新摆放或者重新调整子图层的大小，但是不能像`UIView`的`autoresizingMask`和`constraints`属性做到自适应屏幕旋转。

这也是为什么最好使用视图而不是单独的图层来构建应用程序的另一个重要原因之一。


## 总结

本章涉及了`CALayer`的几何结构，包括它的`frame`，`position`和`bounds`，介绍了三维空间内图层的概念，以及如何在独立的图层内响应事件，最后简单说明了在iOS平台中，Core Animation对自动调整和自动布局支持的缺乏。

在第四章“视觉效果”当中，我们接着介绍一些图层外表的特性。


# 视觉效果

>嗯，圆和椭圆还不错，但如果是带圆角的矩形呢？

>我们现在能做到那样了么？

>史蒂芬·乔布斯

我们在第三章『图层几何学』中讨论了图层的frame，第二章『寄宿图』则讨论了图层的寄宿图。但是图层不仅仅可以是图片或是颜色的容器；还有一系列内建的特性使得创造美丽优雅的令人深刻的界面元素成为可能。在这一章，我们将会探索一些能够通过使用CALayer属性实现的视觉效果。

## 圆角

圆角矩形是iOS的一个标志性审美特性。这在iOS的每一个地方都得到了体现，不论是主屏幕图标，还是警告弹框，甚至是文本框。按照这流行程度，你可能会认为一定有不借助Photoshop就能轻易创建圆角矩形的方法。恭喜你，猜对了。

CALayer有一个叫做`conrnerRadius`的属性控制着图层角的曲率。它是一个浮点数，默认为0（为0的时候就是直角），但是你可以把它设置成任意值。默认情况下，这个曲率值只影响背景颜色而不影响背景图片或是子图层。不过，如果把`masksToBounds`设置成YES的话，图层里面的所有东西都会被截取。

我们可以通过一个简单的项目来演示这个效果。在Interface Builder中，我们放置一些视图，他们有一些子视图。而且这些子视图有一些超出了边界（如图4.1）。你可能无法看到他们超出了边界，因为在编辑界面的时候，超出的部分总是被Interface Builder裁切掉了。不过，你相信我就好了 :)

![图4.1](./4.1.png)

图4.1 两个白色的大视图，他们都包含了小一些的红色视图。

然后在代码中，我们设置角的半径为20个点，并裁剪掉第一个视图的超出部分（见清单4.1）。技术上来说，这些属性都可以在Interface Builder的探测板中分别通过『用户定义运行时属性』和勾选『裁剪子视图』(Clip Subviews)选择框来直接设置属性的值。不过，在这个示例中，代码能够表示得更清楚。图4.2是运行代码的结果

清单4.1 设置`cornerRadius`和`masksToBounds`

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView1;
@property (nonatomic, weak) IBOutlet UIView *layerView2;

@end

@implementation ViewController
- (void)viewDidLoad
{￼￼￼
[super viewDidLoad];

//set the corner radius on our layers
self.layerView1.layer.cornerRadius = 20.0f;
self.layerView2.layer.cornerRadius = 20.0f;

//enable clipping on the second layer
self.layerView2.layer.masksToBounds = YES;
}
@end
```

![图4.2](./4.2.png)

右图中，红色的子视图沿角半径被裁剪了

如你所见，右边的子视图沿边界被裁剪了。

单独控制每个层的圆角曲率是不可能的，所以如果你想创建既有圆角又有直角的图层或视图时，就需要一些不同的方法。比如使用一个图层蒙板（本章稍后会讲到）或者是CAShapeLayer（见第六章『专用图层』）。

## 图层边框

CALayer另外两个非常有用属性就是`borderWidth`和`borderColor`。二者共同定义了图层边的绘制样式。这条线（也被称作stroke）沿着图层的`bounds`绘制，同时也包含图层的角。

`borderWidth`是以点为单位的定义边框粗细的浮点数，默认为0.`borderColor`定义了边框的颜色，默认为黑色。

`borderColor`是CGColorRef类型，而不是UIColor，所以它不是Cocoa的内置对象。不过呢，你肯定也清楚图层引用了`borderColor`，虽然属性声明并不能证明这一点。`CGColorRef`在引用/释放时候的行为表现得与`NSObject`极其相似。但是Objective-C语法并不支持这一做法，所以`CGColorRef`属性即便是强引用也只能通过assign关键字来声明。

边框是绘制在图层边界里面的，而且在所有子内容之前，也在子图层之前。如果我们在之前的示例中（清单4.2）加入图层的边框，你就能看到到底是怎么一回事了（如图4.3）.

清单4.2 加上边框

```objective-c
@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];

//set the corner radius on our layers
self.layerView1.layer.cornerRadius = 20.0f;
self.layerView2.layer.cornerRadius = 20.0f;

//add a border to our layers
self.layerView1.layer.borderWidth = 5.0f;
self.layerView2.layer.borderWidth = 5.0f;

//enable clipping on the second layer
self.layerView2.layer.masksToBounds = YES;
}

@end
```

![图4.3](./4.3.png)

图4.3 给图层增加一个边框

注意边框并不会考虑寄宿图或子图层的形状，如果图层的子图层超过了边界，或者是寄宿图在透明区域有一个透明蒙板，边框仍然会沿着图层的边界绘制出来（如图4.4）.

![图4.4](./4.4.png)

图4.4 边框是跟随图层的边界变化的，而不是图层里面的内容

## 阴影

iOS的另一个常见特性呢，就是阴影。阴影往往可以达到图层深度暗示的效果。也能够用来强调正在显示的图层和优先级（比如说一个在其他视图之前的弹出框），不过有时候他们只是单纯的装饰目的。

给`shadowOpacity`属性一个大于默认值（也就是0）的值，阴影就可以显示在任意图层之下。`shadowOpacity`是一个必须在0.0（不可见）和1.0（完全不透明）之间的浮点数。如果设置为1.0，将会显示一个有轻微模糊的黑色阴影稍微在图层之上。若要改动阴影的表现，你可以使用CALayer的另外三个属性：`shadowColor`，`shadowOffset`和`shadowRadius`。

显而易见，`shadowColor`属性控制着阴影的颜色，和`borderColor`和`backgroundColor`一样，它的类型也是`CGColorRef`。阴影默认是黑色，大多数时候你需要的阴影也是黑色的（其他颜色的阴影看起来是不是有一点点奇怪。。）。

`shadowOffset`属性控制着阴影的方向和距离。它是一个`CGSize`的值，宽度控制着阴影横向的位移，高度控制着纵向的位移。`shadowOffset`的默认值是 {0, -3}，意即阴影相对于Y轴有3个点的向上位移。

为什么要默认向上的阴影呢？尽管Core Animation是从Layer Kit演变而来（可以认为是为iOS创建的私有动画框架），但是呢，它却是在Mac OS上面世的，前面有提到，二者的Y轴是颠倒的。这就导致了默认的3个点位移的阴影是向上的。在Mac上，`shadowOffset`的默认值是阴影向下的，这样你就能理解为什么iOS上的阴影方向是向上的了（如图4.5）.

![图4.5](./4.5.png)

图4.5 在iOS（左）和Mac OS（右）上`shadowOffset`的表现。

苹果更倾向于用户界面的阴影应该是垂直向下的，所以在iOS把阴影宽度设为0，然后高度设为一个正值不失为一个做法。

`shadowRadius`属性控制着阴影的*模糊度*，当它的值是0的时候，阴影就和视图一样有一个非常确定的边界线。当值越来越大的时候，边界线看上去就会越来越模糊和自然。苹果自家的应用设计更偏向于自然的阴影，所以一个非零值再合适不过了。

通常来讲，如果你想让视图或控件非常醒目独立于背景之外（比如弹出框遮罩层），你就应该给`shadowRadius`设置一个稍大的值。阴影越模糊，图层的深度看上去就会更明显（如图4.6）.

![图4.6](./4.6.png)

图4.6 大一些的阴影位移和角半径会增加图层的深度即视感

## 阴影裁剪

和图层边框不同，图层的阴影来源于其内容的确切形状，而不是仅仅是边界和`cornerRadius`。为了计算出阴影的形状，Core Animation会将寄宿图（包括子视图，如果有的话）考虑在内，然后通过这些来完美搭配图层形状从而创建一个阴影（见图4.7）。

![图4.7](./4.7.png)

图4.7 阴影是根据寄宿图的轮廓来确定的

当阴影和裁剪扯上关系的时候就有一个头疼的限制：阴影通常就是在Layer的边界之外，如果你开启了`masksToBounds`属性，所有从图层中突出来的内容都会被才剪掉。如果我们在我们之前的边框示例项目中增加图层的阴影属性时，你就会发现问题所在（见图4.8）.

![图4.8](./4.8.png)

图4.8 `maskToBounds`属性裁剪掉了阴影和内容

从技术角度来说，这个结果是可以是可以理解的，但确实又不是我们想要的效果。如果你既想裁切内容又想有阴影效果，你就需要用到两个图层：一个只画阴影的空的外图层，和一个用`masksToBounds`裁剪内容的内图层。

如果我们把之前项目的右边用单独的视图把裁剪的视图包起来，我们就可以解决这个问题（如图4.9）.

![图4.9](./4.9.png)

图4.9 右边，用额外的阴影转换视图包裹被裁剪的视图

我们只把阴影用在最外层的视图上，内层视图进行裁剪。清单4.3是代码实现，图4.10是运行结果。

清单4.3 用一个额外的视图来解决阴影裁切的问题

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView1;
@property (nonatomic, weak) IBOutlet UIView *layerView2;
@property (nonatomic, weak) IBOutlet UIView *shadowView;

@end

@implementation ViewController
￼
- (void)viewDidLoad
{
[super viewDidLoad];

//set the corner radius on our layers
self.layerView1.layer.cornerRadius = 20.0f;
self.layerView2.layer.cornerRadius = 20.0f;

//add a border to our layers
self.layerView1.layer.borderWidth = 5.0f;
self.layerView2.layer.borderWidth = 5.0f;

//add a shadow to layerView1
self.layerView1.layer.shadowOpacity = 0.5f;
self.layerView1.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
self.layerView1.layer.shadowRadius = 5.0f;

//add same shadow to shadowView (not layerView2)
self.shadowView.layer.shadowOpacity = 0.5f;
self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
self.shadowView.layer.shadowRadius = 5.0f;

//enable clipping on the second layer
self.layerView2.layer.masksToBounds = YES;
}

@end
```

![图4.10](./4.10.png)

图4.10 右边视图，不受裁切阴影的阴影视图。

## `shadowPath`属性

我们已经知道图层阴影并不总是方的，而是从图层内容的形状衍生而来。这看上去不错，但是实时计算阴影也是非常消耗资源的，尤其是当图层有多个子图层，每个图层还有一个有透明效果的寄宿图的时候。

如果你事先知道你的阴影形状会是什么样子的，你可以通过指定一个`shadowPath`来提高性能。`shadowPath`是一个`CGPathRef`类型（一个指向`CGPath`的指针）。`CGPath`是一个Core Graphics对象，用来指定任意的一个矢量图形。我们可以通过这个属性独立于图层形状之外指定阴影的形状。

图4.11 展示了同一寄宿图的不同阴影设定。如你所见，我们使用的图形很简单，但是它的阴影可以是你想要的任何形状。清单4.4是代码实现。

![图4.11](./4.11.png)

图4.11 用`shadowPath`指定任意阴影形状

清单4.4 创建简单的阴影形状

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView1;
@property (nonatomic, weak) IBOutlet UIView *layerView2;
@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];

//enable layer shadows
self.layerView1.layer.shadowOpacity = 0.5f;
self.layerView2.layer.shadowOpacity = 0.5f;

//create a square shadow
CGMutablePathRef squarePath = CGPathCreateMutable();
CGPathAddRect(squarePath, NULL, self.layerView1.bounds);
self.layerView1.layer.shadowPath = squarePath; CGPathRelease(squarePath);

￼//create a circular shadow
CGMutablePathRef circlePath = CGPathCreateMutable();
CGPathAddEllipseInRect(circlePath, NULL, self.layerView2.bounds);
self.layerView2.layer.shadowPath = circlePath; CGPathRelease(circlePath);
}
@end
```

如果是一个矩形或者是圆，用`CGPath`会相当简单明了。但是如果是更加复杂一点的图形，`UIBezierPath`类会更合适，它是一个由UIKit提供的在CGPath基础上的Objective-C包装类。

## 图层蒙板

通过`masksToBounds`属性，我们可以沿边界裁剪图形；通过`cornerRadius`属性，我们还可以设定一个圆角。但是有时候你希望展现的内容不是在一个矩形或圆角矩形。比如，你想展示一个有星形框架的图片，又或者想让一些古卷文字慢慢渐变成背景色，而不是一个突兀的边界。

使用一个32位有alpha通道的png图片通常是创建一个无矩形视图最方便的方法，你可以给它指定一个透明蒙板来实现。但是这个方法不能让你以编码的方式动态地生成蒙板，也不能让子图层或子视图裁剪成同样的形状。

CALayer有一个属性叫做`mask`可以解决这个问题。这个属性本身就是个CALayer类型，有和其他图层一样的绘制和布局属性。它类似于一个子图层，相对于父图层（即拥有该属性的图层）布局，但是它却不是一个普通的子图层。不同于那些绘制在父图层中的子图层，`mask`图层定义了父图层的部分可见区域。

`mask`图层的`Color`属性是无关紧要的，真正重要的是图层的轮廓。`mask`属性就像是一个饼干切割机，`mask`图层实心的部分会被保留下来，其他的则会被抛弃。（如图4.12）

如果`mask`图层比父图层要小，只有在`mask`图层里面的内容才是它关心的，除此以外的一切都会被隐藏起来。

![图4.12](./4.12.png)

图4.12 把图片和蒙板图层作用在一起的效果

我们将代码演示一下这个过程，创建一个简单的项目，通过图层的`mask`属性来作用于图片之上。为了简便一些，我们用Interface Builder来创建一个包含UIImageView的图片图层。这样我们就只要代码实现蒙板图层了。清单4.5是最终的代码，图4.13是运行后的结果。

清单4.5 应用蒙板图层

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];

//create mask layer
CALayer *maskLayer = [CALayer layer];
maskLayer.frame = self.imageView.bounds;
UIImage *maskImage = [UIImage imageNamed:@"Cone.png"];
maskLayer.contents = (__bridge id)maskImage.CGImage;

//apply mask to image layer￼
self.imageView.layer.mask = maskLayer;
}
@end
```

![图4.13](./4.13.png)

图4.13 使用了`mask`之后的UIImageView

CALayer蒙板图层真正厉害的地方在于蒙板图不局限于静态图。任何有图层构成的都可以作为`mask`属性，这意味着你的蒙板可以通过代码甚至是动画实时生成。

##拉伸过滤

最后我们再来谈谈`minificationFilter`和`magnificationFilter`属性。总得来讲，当我们视图显示一个图片的时候，都应该正确地显示这个图片（意即：以正确的比例和正确的1：1像素显示在屏幕上）。原因如下：

* 能够显示最好的画质，像素既没有被压缩也没有被拉伸。
* 能更好的使用内存，因为这就是所有你要存储的东西。
* 最好的性能表现，CPU不需要为此额外的计算。

不过有时候，显示一个非真实大小的图片确实是我们需要的效果。比如说一个头像或是图片的缩略图，再比如说一个可以被拖拽和伸缩的大图。这些情况下，为同一图片的不同大小存储不同的图片显得又不切实际。

当图片需要显示不同的大小的时候，有一种叫做*拉伸过滤*的算法就起到作用了。它作用于原图的像素上并根据需要生成新的像素显示在屏幕上。

事实上，重绘图片大小也没有一个统一的通用算法。这取决于需要拉伸的内容，放大或是缩小的需求等这些因素。`CALayer`为此提供了三种拉伸过滤方法，他们是：

* kCAFilterLinear
* kCAFilterNearest
* kCAFilterTrilinear

minification（缩小图片）和magnification（放大图片）默认的过滤器都是`kCAFilterLinear`，这个过滤器采用双线性滤波算法，它在大多数情况下都表现良好。双线性滤波算法通过对多个像素取样最终生成新的值，得到一个平滑的表现不错的拉伸。但是当放大倍数比较大的时候图片就模糊不清了。

`kCAFilterTrilinear`和`kCAFilterLinear`非常相似，大部分情况下二者都看不出来有什么差别。但是，较双线性滤波算法而言，三线性滤波算法存储了多个大小情况下的图片（也叫多重贴图），并三维取样，同时结合大图和小图的存储进而得到最后的结果。

这个方法的好处在于算法能够从一系列已经接近于最终大小的图片中得到想要的结果，也就是说不要对很多像素同步取样。这不仅提高了性能，也避免了小概率因舍入错误引起的取样失灵的问题

![图4.14](./4.14.png)

图4.14 对于大图来说，双线性滤波和三线性滤波表现得更出色

`kCAFilterNearest`是一种比较武断的方法。从名字不难看出，这个算法（也叫最近过滤）就是取样最近的单像素点而不管其他的颜色。这样做非常快，也不会使图片模糊。但是，最明显的效果就是，会使得压缩图片更糟，图片放大之后也显得块状或是马赛克严重。

![图4.15](./4.15.png)

图4.15 对于没有斜线的小图来说，最近过滤算法要好很多

总的来说，对于比较小的图或者是差异特别明显，极少斜线的大图，最近过滤算法会保留这种差异明显的特质以呈现更好的结果。但是对于大多数的图尤其是有很多斜线或是曲线轮廓的图片来说，最近过滤算法会导致更差的结果。换句话说，线性过滤保留了形状，最近过滤则保留了像素的差异。

让我们来实验一下。我们对第三章的时钟项目改动一下，用LCD风格的数字方式显示。我们用简单的像素字体（一种用像素构成字符的字体，而非矢量图形）创造数字显示方式，用图片存储起来，而且用第二章介绍过的拼合技术来显示（如图4.16）。

![图4.16](./4.16.png)

图4.16 一个简单的运用拼合技术显示的LCD数字风格的像素字体

我们在Interface Builder中放置了六个视图，小时、分钟、秒钟各两个，图4.17显示了这六个视图是如何在Interface Builder中放置的。如果每个都用一个淡出的outlets对象就会显得太多了，所以我们就用了一个`IBOutletCollection`对象把他们和控制器联系起来，这样我们就可以以数组的方式访问视图了。清单4.6是代码实现。


![图4.17](./4.17.png)

图4.17 在Interface Builder中放置的六个视图

清单4.6 显示一个LCD风格的时钟

```objective-c
@interface ViewController ()

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *digitViews;
@property (nonatomic, weak) NSTimer *timer;
￼￼
@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad]; //get spritesheet image
UIImage *digits = [UIImage imageNamed:@"Digits.png"];

//set up digit views
for (UIView *view in self.digitViews) {
//set contents
view.layer.contents = (__bridge id)digits.CGImage;
view.layer.contentsRect = CGRectMake(0, 0, 0.1, 1.0);
view.layer.contentsGravity = kCAGravityResizeAspect;
}

//start timer
self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];

//set initial clock time
[self tick];
}

- (void)setDigit:(NSInteger)digit forView:(UIView *)view
{
//adjust contentsRect to select correct digit
view.layer.contentsRect = CGRectMake(digit * 0.1, 0, 0.1, 1.0);
}

- (void)tick
{
//convert time to hours, minutes and seconds
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
￼
NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];

//set hours
[self setDigit:components.hour / 10 forView:self.digitViews[0]];
[self setDigit:components.hour % 10 forView:self.digitViews[1]];

//set minutes
[self setDigit:components.minute / 10 forView:self.digitViews[2]];
[self setDigit:components.minute % 10 forView:self.digitViews[3]];

//set seconds
[self setDigit:components.second / 10 forView:self.digitViews[4]];
[self setDigit:components.second % 10 forView:self.digitViews[5]];
}
@end
```

如图4.18，这样做的确起了效果，但是图片看起来模糊了。看起来默认的`kCAFilterLinear`选项让我们失望了。

![图4.18](./4.18.png)

图4.18 一个模糊的时钟，由默认的`kCAFilterLinear`引起

为了能像图4.19中那样，我们需要在for循环中加入如下代码：

```objective-c
view.layer.magnificationFilter = kCAFilterNearest;
```

![图4.19](./4.19.png)

图4.19 设置了最近过滤之后的清晰显示

## 组透明

UIView有一个叫做`alpha`的属性来确定视图的透明度。CALayer有一个等同的属性叫做`opacity`，这两个属性都是影响子层级的。也就是说，如果你给一个图层设置了`opacity`属性，那它的子图层都会受此影响。

iOS常见的做法是把一个空间的alpha值设置为0.5（50%）以使其看上去呈现为不可用状态。对于独立的视图来说还不错，但是当一个控件有子视图的时候就有点奇怪了，图4.20展示了一个内嵌了UILabel的自定义UIButton；左边是一个不透明的按钮，右边是50%透明度的相同按钮。我们可以注意到，里面的标签的轮廓跟按钮的背景很不搭调。

![图4.20](./4.20.png)

图4.20 右边的渐隐按钮中，里面的标签清晰可见

这是由透明度的混合叠加造成的，当你显示一个50%透明度的图层时，图层的每个像素都会一半显示自己的颜色，另一半显示图层下面的颜色。这是正常的透明度的表现。但是如果图层包含一个同样显示50%透明的子图层时，你所看到的视图，50%来自子视图，25%来了图层本身的颜色，另外的25%则来自背景色。

在我们的示例中，按钮和表情都是白色背景。虽然他们都是50%的可见度，但是合起来的可见度是75%，所以标签所在的区域看上去就没有周围的部分那么透明。所以看上去子视图就高亮了，使得这个显示效果都糟透了。

理想状况下，当你设置了一个图层的透明度，你希望它包含的整个图层树像一个整体一样的透明效果。你可以通过设置Info.plist文件中的`UIViewGroupOpacity`为YES来达到这个效果，但是这个设置会影响到这个应用，整个app可能会受到不良影响。如果`UIViewGroupOpacity`并未设置，iOS 6和以前的版本会默认为NO（也许以后的版本会有一些改变）。

另一个方法就是，你可以设置CALayer的一个叫做`shouldRasterize`属性（见清单4.7）来实现组透明的效果，如果它被设置为YES，在应用透明度之前，图层及其子图层都会被整合成一个整体的图片，这样就没有透明度混合的问题了（如图4.21）。

为了启用`shouldRasterize`属性，我们设置了图层的`rasterizationScale`属性。默认情况下，所有图层拉伸都是1.0， 所以如果你使用了`shouldRasterize`属性，你就要确保你设置了`rasterizationScale`属性去匹配屏幕，以防止出现Retina屏幕像素化的问题。

当`shouldRasterize`和`UIViewGroupOpacity`一起的时候，性能问题就出现了（我们在第12章『速度』和第15章『图层性能』将做出介绍），但是性能碰撞都本地化了（译者注：这句话需要再翻译）。

清单4.7 使用`shouldRasterize`属性解决组透明问题

```objective-c
@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *containerView;
@end

@implementation ViewController

- (UIButton *)customButton
{
//create button
CGRect frame = CGRectMake(0, 0, 150, 50);
UIButton *button = [[UIButton alloc] initWithFrame:frame];
button.backgroundColor = [UIColor whiteColor];
button.layer.cornerRadius = 10;

//add label
frame = CGRectMake(20, 10, 110, 30);
UILabel *label = [[UILabel alloc] initWithFrame:frame];
label.text = @"Hello World";
label.textAlignment = NSTextAlignmentCenter;
[button addSubview:label];
return button;
}

- (void)viewDidLoad
{
[super viewDidLoad];

//create opaque button
UIButton *button1 = [self customButton];
button1.center = CGPointMake(50, 150);
[self.containerView addSubview:button1];

//create translucent button
UIButton *button2 = [self customButton];
￼
button2.center = CGPointMake(250, 150);
button2.alpha = 0.5;
[self.containerView addSubview:button2];

//enable rasterization for the translucent button
button2.layer.shouldRasterize = YES;
button2.layer.rasterizationScale = [UIScreen mainScreen].scale;
}
@end
```

![图4.12](./4.21.png)

图4.21 修正后的图

## 总结

这一章介绍了一些可以通过代码应用到图层上的视觉效果，比如圆角，阴影和蒙板。我们也了解了拉伸过滤器和组透明。

在第五章，『变换』中，我们将会研究图层变化和3D转换。



# 变换

>*很不幸，没人能告诉你矩阵是什么，你只能自己体会* -- 黑客帝国

在第四章“可视效果”中，我们研究了一些增强图层和它的内容显示效果的一些技术，在这一章中，我们将要研究可以用来对图层旋转，摆放或者扭曲的`CGAffineTransform`，以及可以将扁平物体转换成三维空间对象的`CATransform3D`（而不是仅仅对圆角矩形添加下沉阴影）。

## 仿射变换

在第三章“图层几何学”中，我们使用了`UIView`的`transform`属性旋转了钟的指针，但并没有解释背后运作的原理，实际上`UIView`的`transform`属性是一个`CGAffineTransform`类型，用于在二维空间做旋转，缩放和平移。`CGAffineTransform`是一个可以和二维空间向量（例如`CGPoint`）做乘法的3X2的矩阵（见图5.1）。

<img src="./5.1.jpeg" alt="图5.1" title="图5.1" width="700"/>

图5.1 用矩阵表示的`CGAffineTransform`和`CGPoint`

用`CGPoint`的每一列和`CGAffineTransform`矩阵的每一行对应元素相乘再求和，就形成了一个新的`CGPoint`类型的结果。要解释一下图中显示的灰色元素，为了能让矩阵做乘法，左边矩阵的列数一定要和右边矩阵的行数个数相同，所以要给矩阵填充一些标志值，使得既可以让矩阵做乘法，又不改变运算结果，并且没必要存储这些添加的值，因为它们的值不会发生变化，但是要用来做运算。

因此，通常会用3×3（而不是2×3）的矩阵来做二维变换，你可能会见到3行2列格式的矩阵，这是所谓的以列为主的格式，图5.1所示的是以行为主的格式，只要能保持一致，用哪种格式都无所谓。

当对图层应用变换矩阵，图层矩形内的每一个点都被相应地做变换，从而形成一个新的四边形的形状。`CGAffineTransform`中的“仿射”的意思是无论变换矩阵用什么值，图层中平行的两条线在变换之后任然保持平行，`CGAffineTransform`可以做出任意符合上述标注的变换，图5.2显示了一些仿射的和非仿射的变换：

<img src="./5.2.jpeg" alt="图5.2" title="图5.2" width="700"/>

图5.2 仿射和非仿射变换

### 创建一个`CGAffineTransform`

对矩阵数学做一个全面的阐述就超出本书的讨论范围了，不过如果你对矩阵完全不熟悉的话，矩阵变换可能会使你感到畏惧。幸运的是，Core Graphics提供了一系列函数，对完全没有数学基础的开发者也能够简单地做一些变换。如下几个函数都创建了一个`CGAffineTransform`实例：

CGAffineTransformMakeRotation(CGFloat angle) 
CGAffineTransformMakeScale(CGFloat sx, CGFloat sy)
CGAffineTransformMakeTranslation(CGFloat tx, CGFloat ty)

旋转和缩放变换都可以很好解释--分别旋转或者缩放一个向量的值。平移变换是指每个点都移动了向量指定的x或者y值--所以如果向量代表了一个点，那它就平移了这个点的距离。

我们用一个很简单的项目来做个demo，把一个原始视图旋转45度角度（图5.3）

<img src="./5.3.jpeg" alt="图5.3" title="图5.3" width="700"/>

图5.3 使用仿射变换旋转45度角之后的视图

`UIView`可以通过设置`transform`属性做变换，但实际上它只是封装了内部图层的变换。

`CALayer`同样也有一个`transform`属性，但它的类型是`CATransform3D`，而不是`CGAffineTransform`，本章后续将会详细解释。`CALayer`对应于`UIView`的`transform`属性叫做`affineTransform`，清单5.1的例子就是使用`affineTransform`对图层做了45度顺时针旋转。

清单5.1 使用`affineTransform`对图层旋转45度
```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *layerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//rotate the layer 45 degrees
CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
self.layerView.layer.affineTransform = transform;
}

@end
```

注意我们使用的旋转常量是`M_PI_4`，而不是你想象的45，因为iOS的变换函数使用弧度而不是角度作为单位。弧度用数学常量pi的倍数表示，一个pi代表180度，所以四分之一的pi就是45度。

C的数学函数库（iOS会自动引入）提供了pi的一些简便的换算，`M_PI_4`于是就是pi的四分之一，如果对换算不太清楚的话，可以用如下的宏做换算：

#define RADIANS_TO_DEGREES(x) ((x)/M_PI*180.0) 
#define DEGREES_TO_RADIANS(x) ((x)/180.0*M_PI)


### 混合变换

Core Graphics提供了一系列的函数可以在一个变换的基础上做更深层次的变换，如果做一个既要*缩放*又要*旋转*的变换，这就会非常有用了。例如下面几个函数：

CGAffineTransformRotate(CGAffineTransform t, CGFloat angle)     
CGAffineTransformScale(CGAffineTransform t, CGFloat sx, CGFloat sy)      
CGAffineTransformTranslate(CGAffineTransform t, CGFloat tx, CGFloat ty)

当操纵一个变换的时候，初始生成一个什么都不做的变换很重要--也就是创建一个`CGAffineTransform`类型的空值，矩阵论中称作*单位矩阵*，Core Graphics同样也提供了一个方便的常量：

CGAffineTransformIdentity

最后，如果需要混合两个已经存在的变换矩阵，就可以使用如下方法，在两个变换的基础上创建一个新的变换：

CGAffineTransformConcat(CGAffineTransform t1, CGAffineTransform t2);

我们来用这些函数组合一个更加复杂的变换，先缩小50%，再旋转30度，最后向右移动200个像素（清单5.2）。图5.4显示了图层变换最后的结果。

清单5.2 使用若干方法创建一个复合变换

```objective-c
- (void)viewDidLoad
{
[super viewDidLoad]; 
CGAffineTransform transform = CGAffineTransformIdentity; //create a new transform 
transform = CGAffineTransformScale(transform, 0.5, 0.5); //scale by 50%
transform = CGAffineTransformRotate(transform, M_PI / 180.0 * 30.0); //rotate by 30 degrees
transform = CGAffineTransformTranslate(transform, 200, 0); //translate by 200 points
//apply transform to layer
self.layerView.layer.affineTransform = transform;
}
```

<img src="./5.4.jpeg" alt="图5.4" title="图5.4" width="700"/>

图5.4 顺序应用多个仿射变换之后的结果

图5.4中有些需要注意的地方：图片向右边发生了平移，但并没有指定距离那么远（200像素），另外它还有点向下发生了平移。原因在于当你按顺序做了变换，上一个变换的结果将会影响之后的变换，所以200像素的向右平移同样也被旋转了30度，缩小了50%，所以它实际上是斜向移动了100像素。

这意味着变换的顺序会影响最终的结果，也就是说旋转之后的平移和平移之后的旋转结果可能不同。

### 剪切变换

Core Graphics为你提供了计算变换矩阵的一些方法，所以很少需要直接设置`CGAffineTransform`的值。除非需要创建一个*斜切*的变换，Core Graphics并没有提供直接的函数。

斜切变换是放射变换的第四种类型，较于平移，旋转和缩放并不常用（这也是Core Graphics没有提供相应函数的原因），但有些时候也会很有用。我们用一张图片可以很直接的说明效果（图5.5）。也许用“倾斜”描述更加恰当，具体做变换的代码见清单5.3。

<img src="./5.5.jpeg" alt="图5.5" title="图5.5" width="700"/>

图5.5 水平方向的斜切变换

清单5.3 实现一个斜切变换

```objective-c
@implementation ViewController

CGAffineTransform CGAffineTransformMakeShear(CGFloat x, CGFloat y)
{
CGAffineTransform transform = CGAffineTransformIdentity;
transform.c = -x;
transform.b = y;
return transform;
}

- (void)viewDidLoad
{
[super viewDidLoad];
//shear the layer at a 45-degree angle
self.layerView.layer.affineTransform = CGAffineTransformMakeShear(1, 0);
}

@end
```

## 3D变换

CG的前缀告诉我们，`CGAffineTransform`类型属于Core Graphics框架，Core Graphics实际上是一个严格意义上的2D绘图API，并且`CGAffineTransform`仅仅对2D变换有效。

在第三章中，我们提到了`zPosition`属性，可以用来让图层靠近或者远离相机（用户视角），`transform`属性（`CATransform3D`类型）可以真正做到这点，即让图层在3D空间内移动或者旋转。

和`CGAffineTransform`类似，`CATransform3D`也是一个矩阵，但是和2x3的矩阵不同，`CATransform3D`是一个可以在3维空间内做变换的4x4的矩阵（图5.6）。

<img src="./5.6.jpeg" alt="图5.6" title="图5.6" width="700"/>

图5.6 对一个3D像素点做`CATransform3D`矩阵变换

和`CGAffineTransform`矩阵类似，Core Animation提供了一系列的方法用来创建和组合`CATransform3D`类型的矩阵，和Core Graphics的函数类似，但是3D的平移和缩放多出了一个`z`参数，并且旋转函数除了`angle`之外多出了`x`,`y`,`z`三个参数，分别决定了每个坐标轴方向上的旋转：

CATransform3DMakeRotation(CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
CATransform3DMakeScale(CGFloat sx, CGFloat sy, CGFloat sz) 
CATransform3DMakeTranslation(Gloat tx, CGFloat ty, CGFloat tz)

你应该对X轴和Y轴比较熟悉了，分别以右和下为正方向（回忆第三章，这是iOS上的标准结构，在Mac OS，Y轴朝上为正方向），Z轴和这两个轴分别垂直，指向视角外为正方向（图5.7）。

<img src="./5.7.jpeg" alt="图5.7" title="图5.7" width="700"/>

图5.7 X，Y，Z轴，以及围绕它们旋转的方向

由图所见，绕Z轴的旋转等同于之前二维空间的仿射旋转，但是绕X轴和Y轴的旋转就突破了屏幕的二维空间，并且在用户视角看来发生了倾斜。

举个例子：清单5.4的代码使用了`CATransform3DMakeRotation`对视图内的图层绕Y轴做了45度角的旋转，我们可以把视图向右倾斜，这样会看得更清晰。

结果见图5.8，但并不像我们期待的那样。

清单5.4 绕Y轴旋转图层

```objective-c
@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//rotate the layer 45 degrees along the Y axis
CATransform3D transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
self.layerView.layer.transform = transform;
}

@end
```

<img src="./5.8.jpeg" alt="图5.8" title="图5.8" width="700"/>

图5.8 绕y轴旋转45度的视图

看起来图层并没有被旋转，而是仅仅在水平方向上的一个压缩，是哪里出了问题呢？

其实完全没错，视图看起来更窄实际上是因为我们在用一个斜向的视角看它，而不是*透视*。

### 透视投影

在真实世界中，当物体远离我们的时候，由于视角的原因看起来会变小，理论上说远离我们的视图的边要比靠近视角的边更短，但实际上并没有发生，而我们当前的视角是等距离的，也就是在3D变换中仍然保持平行，和之前提到的仿射变换类似。

在等距投影中，远处的物体和近处的物体保持同样的缩放比例，这种投影也有它自己的用处（例如建筑绘图，颠倒，和伪3D视频），但当前我们并不需要。

为了解决这个问题，我们需要引入*投影变换*（又称作*z变换*）来对除了旋转之外的变换矩阵做一些修改，Core Animation并没有给我们提供设置透视变换的函数，因此我们需要手动修改矩阵值，幸运的是，这很简单：

`CATransform3D`的透视效果通过一个矩阵中一个很简单的元素来控制：`m34`。`m34`（图5.9）用于按比例缩放X和Y的值来计算到底要离视角多远。

<img src="./5.9.jpeg" alt="图5.9" title="图5.9" width="700"/>

图5.9 `CATransform3D`的`m34`元素，用来做透视

`m34`的默认值是0，我们可以通过设置`m34`为-1.0 / `d`来应用透视效果，`d`代表了想象中视角相机和屏幕之间的距离，以像素为单位，那应该如何计算这个距离呢？实际上并不需要，大概估算一个就好了。

因为视角相机实际上并不存在，所以可以根据屏幕上的显示效果自由决定它的放置的位置。通常500-1000就已经很好了，但对于特定的图层有时候更小或者更大的值会看起来更舒服，减少距离的值会增强透视效果，所以一个非常微小的值会让它看起来更加失真，然而一个非常大的值会让它基本失去透视效果，对视图应用透视的代码见清单5.5，结果见图5.10。

清单5.5 对变换应用透视效果

```objective-c
@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//create a new transform
CATransform3D transform = CATransform3DIdentity;
//apply perspective
transform.m34 = - 1.0 / 500.0;
//rotate by 45 degrees along the Y axis
transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
//apply to layer
self.layerView.layer.transform = transform;
}

@end
```

<img src="./5.10.jpeg" alt="图5.10" title="图5.10" width="700"/>

图5.10 应用透视效果之后再次对图层做旋转

### 灭点

当在透视角度绘图的时候，远离相机视角的物体将会变小变远，当远离到一个极限距离，它们可能就缩成了一个点，于是所有的物体最后都汇聚消失在同一个点。

在现实中，这个点通常是视图的中心（图5.11），于是为了在应用中创建拟真效果的透视，这个点应该聚在屏幕中点，或者至少是包含所有3D对象的视图中点。

<img src="./5.11.jpeg" alt="图5.11" title="图5.11" width="700"/>

图5.11 灭点

Core Animation定义了这个点位于变换图层的`anchorPoint`（通常位于图层中心，但也有例外，见第三章）。这就是说，当图层发生变换时，这个点永远位于图层变换之前`anchorPoint`的位置。

当改变一个图层的`position`，你也改变了它的灭点，做3D变换的时候要时刻记住这一点，当你试图通过调整`m34`来让它更加有3D效果时，应该首先把它放置于屏幕中央，然后通过平移来把它移动到指定位置（而不是直接改变它的`position`），这样所有的3D图层都共享一个灭点。

### `sublayerTransform`属性

如果有多个视图或者图层，每个都做3D变换，那就需要分别设置相同的m34值，并且确保在变换之前都在屏幕中央共享同一个`position`，如果用一个函数封装这些操作的确会更加方便，但仍然有限制（例如，你不能在Interface Builder中摆放视图），这里有一个更好的方法。

`CALayer`有一个属性叫做`sublayerTransform`。它也是`CATransform3D`类型，但和对一个图层的变换不同，它影响到所有的子图层。这意味着你可以一次性对包含这些图层的容器做变换，于是所有的子图层都自动继承了这个变换方法。

相较而言，通过在一个地方设置透视变换会很方便，同时它会带来另一个显著的优势：灭点被设置在*容器图层*的中点，从而不需要再对子图层分别设置了。这意味着你可以随意使用`position`和`frame`来放置子图层，而不需要把它们放置在屏幕中点，然后为了保证统一的灭点用变换来做平移。

我们来用一个demo举例说明。这里用Interface Builder并排放置两个视图（图5.12），然后通过设置它们容器视图的透视变换，我们可以保证它们有相同的透视和灭点，代码见清单5.6，结果见图5.13。

<img src="./5.12.jpeg" alt="图5.12" title="图5.12" width="700"/>

图5.12 在一个视图容器内并排放置两个视图

清单5.6 应用`sublayerTransform`

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *layerView1;
@property (nonatomic, weak) IBOutlet UIView *layerView2;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//apply perspective transform to container
CATransform3D perspective = CATransform3DIdentity;
perspective.m34 = - 1.0 / 500.0;
self.containerView.layer.sublayerTransform = perspective;
//rotate layerView1 by 45 degrees along the Y axis
CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
self.layerView1.layer.transform = transform1;
//rotate layerView2 by 45 degrees along the Y axis
CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
self.layerView2.layer.transform = transform2;
}
```

<img src="./5.13.jpeg" alt="图5.13" title="图5.13" width="700"/>

图5.13 通过相同的透视效果分别对视图做变换

### 背面

我们既然可以在3D场景下旋转图层，那么也可以从*背面*去观察它。如果我们在清单5.4中把角度修改为`M_PI`（180度）而不是当前的` M_PI_4`（45度），那么将会把图层完全旋转一个半圈，于是完全背对了相机视角。

那么从背部看图层是什么样的呢，见图5.14

<img src="./5.14.jpeg" alt="图5.14" title="图5.14" width="700"/>

图5.14 视图的背面，一个镜像对称的图片

如你所见，图层是双面绘制的，反面显示的是正面的一个镜像图片。

但这并不是一个很好的特性，因为如果图层包含文本或者其他控件，那用户看到这些内容的镜像图片当然会感到困惑。另外也有可能造成资源的浪费：想象用这些图层形成一个不透明的固态立方体，既然永远都看不见这些图层的背面，那为什么浪费GPU来绘制它们呢？

`CALayer`有一个叫做`doubleSided`的属性来控制图层的背面是否要被绘制。这是一个`BOOL`类型，默认为`YES`，如果设置为`NO`，那么当图层正面从相机视角消失的时候，它将不会被绘制。

### 扁平化图层

如果对包含已经做过变换的图层的图层做反方向的变换将会发什么什么呢？是不是有点困惑？见图5.15

<img src="./5.15.jpeg" alt="图5.15" title="图5.15" width="700"/>

图5.15 反方向变换的嵌套图层

注意做了-45度旋转的内部图层是怎样抵消旋转45度的图层，从而恢复正常状态的。

如果内部图层相对外部图层做了相反的变换（这里是绕Z轴的旋转），那么按照逻辑这两个变换将被相互抵消。

验证一下，相应代码见清单5.7，结果见5.16

清单5.7 绕Z轴做相反的旋转变换

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *outerView;
@property (nonatomic, weak) IBOutlet UIView *innerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//rotate the outer layer 45 degrees
CATransform3D outer = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
self.outerView.layer.transform = outer;
//rotate the inner layer -45 degrees
CATransform3D inner = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
self.innerView.layer.transform = inner;
}

@end
```

<img src="./5.16.jpeg" alt="图5.16" title="图5.16" width="700"/>

图5.16 旋转后的视图

运行结果和我们预期的一致。现在在3D情况下再试一次。修改代码，让内外两个视图绕Y轴旋转而不是Z轴，再加上透视效果，以便我们观察。注意不能用`sublayerTransform`属性，因为内部的图层并不直接是容器图层的子图层，所以这里分别对图层设置透视变换（清单5.8）。

清单5.8 绕Y轴相反的旋转变换

```objective-c
- (void)viewDidLoad
{
[super viewDidLoad];
//rotate the outer layer 45 degrees
CATransform3D outer = CATransform3DIdentity;
outer.m34 = -1.0 / 500.0;
outer = CATransform3DRotate(outer, M_PI_4, 0, 1, 0);
self.outerView.layer.transform = outer;
//rotate the inner layer -45 degrees
CATransform3D inner = CATransform3DIdentity;
inner.m34 = -1.0 / 500.0;
inner = CATransform3DRotate(inner, -M_PI_4, 0, 1, 0);
self.innerView.layer.transform = inner;
}
```

预期的效果应该如图5.17所示。

<img src="./5.17.jpeg" alt="图5.17" title="图5.17" width="700"/>

图5.17 绕Y轴做相反旋转的预期结果。

但其实这并不是我们所看到的，相反，我们看到的结果如图5.18所示。发什么了什么呢？内部的图层仍然向左侧旋转，并且发生了扭曲，但按道理说它应该保持正面朝上，并且显示正常的方块。

这是由于尽管Core Animation图层存在于3D空间之内，但它们并不都存在*同一个*3D空间。每个图层的3D场景其实是扁平化的，当你从正面观察一个图层，看到的实际上由子图层创建的想象出来的3D场景，但当你倾斜这个图层，你会发现实际上这个3D场景仅仅是被绘制在图层的表面。

<img src="./5.18.jpeg" alt="图5.18" title="图5.18" width="700"/>

图5.18 绕Y轴做相反旋转的真实结果

类似的，当你在玩一个3D游戏，实际上仅仅是把屏幕做了一次倾斜，或许在游戏中可以看见有一面墙在你面前，但是倾斜屏幕并不能够看见墙里面的东西。所有场景里面绘制的东西并不会随着你观察它的角度改变而发生变化；图层也是同样的道理。

这使得用Core Animation创建非常复杂的3D场景变得十分困难。你不能够使用图层树去创建一个3D结构的层级关系--在相同场景下的任何3D表面必须和同样的图层保持一致，这是因为每个的父视图都把它的子视图扁平化了。

至少当你用正常的`CALayer`的时候是这样，`CALayer`有一个叫做`CATransformLayer`的子类来解决这个问题。具体在第六章“特殊的图层”中将会具体讨论。

## 固体对象

现在你懂得了在3D空间的一些图层布局的基础，我们来试着创建一个固态的3D对象（从技术上讲，它是一个空心的对象，但从表面上看它是一个实心体）。我们用六个独立的视图来构建一个立方体的各个面。

在这个例子中，我们用Interface Builder来构建立方体的面（图5.19），我们当然可以用代码来写，但是用Interface Builder的好处是可以方便的在每一个面上添加子视图。记住这些面仅仅是包含视图和控件的普通的用户界面元素，它们完全是我们界面交互的部分，并且当把它折成一个立方体之后也不会改变这个性质。

<img src="./5.19.jpeg" alt="图5.19" title="图5.19" width="700"/>

图5.19 用Interface Builder对立方体的六个面进行布局

这些面视图并没有放置在主视图当中，而是松散地排列在根nib文件里面。我们并不关心在这个容器中如何摆放它们的位置，因为后续将会用图层的`transform`对它们进行重新布局，并且用Interface Builder在容器视图之外摆放他们可以让我们容易看清楚它们的内容，如果把它们一个叠着一个都塞进主视图，将会变得很难看。

我们把一个有颜色的`UILabel`放置在视图内部，是为了清楚的辨别它们之间的关系，并且`UIButton`被放置在第三个面视图里面，后面会做简单的解释。

具体把视图组织成立方体的代码见清单5.9，结果见图5.20

清单5.9 创建一个立方体

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *faces;

@end

@implementation ViewController

- (void)addFace:(NSInteger)index withTransform:(CATransform3D)transform
{
//get the face view and add it to the container
UIView *face = self.faces[index];
[self.containerView addSubview:face];
//center the face view within the container
CGSize containerSize = self.containerView.bounds.size;
face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
// apply the transform
face.layer.transform = transform;
}

- (void)viewDidLoad
{
[super viewDidLoad];
//set up the container sublayer transform
CATransform3D perspective = CATransform3DIdentity;
perspective.m34 = -1.0 / 500.0;
self.containerView.layer.sublayerTransform = perspective;
//add cube face 1
CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
[self addFace:0 withTransform:transform];
//add cube face 2
transform = CATransform3DMakeTranslation(100, 0, 0);
transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
[self addFace:1 withTransform:transform];
//add cube face 3
transform = CATransform3DMakeTranslation(0, -100, 0);
transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
[self addFace:2 withTransform:transform];
//add cube face 4
transform = CATransform3DMakeTranslation(0, 100, 0);
transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
[self addFace:3 withTransform:transform];
//add cube face 5
transform = CATransform3DMakeTranslation(-100, 0, 0);
transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
[self addFace:4 withTransform:transform];
//add cube face 6
transform = CATransform3DMakeTranslation(0, 0, -100);
transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
[self addFace:5 withTransform:transform];
}

@end
```

<img src="./5.20.jpeg" alt="图5.20" title="图5.20" width="700"/>

图5.20 正面朝上的立方体

从这个角度看立方体并不是很明显；看起来只是一个方块，为了更好地欣赏它，我们将更换一个*不同的视角*。

旋转这个立方体将会显得很笨重，因为我们要单独对每个面做旋转。另一个简单的方案是通过调整容器视图的`sublayerTransform`去旋转*照相机*。

添加如下几行去旋转`containerView`图层的`perspective`变换矩阵：

perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0); 
perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);

这就对相机（或者相对相机的整个场景，你也可以这么认为）绕Y轴旋转45度，并且绕X轴旋转45度。现在从另一个角度去观察立方体，就能看出它的真实面貌（图5.21）。

<img src="./5.21.jpeg" alt="图5.21" title="图5.21" width="700"/>

图5.21 从一个边角观察的立方体

###光亮和阴影

现在它看起来更像是一个立方体没错了，但是对每个面之间的连接还是很难分辨。Core Animation可以用3D显示图层，但是它对*光线*并没有概念。如果想让立方体看起来更加真实，需要自己做一个阴影效果。你可以通过改变每个面的背景颜色或者直接用带光亮效果的图片来调整。

如果需要*动态*地创建光线效果，你可以根据每个视图的方向应用不同的alpha值做出半透明的阴影图层，但为了计算阴影图层的不透明度，你需要得到每个面的*法向量*（垂直于表面的向量），然后计算该向量与一个来自虚构光源的向量的*叉乘*结果。叉乘代表了光源和图层之间的角度，从而决定了它有多大程度上的光亮。

清单5.10实现了这样一个结果，我们用GLKit框架来做向量的计算（你需要引入GLKit库来运行代码），每个面的`CATransform3D`都被转换成`GLKMatrix4`，然后通过`GLKMatrix4GetMatrix3`函数得出一个3×3的*旋转矩阵*。这个旋转矩阵指定了图层的方向，然后可以用它来得到法向量的值。

结果如图5.22所示，试着调整`LIGHT_DIRECTION`和`AMBIENT_LIGHT`的值来切换光线效果

清单5.10 对立方体的表面应用动态的光线效果

```objective-c
#import "ViewController.h" 
#import <QuartzCore/QuartzCore.h> 
#import <GLKit/GLKit.h>

#define LIGHT_DIRECTION 0, 1, -0.5 
#define AMBIENT_LIGHT 0.5

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *faces;

@end

@implementation ViewController

- (void)applyLightingToFace:(CALayer *)face
{
//add lighting layer
CALayer *layer = [CALayer layer];
layer.frame = face.bounds;
[face addSublayer:layer];
//convert the face transform to matrix
//(GLKMatrix4 has the same structure as CATransform3D)
//译者注：GLKMatrix4和CATransform3D内存结构一致，但坐标类型有长度区别，所以理论上应该做一次float到CGFloat的转换，感谢[@zihuyishi](https://github.com/zihuyishi)同学~
CATransform3D transform = face.transform;
GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
//get face normal
GLKVector3 normal = GLKVector3Make(0, 0, 1);
normal = GLKMatrix3MultiplyVector3(matrix3, normal);
normal = GLKVector3Normalize(normal);
//get dot product with light direction
GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
float dotProduct = GLKVector3DotProduct(light, normal);
//set lighting layer opacity
CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
layer.backgroundColor = color.CGColor;
}

- (void)addFace:(NSInteger)index withTransform:(CATransform3D)transform
{
//get the face view and add it to the container
UIView *face = self.faces[index];
[self.containerView addSubview:face];
//center the face view within the container
CGSize containerSize = self.containerView.bounds.size;
face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
// apply the transform
face.layer.transform = transform;
//apply lighting
[self applyLightingToFace:face.layer];
}

- (void)viewDidLoad
{
[super viewDidLoad];
//set up the container sublayer transform
CATransform3D perspective = CATransform3DIdentity;
perspective.m34 = -1.0 / 500.0;
perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
self.containerView.layer.sublayerTransform = perspective;
//add cube face 1
CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
[self addFace:0 withTransform:transform];
//add cube face 2
transform = CATransform3DMakeTranslation(100, 0, 0);
transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
[self addFace:1 withTransform:transform];
//add cube face 3
transform = CATransform3DMakeTranslation(0, -100, 0);
transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
[self addFace:2 withTransform:transform];
//add cube face 4
transform = CATransform3DMakeTranslation(0, 100, 0);
transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
[self addFace:3 withTransform:transform];
//add cube face 5
transform = CATransform3DMakeTranslation(-100, 0, 0);
transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
[self addFace:4 withTransform:transform];
//add cube face 6
transform = CATransform3DMakeTranslation(0, 0, -100);
transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
[self addFace:5 withTransform:transform];
}

@end
```

<img src="./5.22.jpeg" alt="图5.22" title="图5.22" width="700"/>

图5.22 动态计算光线效果之后的立方体

### 点击事件

你应该能注意到现在可以在第三个表面的顶部看见按钮了，点击它，什么都没发生，为什么呢？

这并不是因为iOS在3D场景下不能够正确地处理响应事件，实际上是可以做到的。问题在于*视图顺序*。在第三章中我们简要提到过，点击事件的处理由视图在父视图中的顺序决定的，并不是3D空间中的Z轴顺序。当给立方体添加视图的时候，我们实际上是按照数字顺序添加的，所以按照视图/图层顺序来说，4，5，6在3的前面。

即使我们看不见4，5，6的表面（因为被1，2，3遮住了），iOS在事件响应上仍然保持之前的顺序。当试图点击表面3上的按钮，表面4，5，6截断了点击事件（取决于点击的位置），这就和普通的2D布局在按钮上覆盖物体一样。

你也许认为把`doubleSided`设置成`NO`可以解决这个问题，因为它不再渲染视图后面的内容，但实际上并不起作用。因为背对相机而隐藏的视图仍然会响应点击事件（这和通过设置`hidden`属性或者设置`alpha`为0而隐藏的视图不同，那两种方式将不会响应事件）。所以即使禁止了双面渲染仍然不能解决这个问题（虽然由于性能问题，还是需要把它设置成`NO`）。

这里有几种正确的方案：把除了表面3的其他视图`userInteractionEnabled`属性都设置成`NO`来禁止事件传递。或者简单通过代码把视图3覆盖在视图6上。无论怎样都可以点击按钮了（图5.23）。

<img src="./5.23.jpeg" alt="图5.23" title="图5.23" width="700"/>

图5.23 背景视图不再阻碍按钮，我们可以点击它了


## 总结

这一章涉及了一些2D和3D的变换。你学习了一些矩阵计算的基础，以及如何用Core Animation创建3D场景。你看到了图层背后到底是如何呈现的，并且知道了不能把扁平的图片做成真实的立体效果，最后我们用demo说明了触摸事件的处理，视图中图层添加的层级顺序会比屏幕上显示的顺序更有意义。

第六章我们会研究一些Core Animation提供不同功能的具体的`CALayer`子类。





## 专用图层

>复杂的组织都是专门化的

>Catharine R. Stimpson

到目前为止，我们已经探讨过`CALayer`类了，同时我们也了解到了一些非常有用的绘图和动画功能。但是Core Animation图层不仅仅能作用于图片和颜色而已。本章就会学习其他的一些图层类，进一步扩展使用Core Animation绘图的能力。

##CAShapeLayer

在第四章『视觉效果』我们学习到了不使用图片的情况下用`CGPath`去构造任意形状的阴影。如果我们能用同样的方式创建相同形状的图层就好了。

`CAShapeLayer`是一个通过矢量图形而不是bitmap来绘制的图层子类。你指定诸如颜色和线宽等属性，用`CGPath`来定义想要绘制的图形，最后`CAShapeLayer`就自动渲染出来了。当然，你也可以用Core Graphics直接向原始的`CALyer`的内容中绘制一个路径，相比之下，使用`CAShapeLayer`有以下一些优点：

* 渲染快速。`CAShapeLayer`使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
* 高效使用内存。一个`CAShapeLayer`不需要像普通`CALayer`一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
* 不会被图层边界剪裁掉。一个`CAShapeLayer`可以在边界之外绘制。你的图层路径不会像在使用Core Graphics的普通`CALayer`一样被剪裁掉（如我们在第二章所见）。
* 不会出现像素化。当你把`CAShapeLayer`放大，或是用3D透视变换将其离相机更近时，它不像一个有寄宿图的普通图层一样变得像素化。

### 创建一个`CGPath`

`CAShapeLayer`可以用来绘制所有能够通过`CGPath`来表示的形状。这个形状不一定要闭合，图层路径也不一定要不间断的，事实上你可以在一个图层上绘制好几个不同的形状。你可以控制一些属性比如`lineWith`（线宽，用点表示单位），`lineCap`（线条结尾的样子），和`lineJoin`（线条之间的结合点的样子）；但是在图层层面你只有一次机会设置这些属性。如果你想用不同颜色或风格来绘制多个形状，就不得不为每个形状准备一个图层了。

清单6.1 的代码用一个`CAShapeLayer`渲染一个简单的火柴人。`CAShapeLayer`的`path`属性是`CGPathRef`类型，但是我们用`UIBezierPath`帮助类创建了图层路径，这样我们就不用考虑人工释放`CGPath`了。图6.1是代码运行的结果。虽然还不是很完美，但是总算知道了大意对吧！

清单6.1 用`CAShapeLayer`绘制一个火柴人

```objective-c
#import "DrawingView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//create path
UIBezierPath *path = [[UIBezierPath alloc] init];
[path moveToPoint:CGPointMake(175, 100)];
￼
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
shapeLayer.strokeColor = [UIColor redColor].CGColor;
shapeLayer.fillColor = [UIColor clearColor].CGColor;
shapeLayer.lineWidth = 5;
shapeLayer.lineJoin = kCALineJoinRound;
shapeLayer.lineCap = kCALineCapRound;
shapeLayer.path = path.CGPath;
//add it to our view
[self.containerView.layer addSublayer:shapeLayer];
}
@end
```

![图6.1](./6.1.png)

图6.1 用`CAShapeLayer`绘制一个简单的火柴人

### 圆角

第二章里面提到了`CAShapeLayer`是一个代替使用`CALayer`的`cornerRadius`属性来创建视图圆角的替代方法（译者注：其实是在第四章提到的）。虽然使用`CAShapeLayer`类需要更多的工作，但是它有一个优势就是可以单独指定每个角。

我们创建圆角矩形其实就是人工绘制单独的直线和弧度，但是事实上`UIBezierPath`有方便地自动绘制圆角矩形的构造方法，下面这段代码绘制了一个有三个圆角一个直角的矩形：

```objective-c
//define path parameters
CGRect rect = CGRectMake(50, 50, 100, 100);
CGSize radii = CGSizeMake(20, 20);
UIRectCorner corners = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
//create path
UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
```

我们可以通过这个图层路径绘制一个既有直角又有圆角的视图。如果我们想依照此图形来剪裁视图内容，我们可以把`CAShapeLayer`作为视图的宿主图层，而不是添加一个子视图（图层蒙板的详细解释见第四章『视觉效果』）。

## CATextLayer

用户界面是无法从一个单独的图片里面构建的。一个设计良好的图标能够很好地表现一个按钮或控件的意图，不过你迟早都要需要一个不错的老式风格的文本标签。

如果你想在一个图层里面显示文字，完全可以借助图层代理直接将字符串使用Core Graphics写入图层的内容（事实上这就是`UILabel`所做的）。如果越过寄宿于图层的视图，直接在图层上操作，那其实相当繁琐。你要为每一个显示文字的图层创建一个能像图层代理一样工作的类，还要逻辑上判断哪个图层需要显示哪个字符串，更别提还要记录不同的字体，颜色等一系列乱七八糟的东西。

万幸的是这些都是不必要的，Core Animation提供了一个`CALayer`的子类`CATextLayer`，它以图层的形式包含了`UILabel`几乎所有的绘制特性，并且额外提供了一些新的特性。

同样，`CATextLayer`也要比`UILabel`渲染得快得多。很少有人知道在iOS 6及之前的版本，`UILabel`其实是通过WebKit来实现绘制的，这样就造成了当有很多文字的时候就会有极大的性能压力。而`CATextLayer`使用了Core text，并且渲染得非常快。

让我们来尝试用`CATextLayer`来显示一些文字。清单6.2的代码实现了这一功能，结果如图6.2所示。

清单6.2 用`CATextLayer`来实现一个`UILabel`

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *labelView;

@end

@implementation ViewController
- (void)viewDidLoad
{
[super viewDidLoad];

//create a text layer
CATextLayer *textLayer = [CATextLayer layer];
textLayer.frame = self.labelView.bounds;
[self.labelView.layer addSublayer:textLayer];

//set text attributes
textLayer.foregroundColor = [UIColor blackColor].CGColor;
textLayer.alignmentMode = kCAAlignmentJustified;
textLayer.wrapped = YES;

//choose a font
UIFont *font = [UIFont systemFontOfSize:15];

//set layer font
CFStringRef fontName = (__bridge CFStringRef)font.fontName;
CGFontRef fontRef = CGFontCreateWithFontName(fontName);
textLayer.font = fontRef;
textLayer.fontSize = font.pointSize;
CGFontRelease(fontRef);

//choose some text
NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing \ elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar \ leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc elementum, libero ut porttitor dictum, diam odio congue lacus, vel \ fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet \ lobortis";

//set layer text
textLayer.string = text;
}
@end
```

![图6.2](./6.2.png)

图6.2 用`CATextLayer`来显示一个纯文本标签

如果你仔细看这个文本，你会发现一个奇怪的地方：这些文本有一些像素化了。这是因为并没有以Retina的方式渲染，第二章提到了这个`contentScale`属性，用来决定图层内容应该以怎样的分辨率来渲染。`contentsScale`并不关心屏幕的拉伸因素而总是默认为1.0。如果我们想以Retina的质量来显示文字，我们就得手动地设置`CATextLayer`的`contentsScale`属性，如下：

```objective-c
textLayer.contentsScale = [UIScreen mainScreen].scale;
```

这样就解决了这个问题（如图6.3）

![图6.3](./6.3.png)

图6.3 设置`contentsScale`来匹配屏幕

`CATextLayer`的`font`属性不是一个`UIFont`类型，而是一个`CFTypeRef`类型。这样可以根据你的具体需要来决定字体属性应该是用`CGFontRef`类型还是`CTFontRef`类型（Core Text字体）。同时字体大小也是用`fontSize`属性单独设置的，因为`CTFontRef`和`CGFontRef`并不像UIFont一样包含点大小。这个例子会告诉你如何将`UIFont`转换成`CGFontRef`。

另外，`CATextLayer`的`string`属性并不是你想象的`NSString`类型，而是`id`类型。这样你既可以用`NSString`也可以用`NSAttributedString`来指定文本了（注意，`NSAttributedString`并不是`NSString`的子类）。属性化字符串是iOS用来渲染字体风格的机制，它以特定的方式来决定指定范围内的字符串的原始信息，比如字体，颜色，字重，斜体等。

### 富文本

iOS 6中，Apple给`UILabel`和其他UIKit文本视图添加了直接的属性化字符串的支持，应该说这是一个很方便的特性。不过事实上从iOS3.2开始`CATextLayer`就已经支持属性化字符串了。这样的话，如果你想要支持更低版本的iOS系统，`CATextLayer`无疑是你向界面中增加富文本的好办法，而且也不用去跟复杂的Core Text打交道，也省了用`UIWebView`的麻烦。

让我们编辑一下示例使用到`NSAttributedString`（见清单6.3）.iOS 6及以上我们可以用新的`NSTextAttributeName`实例来设置我们的字符串属性，但是练习的目的是为了演示在iOS 5及以下，所以我们用了Core Text，也就是说你需要把Core Text framework添加到你的项目中。否则，编译器是无法识别属性常量的。

图6.4是代码运行结果（注意那个红色的下划线文本）

清单6.3 用NSAttributedString实现一个富文本标签。

```objective-c
#import "DrawingView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *labelView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];

//create a text layer
CATextLayer *textLayer = [CATextLayer layer];
textLayer.frame = self.labelView.bounds;
textLayer.contentsScale = [UIScreen mainScreen].scale;
[self.labelView.layer addSublayer:textLayer];

//set text attributes
textLayer.alignmentMode = kCAAlignmentJustified;
textLayer.wrapped = YES;

//choose a font
UIFont *font = [UIFont systemFontOfSize:15];

//choose some text
NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing \ elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar \ leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc \ elementum, libero ut porttitor dictum, diam odio congue lacus, vel \ fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet \ lobortis";
￼
//create attributed string
NSMutableAttributedString *string = nil;
string = [[NSMutableAttributedString alloc] initWithString:text];

//convert UIFont to a CTFont
CFStringRef fontName = (__bridge CFStringRef)font.fontName;
CGFloat fontSize = font.pointSize;
CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);

//set text attributes
NSDictionary *attribs = @{
(__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor blackColor].CGColor,
(__bridge id)kCTFontAttributeName: (__bridge id)fontRef
};

[string setAttributes:attribs range:NSMakeRange(0, [text length])];
attribs = @{
(__bridge id)kCTForegroundColorAttributeName: (__bridge id)[UIColor redColor].CGColor,
(__bridge id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleSingle),
(__bridge id)kCTFontAttributeName: (__bridge id)fontRef
};
[string setAttributes:attribs range:NSMakeRange(6, 5)];

//release the CTFont we created earlier
CFRelease(fontRef);

//set layer text
textLayer.string = string;
}
@end
```

![图6.4](./6.4.png)

图6.4 用CATextLayer实现一个富文本标签。

###行距和字距

有必要提一下的是，由于绘制的实现机制不同（Core Text和WebKit），用`CATextLayer`渲染和用`UILabel`渲染出的文本行距和字距也是不完全相同的。

二者的差异程度（由使用的字体和字符决定）总的来说挺小，但是如果你想正确的显示普通便签和`CATextLayer`就一定要记住这一点。

### `UILabel`的替代品

我们已经证实了`CATextLayer`比`UILabel`有着更好的性能表现，同时还有额外的布局选项并且在iOS 5上支持富文本。但是与一般的标签比较而言会更加繁琐一些。如果我们真的在需求一个`UILabel`的可用替代品，最好是能够在Interface Builder上创建我们的标签，而且尽可能地像一般的视图一样正常工作。

我们应该继承`UILabel`，然后添加一个子图层`CATextLayer`并重写显示文本的方法。但是仍然会有由`UILabel`的`-drawRect:`方法创建的空寄宿图。而且由于`CALayer`不支持自动缩放和自动布局，子视图并不是主动跟踪视图边界的大小，所以每次视图大小被更改，我们不得不手动更新子图层的边界。

我们真正想要的是一个用`CATextLayer`作为宿主图层的`UILabel`子类，这样就可以随着视图自动调整大小而且也没有冗余的寄宿图啦。

就像我们在第一章『图层树』讨论的一样，每一个`UIView`都是寄宿在一个`CALayer`的示例上。这个图层是由视图自动创建和管理的，那我们可以用别的图层类型替代它么？一旦被创建，我们就无法代替这个图层了。但是如果我们继承了`UIView`，那我们就可以重写`+layerClass`方法使得在创建的时候能返回一个不同的图层子类。`UIView`会在初始化的时候调用`+layerClass`方法，然后用它的返回类型来创建宿主图层。

清单6.4 演示了一个`UILabel`子类`LayerLabel`用`CATextLayer`绘制它的问题，而不是调用一般的`UILabel`使用的较慢的`-drawRect：`方法。`LayerLabel`示例既可以用代码实现，也可以在Interface Builder实现，只要把普通的标签拖入视图之中，然后设置它的类是LayerLabel就可以了。

清单6.4 使用`CATextLayer`的`UILabel`子类：`LayerLabel`

```objective-c
#import "LayerLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation LayerLabel
+ (Class)layerClass
{
//this makes our label create a CATextLayer //instead of a regular CALayer for its backing layer
return [CATextLayer class];
}

- (CATextLayer *)textLayer
{
return (CATextLayer *)self.layer;
}

- (void)setUp
{
//set defaults from UILabel settings
self.text = self.text;
self.textColor = self.textColor;
self.font = self.font;

//we should really derive these from the UILabel settings too
//but that's complicated, so for now we'll just hard-code them
[self textLayer].alignmentMode = kCAAlignmentJustified;
￼
[self textLayer].wrapped = YES;
[self.layer display];
}

- (id)initWithFrame:(CGRect)frame
{
//called when creating label programmatically
if (self = [super initWithFrame:frame]) {
[self setUp];
}
return self;
}

- (void)awakeFromNib
{
//called when creating label using Interface Builder
[self setUp];
}

- (void)setText:(NSString *)text
{
super.text = text;
//set layer text
[self textLayer].string = text;
}

- (void)setTextColor:(UIColor *)textColor
{
super.textColor = textColor;
//set layer text color
[self textLayer].foregroundColor = textColor.CGColor;
}

- (void)setFont:(UIFont *)font
{
super.font = font;
//set layer font
CFStringRef fontName = (__bridge CFStringRef)font.fontName;
CGFontRef fontRef = CGFontCreateWithFontName(fontName);
[self textLayer].font = fontRef;
[self textLayer].fontSize = font.pointSize;
￼
CGFontRelease(fontRef);
}
@end
```

如果你运行代码，你会发现文本并没有像素化，而我们也没有设置`contentsScale`属性。把`CATextLayer`作为宿主图层的另一好处就是视图自动设置了`contentsScale`属性。

在这个简单的例子中，我们只是实现了`UILabel`的一部分风格和布局属性，不过稍微再改进一下我们就可以创建一个支持`UILabel`所有功能甚至更多功能的`LayerLabel`类（你可以在一些线上的开源项目中找到）。

如果你打算支持iOS 6及以上，基于`CATextLayer`的标签可能就有有些局限性。但是总得来说，如果想在app里面充分利用`CALayer`子类，用`+layerClass`来创建基于不同图层的视图是一个简单可复用的方法。

### CATransformLayer

当我们在构造复杂的3D事物的时候，如果能够组织独立元素就太方便了。比如说，你想创造一个孩子的手臂：你就需要确定哪一部分是孩子的手腕，哪一部分是孩子的前臂，哪一部分是孩子的肘，哪一部分是孩子的上臂，哪一部分是孩子的肩膀等等。

这样做的原因是允许独立地移动每个区域。以肘为指点会移动前臂和手，而不是肩膀。Core Animation图层很容易就可以让你在2D环境下做出这样的层级体系下的变换，但是3D情况下就不太可能，因为所有的图层都把他的孩子都平面化到一个场景中（第五章『变换』有提到）。

`CATransformLayer`解决了这个问题，`CATransformLayer`不同于普通的`CALayer`，因为它不能显示它自己的内容。只有当存在了一个能作用于子图层的变换它才真正存在。`CATransformLayer`并不平面化它的子图层，所以它能够用于构造一个层级的3D结构，比如我的手臂示例。

用代码创建一个手臂需要相当多的代码，所以我就演示得更简单一些吧：在第五章的立方体示例，我们将通过旋转`camara`来解决图层平面化问题而不是像立方体示例代码中用的`sublayerTransform`。这是一个非常不错的技巧，但是只能作用于单个对象上，如果你的场景包含两个立方体，那我们就不能用这个技巧单独旋转他们了。

那么，就让我们来试一试`CATransformLayer`吧，第一个问题就来了：在第五章，我们是用多个视图来构造了我们的立方体，而不是单独的图层。我们不能在不打乱已有的视图层次的前提下在一个本身不是有寄宿图的图层中放置一个寄宿图图层。我们可以创建一个新的`UIView`子类寄宿在`CATransformLayer`（用`+layerClass`方法）之上。但是，为了简化案例，我们仅仅重建了一个单独的图层，而不是使用视图。这意味着我们不能像第五章一样在立方体表面显示按钮和标签，不过我们现在也用不到这个特性。

清单6.5就是代码。我们以我们在第五章使用过的相同基本逻辑放置立方体。但是并不像以前那样直接将立方面添加到容器视图的宿主图层，我们将他们放置到一个`CATransformLayer`中创建一个独立的立方体对象，然后将两个这样的立方体放进容器中。我们随机地给立方面染色以将他们区分开来，这样就不用靠标签或是光亮来区分他们。图6.5是运行结果。

清单6.5 用`CATransformLayer`装配一个3D图层体系

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (CALayer *)faceWithTransform:(CATransform3D)transform
{
//create cube face layer
CALayer *face = [CALayer layer];
face.frame = CGRectMake(-50, -50, 100, 100);

//apply a random color
CGFloat red = (rand() / (double)INT_MAX);
CGFloat green = (rand() / (double)INT_MAX);
CGFloat blue = (rand() / (double)INT_MAX);
face.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;

￼//apply the transform and return
face.transform = transform;
return face;
}

- (CALayer *)cubeWithTransform:(CATransform3D)transform
{
//create cube layer
CATransformLayer *cube = [CATransformLayer layer];

//add cube face 1
CATransform3D ct = CATransform3DMakeTranslation(0, 0, 50);
[cube addSublayer:[self faceWithTransform:ct]];

//add cube face 2
ct = CATransform3DMakeTranslation(50, 0, 0);
ct = CATransform3DRotate(ct, M_PI_2, 0, 1, 0);
[cube addSublayer:[self faceWithTransform:ct]];

//add cube face 3
ct = CATransform3DMakeTranslation(0, -50, 0);
ct = CATransform3DRotate(ct, M_PI_2, 1, 0, 0);
[cube addSublayer:[self faceWithTransform:ct]];

//add cube face 4
ct = CATransform3DMakeTranslation(0, 50, 0);
ct = CATransform3DRotate(ct, -M_PI_2, 1, 0, 0);
[cube addSublayer:[self faceWithTransform:ct]];

//add cube face 5
ct = CATransform3DMakeTranslation(-50, 0, 0);
ct = CATransform3DRotate(ct, -M_PI_2, 0, 1, 0);
[cube addSublayer:[self faceWithTransform:ct]];

//add cube face 6
ct = CATransform3DMakeTranslation(0, 0, -50);
ct = CATransform3DRotate(ct, M_PI, 0, 1, 0);
[cube addSublayer:[self faceWithTransform:ct]];

//center the cube layer within the container
CGSize containerSize = self.containerView.bounds.size;
cube.position = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);

//apply the transform and return
cube.transform = transform;
return cube;
}

- (void)viewDidLoad
{￼
[super viewDidLoad];

//set up the perspective transform
CATransform3D pt = CATransform3DIdentity;
pt.m34 = -1.0 / 500.0;
self.containerView.layer.sublayerTransform = pt;

//set up the transform for cube 1 and add it
CATransform3D c1t = CATransform3DIdentity;
c1t = CATransform3DTranslate(c1t, -100, 0, 0);
CALayer *cube1 = [self cubeWithTransform:c1t];
[self.containerView.layer addSublayer:cube1];

//set up the transform for cube 2 and add it
CATransform3D c2t = CATransform3DIdentity;
c2t = CATransform3DTranslate(c2t, 100, 0, 0);
c2t = CATransform3DRotate(c2t, -M_PI_4, 1, 0, 0);
c2t = CATransform3DRotate(c2t, -M_PI_4, 0, 1, 0);
CALayer *cube2 = [self cubeWithTransform:c2t];
[self.containerView.layer addSublayer:cube2];
}
@end
```

![图6.5](./6.5.png)

图6.5 同一视角下的俩不同变换的立方体

## CAGradientLayer

`CAGradientLayer`是用来生成两种或更多颜色平滑渐变的。用Core Graphics复制一个`CAGradientLayer`并将内容绘制到一个普通图层的寄宿图也是有可能的，但是`CAGradientLayer`的真正好处在于绘制使用了硬件加速。

###基础渐变

我们将从一个简单的红变蓝的对角线渐变开始（见清单6.6）.这些渐变色彩放在一个数组中，并赋给`colors`属性。这个数组成员接受`CGColorRef`类型的值（并不是从`NSObject`派生而来），所以我们要用通过bridge转换以确保编译正常。

`CAGradientLayer`也有`startPoint`和`endPoint`属性，他们决定了渐变的方向。这两个参数是以单位坐标系进行的定义，所以左上角坐标是{0, 0}，右下角坐标是{1, 1}。代码运行结果如图6.6

清单6.6 简单的两种颜色的对角线渐变

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//create gradient layer and add it to our container view
CAGradientLayer *gradientLayer = [CAGradientLayer layer];
gradientLayer.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:gradientLayer];

//set gradient colors
gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor];

//set gradient start and end points
gradientLayer.startPoint = CGPointMake(0, 0);
gradientLayer.endPoint = CGPointMake(1, 1);
}
@end
```

![图6.6](./6.6.png)

图6.6 用`CAGradientLayer`实现简单的两种颜色的对角线渐变

### 多重渐变


如果你愿意，`colors`属性可以包含很多颜色，所以创建一个彩虹一样的多重渐变也是很简单的。默认情况下，这些颜色在空间上均匀地被渲染，但是我们可以用`locations`属性来调整空间。`locations`属性是一个浮点数值的数组（以`NSNumber`包装）。这些浮点数定义了`colors`属性中每个不同颜色的位置，同样的，也是以单位坐标系进行标定。0.0代表着渐变的开始，1.0代表着结束。

`locations`数组并不是强制要求的，但是如果你给它赋值了就一定要确保`locations`的数组大小和`colors`数组大小一定要相同，否则你将会得到一个空白的渐变。

清单6.7展示了一个基于清单6.6的对角线渐变的代码改造。现在变成了从红到黄最后到绿色的渐变。`locations`数组指定了0.0，0.25和0.5三个数值，这样这三个渐变就有点像挤在了左上角。（如图6.7）.

清单6.7 在渐变上使用`locations`

```objective-c
- (void)viewDidLoad {
[super viewDidLoad];

//create gradient layer and add it to our container view
CAGradientLayer *gradientLayer = [CAGradientLayer layer];
gradientLayer.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:gradientLayer];

//set gradient colors
gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id) [UIColor yellowColor].CGColor, (__bridge id)[UIColor greenColor].CGColor];

//set locations
gradientLayer.locations = @[@0.0, @0.25, @0.5];

//set gradient start and end points
gradientLayer.startPoint = CGPointMake(0, 0);
gradientLayer.endPoint = CGPointMake(1, 1);
}
```

![图6.7](./6.7.png)

图6.7 用`locations`构造偏移至左上角的三色渐变

## CAReplicatorLayer

`CAReplicatorLayer`的目的是为了高效生成许多相似的图层。它会绘制一个或多个图层的子图层，并在每个复制体上应用不同的变换。看上去演示能够更加解释这些，我们来写个例子吧。

### 重复图层（Repeating Layers）

清单6.8中，我们在屏幕的中间创建了一个小白色方块图层，然后用`CAReplicatorLayer`生成十个图层组成一个圆圈。`instanceCount`属性指定了图层需要重复多少次。`instanceTransform`指定了一个`CATransform3D`3D变换（这种情况下，下一图层的位移和旋转将会移动到圆圈的下一个点）。

变换是逐步增加的，每个实例都是相对于前一实例布局。这就是为什么这些复制体最终不会出现在同意位置上，图6.8是代码运行结果。

清单6.8 用`CAReplicatorLayer`重复图层

```objective-c
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation ViewController
- (void)viewDidLoad
{
[super viewDidLoad];
//create a replicator layer and add it to our view
CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
replicator.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:replicator];

//configure the replicator
replicator.instanceCount = 10;

//apply a transform for each instance
CATransform3D transform = CATransform3DIdentity;
transform = CATransform3DTranslate(transform, 0, 200, 0);
transform = CATransform3DRotate(transform, M_PI / 5.0, 0, 0, 1);
transform = CATransform3DTranslate(transform, 0, -200, 0);
replicator.instanceTransform = transform;

//apply a color shift for each instance
replicator.instanceBlueOffset = -0.1;
replicator.instanceGreenOffset = -0.1;

//create a sublayer and place it inside the replicator
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(100.0f, 100.0f, 100.0f, 100.0f);
layer.backgroundColor = [UIColor whiteColor].CGColor;
[replicator addSublayer:layer];
}
@end
```

![图6.8](./6.8.png)

图6.8 用`CAReplicatorLayer`创建一圈图层

注意到当图层在重复的时候，他们的颜色也在变化：这是用`instanceBlueOffset`和`instanceGreenOffset`属性实现的。通过逐步减少蓝色和绿色通道，我们逐渐将图层颜色转换成了红色。这个复制效果看起来很酷，但是`CAReplicatorLayer`真正应用到实际程序上的场景比如：一个游戏中导弹的轨迹云，或者粒子爆炸（尽管iOS 5已经引入了`CAEmitterLayer`，它更适合创建任意的粒子效果）。除此之外，还有一个实际应用是：反射。

### 反射

使用`CAReplicatorLayer`并应用一个负比例变换于一个复制图层，你就可以创建指定视图（或整个视图层次）内容的镜像图片，这样就创建了一个实时的『反射』效果。让我们来尝试实现这个创意：指定一个继承于`UIView`的`ReflectionView`，它会自动产生内容的反射效果。实现这个效果的代码很简单（见清单6.9），实际上用`ReflectionView`实现这个效果会更简单，我们只需要把`ReflectionView`的实例放置于Interface Builder（见图6.9），它就会实时生成子视图的反射，而不需要别的代码（见图6.10）.

清单6.9 用`CAReplicatorLayer`自动绘制反射

```objective-c
#import "ReflectionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ReflectionView

+ (Class)layerClass
{
return [CAReplicatorLayer class];
}

- (void)setUp
{
//configure replicator
CAReplicatorLayer *layer = (CAReplicatorLayer *)self.layer;
layer.instanceCount = 2;

//move reflection instance below original and flip vertically
CATransform3D transform = CATransform3DIdentity;
CGFloat verticalOffset = self.bounds.size.height + 2;
transform = CATransform3DTranslate(transform, 0, verticalOffset, 0);
transform = CATransform3DScale(transform, 1, -1, 0);
layer.instanceTransform = transform;

//reduce alpha of reflection layer
layer.instanceAlphaOffset = -0.6;
}
￼
- (id)initWithFrame:(CGRect)frame
{
//this is called when view is created in code
if ((self = [super initWithFrame:frame])) {
[self setUp];
}
return self;
}

- (void)awakeFromNib
{
//this is called when view is created from a nib
[self setUp];
}
@end
```

![图6.9](./6.9.png)

图6.9 在Interface Builder中使用`ReflectionView`

![图6.10](./6.10.png)

图6.10 `ReflectionView`自动实时产生反射效果。

开源代码`ReflectionView`完成了一个自适应的渐变淡出效果（用`CAGradientLayer`和图层蒙板实现），代码见 https://github.com/nicklockwood/ReflectionView

## CAScrollLayer

对于一个未转换的图层，它的`bounds`和它的`frame`是一样的，`frame`属性是由`bounds`属性自动计算而出的，所以更改任意一个值都会更新其他值。

但是如果你只想显示一个大图层里面的一小部分呢。比如说，你可能有一个很大的图片，你希望用户能够随意滑动，或者是一个数据或文本的长列表。在一个典型的iOS应用中，你可能会用到`UITableView`或是`UIScrollView`，但是对于独立的图层来说，什么会等价于刚刚提到的`UITableView`和`UIScrollView`呢？

在第二章中，我们探索了图层的`contentsRect`属性的用法，它的确是能够解决在图层中小地方显示大图片的解决方法。但是如果你的图层包含子图层那它就不是一个非常好的解决方案，因为，这样做的话每次你想『滑动』可视区域的时候，你就需要手工重新计算并更新所有的子图层位置。

这个时候就需要`CAScrollLayer`了。`CAScrollLayer`有一个`-scrollToPoint:`方法，它自动适应`bounds`的原点以便图层内容出现在滑动的地方。注意，这就是它做的所有事情。前面提到过，Core Animation并不处理用户输入，所以`CAScrollLayer`并不负责将触摸事件转换为滑动事件，既不渲染滚动条，也不实现任何iOS指定行为例如滑动反弹（当视图滑动超多了它的边界的将会反弹回正确的地方）。

让我们来用`CAScrollLayer`来常见一个基本的`UIScrollView`替代品。我们将会用`CAScrollLayer`作为视图的宿主图层，并创建一个自定义的`UIView`，然后用`UIPanGestureRecognizer`实现触摸事件响应。这段代码见清单6.10. 图6.11是运行效果：`ScrollView`显示了一个大于它的`frame`的`UIImageView`。

清单6.10 用`CAScrollLayer`实现滑动视图

```objective-c
#import "ScrollView.h"
#import <QuartzCore/QuartzCore.h> @implementation ScrollView
+ (Class)layerClass
{
return [CAScrollLayer class];
}

- (void)setUp
{
//enable clipping
self.layer.masksToBounds = YES;

//attach pan gesture recognizer
UIPanGestureRecognizer *recognizer = nil;
recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
[self addGestureRecognizer:recognizer];
}

- (id)initWithFrame:(CGRect)frame
{
//this is called when view is created in code
if ((self = [super initWithFrame:frame])) {
[self setUp];
}
return self;
}

- (void)awakeFromNib {
//this is called when view is created from a nib
[self setUp];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
//get the offset by subtracting the pan gesture
//translation from the current bounds origin
CGPoint offset = self.bounds.origin;
offset.x -= [recognizer translationInView:self].x;
offset.y -= [recognizer translationInView:self].y;

//scroll the layer
[(CAScrollLayer *)self.layer scrollToPoint:offset];

//reset the pan gesture translation
[recognizer setTranslation:CGPointZero inView:self];
}
@end
```

图6.11 用`UIScrollView`创建一个凑合的滑动视图

不同于`UIScrollView`，我们定制的滑动视图类并没有实现任何形式的边界检查（bounds checking）。图层内容极有可能滑出视图的边界并无限滑下去。`CAScrollLayer`并没有等同于`UIScrollView`中`contentSize`的属性，所以当`CAScrollLayer`滑动的时候完全没有一个全局的可滑动区域的概念，也无法自适应它的边界原点至你指定的值。它之所以不能自适应边界大小是因为它不需要，内容完全可以超过边界。

那你一定会奇怪用`CAScrollLayer`的意义到底何在，因为你可以简单地用一个普通的`CALayer`然后手动适应边界原点啊。真相其实并不复杂，`UIScrollView`并没有用`CAScrollLayer`，事实上，就是简单的通过直接操作图层边界来实现滑动。

`CAScrollLayer`有一个潜在的有用特性。如果你查看`CAScrollLayer`的头文件，你就会注意到有一个扩展分类实现了一些方法和属性：

```objective-c
- (void)scrollPoint:(CGPoint)p;
- (void)scrollRectToVisible:(CGRect)r;
@property(readonly) CGRect visibleRect;
```

看到这些方法和属性名，你也许会以为这些方法给每个`CALayer`实例增加了滑动功能。但是事实上他们只是放置在`CAScrollLayer`中的图层的实用方法。`scrollPoint:`方法从图层树中查找并找到第一个可用的`CAScrollLayer`，然后滑动它使得指定点成为可视的。`scrollRectToVisible:`方法实现了同样的事情只不过是作用在一个矩形上的。`visibleRect`属性决定图层（如果存在的话）的哪部分是当前的可视区域。如果你自己实现这些方法就会相对容易明白一点，但是`CAScrollLayer`帮你省了这些麻烦，所以当涉及到实现图层滑动的时候就可以用上了。

## CATiledLayer

有些时候你可能需要绘制一个很大的图片，常见的例子就是一个高像素的照片或者是地球表面的详细地图。iOS应用通畅运行在内存受限的设备上，所以读取整个图片到内存中是不明智的。载入大图可能会相当地慢，那些对你看上去比较方便的做法（在主线程调用`UIImage`的`-imageNamed:`方法或者`-imageWithContentsOfFile:`方法）将会阻塞你的用户界面，至少会引起动画卡顿现象。

能高效绘制在iOS上的图片也有一个大小限制。所有显示在屏幕上的图片最终都会被转化为OpenGL纹理，同时OpenGL有一个最大的纹理尺寸（通常是2048\*2048，或4096\*4096，这个取决于设备型号）。如果你想在单个纹理中显示一个比这大的图，即便图片已经存在于内存中了，你仍然会遇到很大的性能问题，因为Core Animation强制用CPU处理图片而不是更快的GPU（见第12章『速度的曲调』，和第13章『高效绘图』，它更加详细地解释了软件绘制和硬件绘制）。

`CATiledLayer`为载入大图造成的性能问题提供了一个解决方案：将大图分解成小片然后将他们单独按需载入。让我们用实验来证明一下。

### 小片裁剪

这个示例中，我们将会从一个2048*2048分辨率的雪人图片入手。为了能够从`CATiledLayer`中获益，我们需要把这个图片裁切成许多小一些的图片。你可以通过代码来完成这件事情，但是如果你在运行时读入整个图片并裁切，那`CATiledLayer`这些所有的性能优点就损失殆尽了。理想情况下来说，最好能够逐个步骤来实现。

清单6.11 演示了一个简单的Mac OS命令行程序，它用`CATiledLayer`将一个图片裁剪成小图并存储到不同的文件中。

清单6.11 裁剪图片成小图的终端程序

```objective-c
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[])
{
@autoreleasepool{
￼//handle incorrect arguments
if (argc < 2) {
NSLog(@"TileCutter arguments: inputfile");
return 0;
}

//input file
NSString *inputFile = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];

//tile size
CGFloat tileSize = 256; //output path
NSString *outputPath = [inputFile stringByDeletingPathExtension];

//load image
NSImage *image = [[NSImage alloc] initWithContentsOfFile:inputFile];
NSSize size = [image size];
NSArray *representations = [image representations];
if ([representations count]){
NSBitmapImageRep *representation = representations[0];
size.width = [representation pixelsWide];
size.height = [representation pixelsHigh];
}
NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
CGImageRef imageRef = [image CGImageForProposedRect:&rect context:NULL hints:nil];

//calculate rows and columns
NSInteger rows = ceil(size.height / tileSize);
NSInteger cols = ceil(size.width / tileSize);

//generate tiles
for (int y = 0; y < rows; ++y) {
for (int x = 0; x < cols; ++x) {
//extract tile image
CGRect tileRect = CGRectMake(x*tileSize, y*tileSize, tileSize, tileSize);
CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, tileRect);

//convert to jpeg data
NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:tileImage];
NSData *data = [imageRep representationUsingType: NSJPEGFileType properties:nil];
CGImageRelease(tileImage);

//save file
NSString *path = [outputPath stringByAppendingFormat: @"_%02i_%02i.jpg", x, y];
[data writeToFile:path atomically:NO];
}
}
}
return 0;
}
```

这个程序将2048\*2048分辨率的雪人图案裁剪成了64个不同的256\*256的小图。（256*256是`CATiledLayer`的默认小图大小，默认大小可以通过`tileSize`属性更改）。程序接受一个图片路径作为命令行的第一个参数。我们可以在编译的scheme将路径参数硬编码然后就可以在Xcode中运行了，但是以后作用在另一个图片上就不方便了。所以，我们编译了这个程序并把它保存到敏感的地方，然后从终端调用，如下面所示：

```objective-c
> path/to/TileCutterApp path/to/Snowman.jpg
```

The app is very basic, but could easily be extended to support additional arguments such as tile size, or to export images in formats other than JPEG. The result of running it is a sequence of 64 new images, named as follows:

这个程序相当基础，但是能够轻易地扩展支持额外的参数比如小图大小，或者导出格式等等。运行结果是64个新图的序列，如下面命名：

```
Snowman_00_00.jpg
Snowman_00_01.jpg
Snowman_00_02.jpg
...
Snowman_07_07.jpg
```

既然我们有了裁切后的小图，我们就要让iOS程序用到他们。`CATiledLayer`很好地和`UIScrollView`集成在一起。除了设置图层和滑动视图边界以适配整个图片大小，我们真正要做的就是实现`-drawLayer:inContext:`方法，当需要载入新的小图时，`CATiledLayer`就会调用到这个方法。

清单6.12演示了代码。图6.12是代码运行结果。

清单6.12 一个简单的滚动`CATiledLayer`实现

```objective-c
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//add the tiled layer
CATiledLayer *tileLayer = [CATiledLayer layer];￼
tileLayer.frame = CGRectMake(0, 0, 2048, 2048);
tileLayer.delegate = self; [self.scrollView.layer addSublayer:tileLayer];

//configure the scroll view
self.scrollView.contentSize = tileLayer.frame.size;

//draw layer
[tileLayer setNeedsDisplay];
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
{
//determine tile coordinate
CGRect bounds = CGContextGetClipBoundingBox(ctx);
NSInteger x = floor(bounds.origin.x / layer.tileSize.width);
NSInteger y = floor(bounds.origin.y / layer.tileSize.height);

//load tile image
NSString *imageName = [NSString stringWithFormat: @"Snowman_%02i_%02i", x, y];
NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
UIImage *tileImage = [UIImage imageWithContentsOfFile:imagePath];

//draw tile
UIGraphicsPushContext(ctx);
[tileImage drawInRect:bounds];
UIGraphicsPopContext();
}
@end
```

![图6.12](./6.12.png)

图6.12 用`UIScrollView`滚动`CATiledLayer`

当你滑动这个图片，你会发现当`CATiledLayer`载入小图的时候，他们会淡入到界面中。这是`CATiledLayer`的默认行为。（你可能已经在iOS 6之前的苹果地图程序中见过这个效果）你可以用`fadeDuration`属性改变淡入时长或直接禁用掉。`CATiledLayer`（不同于大部分的`UIKit`和Core Animation方法）支持多线程绘制，`-drawLayer:inContext:`方法可以在多个线程中同时地并发调用，所以请小心谨慎地确保你在这个方法中实现的绘制代码是线程安全的。

### Retina小图

你也许已经注意到了这些小图并不是以Retina的分辨率显示的。为了以屏幕的原生分辨率来渲染`CATiledLayer`，我们需要设置图层的`contentsScale`来匹配`UIScreen`的`scale`属性：

```objective-c
tileLayer.contentsScale = [UIScreen mainScreen].scale;
```

有趣的是，`tileSize`是以像素为单位，而不是点，所以增大了`contentsScale`就自动有了默认的小图尺寸（现在它是128\*128的点而不是256\*256）.所以，我们不需要手工更新小图的尺寸或是在Retina分辨率下指定一个不同的小图。我们需要做的是适应小图渲染代码以对应安排`scale`的变化，然而：

```objective-c
//determine tile coordinate
CGRect bounds = CGContextGetClipBoundingBox(ctx);
CGFloat scale = [UIScreen mainScreen].scale;
NSInteger x = floor(bounds.origin.x / layer.tileSize.width * scale);
NSInteger y = floor(bounds.origin.y / layer.tileSize.height * scale);
```

通过这个方法纠正`scale`也意味着我们的雪人图将以一半的大小渲染在Retina设备上（总尺寸是1024\*1024，而不是2048\*2048）。这个通常都不会影响到用`CATiledLayer`正常显示的图片类型（比如照片和地图，他们在设计上就是要支持放大缩小，能够在不同的缩放条件下显示），但是也需要在心里明白。

## CAEmitterLayer

在iOS 5中，苹果引入了一个新的`CALayer`子类叫做`CAEmitterLayer`。`CAEmitterLayer`是一个高性能的粒子引擎，被用来创建实时例子动画如：烟雾，火，雨等等这些效果。

`CAEmitterLayer`看上去像是许多`CAEmitterCell`的容器，这些`CAEmitierCell`定义了一个例子效果。你将会为不同的例子效果定义一个或多个`CAEmitterCell`作为模版，同时`CAEmitterLayer`负责基于这些模版实例化一个粒子流。一个`CAEmitterCell`类似于一个`CALayer`：它有一个`contents`属性可以定义为一个`CGImage`，另外还有一些可设置属性控制着表现和行为。我们不会对这些属性逐一进行详细的描述，你们可以在`CAEmitterCell`类的头文件中找到。

我们来举个例子。我们将利用在一圆中发射不同速度和透明度的粒子创建一个火爆炸的效果。清单6.13包含了生成爆炸的代码。图6.13是运行结果

清单6.13 用`CAEmitterLayer`创建爆炸效果

```objective-c
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView;

@end


@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
￼
//create particle emitter layer
CAEmitterLayer *emitter = [CAEmitterLayer layer];
emitter.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:emitter];

//configure emitter
emitter.renderMode = kCAEmitterLayerAdditive;
emitter.emitterPosition = CGPointMake(emitter.frame.size.width / 2.0, emitter.frame.size.height / 2.0);

//create a particle template
CAEmitterCell *cell = [[CAEmitterCell alloc] init];
cell.contents = (__bridge id)[UIImage imageNamed:@"Spark.png"].CGImage;
cell.birthRate = 150;
cell.lifetime = 5.0;
cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
cell.alphaSpeed = -0.4;
cell.velocity = 50;
cell.velocityRange = 50;
cell.emissionRange = M_PI * 2.0;

//add particle template to emitter
emitter.emitterCells = @[cell];
}
@end
```

图6.13 火焰爆炸效果

`CAEMitterCell`的属性基本上可以分为三种：

* 这种粒子的某一属性的初始值。比如，`color`属性指定了一个可以混合图片内容颜色的混合色。在示例中，我们将它设置为桔色。
* 粒子某一属性的变化范围。比如`emissionRange`属性的值是2π，这意味着粒子可以从360度任意位置反射出来。如果指定一个小一些的值，就可以创造出一个圆锥形。
* 指定值在时间线上的变化。比如，在示例中，我们将`alphaSpeed`设置为-0.4，就是说粒子的透明度每过一秒就是减少0.4，这样就有发射出去之后逐渐消失的效果。

`CAEmitterLayer`的属性它自己控制着整个粒子系统的位置和形状。一些属性比如`birthRate`，`lifetime`和`celocity`，这些属性在`CAEmitterCell`中也有。这些属性会以相乘的方式作用在一起，这样你就可以用一个值来加速或者扩大整个粒子系统。其他值得提到的属性有以下这些：

* `preservesDepth`，是否将3D粒子系统平面化到一个图层（默认值）或者可以在3D空间中混合其他的图层。
* `renderMode`，控制着在视觉上粒子图片是如何混合的。你可能已经注意到了示例中我们把它设置为`kCAEmitterLayerAdditive`，它实现了这样一个效果：合并粒子重叠部分的亮度使得看上去更亮。如果我们把它设置为默认的`kCAEmitterLayerUnordered`，效果就没那么好看了（见图6.14）。

![图6.14](./6.14.png)

图6.14 禁止混色之后的火焰粒子

## CAEAGLLayer

当iOS要处理高性能图形绘制，必要时就是OpenGL。应该说它应该是最后的杀手锏，至少对于非游戏的应用来说是的。因为相比Core Animation和UIkit框架，它不可思议地复杂。

OpenGL提供了Core Animation的基础，它是底层的C接口，直接和iPhone，iPad的硬件通信，极少地抽象出来的方法。OpenGL没有对象或是图层的继承概念。它只是简单地处理三角形。OpenGL中所有东西都是3D空间中有颜色和纹理的三角形。用起来非常复杂和强大，但是用OpenGL绘制iOS用户界面就需要很多很多的工作了。

为了能够以高性能使用Core Animation，你需要判断你需要绘制哪种内容（矢量图形，例子，文本，等等），但后选择合适的图层去呈现这些内容，Core Animation中只有一些类型的内容是被高度优化的；所以如果你想绘制的东西并不能找到标准的图层类，想要得到高性能就比较费事情了。

因为OpenGL根本不会对你的内容进行假设，它能够绘制得相当快。利用OpenGL，你可以绘制任何你知道必要的集合信息和形状逻辑的内容。所以很多游戏都喜欢用OpenGL（这些情况下，Core Animation的限制就明显了：它优化过的内容类型并不一定能满足需求），但是这样依赖，方便的高度抽象接口就没了。

在iOS 5中，苹果引入了一个新的框架叫做GLKit，它去掉了一些设置OpenGL的复杂性，提供了一个叫做`CLKView`的`UIView`的子类，帮你处理大部分的设置和绘制工作。前提是各种各样的OpenGL绘图缓冲的底层可配置项仍然需要你用`CAEAGLLayer`完成，它是`CALayer`的一个子类，用来显示任意的OpenGL图形。

大部分情况下你都不需要手动设置`CAEAGLLayer`（假设用GLKView），过去的日子就不要再提了。特别的，我们将设置一个OpenGL ES 2.0的上下文，它是现代的iOS设备的标准做法。

尽管不需要GLKit也可以做到这一切，但是GLKit囊括了很多额外的工作，比如设置顶点和片段着色器，这些都以类C语言叫做GLSL自包含在程序中，同时在运行时载入到图形硬件中。编写GLSL代码和设置`EAGLayer`没有什么关系，所以我们将用`GLKBaseEffect`类将着色逻辑抽象出来。其他的事情，我们还是会有以往的方式。

在开始之前，你需要将GLKit和OpenGLES框架加入到你的项目中，然后就可以实现清单6.14中的代码，里面是设置一个`GAEAGLLayer`的最少工作，它使用了OpenGL ES 2.0 的绘图上下文，并渲染了一个有色三角（见图6.15）.

清单6.14 用`CAEAGLLayer`绘制一个三角形

```objective-c
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *glView;
@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CAEAGLLayer *glLayer;
@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, strong) GLKBaseEffect *effect;
￼
@end

@implementation ViewController

- (void)setUpBuffers
{
//set up frame buffer
glGenFramebuffers(1, &_framebuffer);
glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

//set up color render buffer
glGenRenderbuffers(1, &_colorRenderbuffer);
glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
[self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);

//check success
if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
}
}

- (void)tearDownBuffers
{
if (_framebuffer) {
//delete framebuffer
glDeleteFramebuffers(1, &_framebuffer);
_framebuffer = 0;
}

if (_colorRenderbuffer) {
//delete color render buffer
glDeleteRenderbuffers(1, &_colorRenderbuffer);
_colorRenderbuffer = 0;
}
}

- (void)drawFrame {
//bind framebuffer & set viewport
glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
glViewport(0, 0, _framebufferWidth, _framebufferHeight);

//bind shader program
[self.effect prepareToDraw];

//clear the screen
glClear(GL_COLOR_BUFFER_BIT); glClearColor(0.0, 0.0, 0.0, 1.0);

//set up vertices
GLfloat vertices[] = {
-0.5f, -0.5f, -1.0f, 0.0f, 0.5f, -1.0f, 0.5f, -0.5f, -1.0f,
};

//set up colors
GLfloat colors[] = {
0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
};

//draw triangle
glEnableVertexAttribArray(GLKVertexAttribPosition);
glEnableVertexAttribArray(GLKVertexAttribColor);
glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
glVertexAttribPointer(GLKVertexAttribColor,4, GL_FLOAT, GL_FALSE, 0, colors);
glDrawArrays(GL_TRIANGLES, 0, 3);

//present render buffer
glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
[self.glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)viewDidLoad
{
[super viewDidLoad];
//set up context
self.glContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
[EAGLContext setCurrentContext:self.glContext];

//set up layer
self.glLayer = [CAEAGLLayer layer];
self.glLayer.frame = self.glView.bounds;
[self.glView.layer addSublayer:self.glLayer];
self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};

//set up base effect
self.effect = [[GLKBaseEffect alloc] init];

//set up buffers
[self setUpBuffers];

//draw frame
[self drawFrame];
}

- (void)viewDidUnload
{
[self tearDownBuffers];
[super viewDidUnload];
}

- (void)dealloc
{
[self tearDownBuffers];
[EAGLContext setCurrentContext:nil];
}
@end
```

![图6.15](./6.15.png)

图6.15 用OpenGL渲染的`CAEAGLLayer`图层

在一个真正的OpenGL应用中，我们可能会用`NSTimer`或`CADisplayLink`周期性地每秒钟调用`-drawRrame`方法60次，同时会将几何图形生成和绘制分开以便不会每次都重新生成三角形的顶点（这样也可以让我们绘制其他的一些东西而不是一个三角形而已），不过上面这个例子已经足够演示了绘图原则了。

## AVPlayerLayer

最后一个图层类型是`AVPlayerLayer`。尽管它不是Core Animation框架的一部分（AV前缀看上去像），`AVPlayerLayer`是有别的框架（AVFoundation）提供的，它和Core Animation紧密地结合在一起，提供了一个`CALayer`子类来显示自定义的内容类型。

`AVPlayerLayer`是用来在iOS上播放视频的。他是高级接口例如`MPMoivePlayer`的底层实现，提供了显示视频的底层控制。`AVPlayerLayer`的使用相当简单：你可以用`+playerLayerWithPlayer:`方法创建一个已经绑定了视频播放器的图层，或者你可以先创建一个图层，然后用`player`属性绑定一个`AVPlayer`实例。

在我们开始之前，我们需要添加AVFoundation到我们的项目中。然后，清单6.15创建了一个简单的电影播放器，图6.16是代码运行结果。

清单6.15 用`AVPlayerLayer`播放视频

```objective-c
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *containerView; @end

@implementation ViewController

- (void)viewDidLoad
{
[super viewDidLoad];
//get video URL
NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Ship" withExtension:@"mp4"];

//create player and player layer
AVPlayer *player = [AVPlayer playerWithURL:URL];
AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];

//set player layer frame and attach it to our view
playerLayer.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:playerLayer];

//play the video
[player play];
}
@end
```

![](./6.16.png)

图6.16 用`AVPlayerLayer`图层播放视频的截图

我们用代码创建了一个`AVPlayerLayer`，但是我们仍然把它添加到了一个容器视图中，而不是直接在controller中的主视图上添加。这样其实是为了可以使用自动布局限制使得图层在最中间；否则，一旦设备被旋转了我们就要手动重新放置位置，因为Core Animation并不支持自动大小和自动布局（见第三章『图层几何学』）。

当然，因为`AVPlayerLayer`是`CALayer`的子类，它继承了父类的所有特性。我们并不会受限于要在一个矩形中播放视频；清单6.16演示了在3D，圆角，有色边框，蒙板，阴影等效果（见图6.17）.

清单6.16 给视频增加变换，边框和圆角

```objective-c
- (void)viewDidLoad
{
...
//set player layer frame and attach it to our view
playerLayer.frame = self.containerView.bounds;
[self.containerView.layer addSublayer:playerLayer];

//transform layer
CATransform3D transform = CATransform3DIdentity;
transform.m34 = -1.0 / 500.0;
transform = CATransform3DRotate(transform, M_PI_4, 1, 1, 0);
playerLayer.transform = transform;
￼
//add rounded corners and border
playerLayer.masksToBounds = YES;
playerLayer.cornerRadius = 20.0;
playerLayer.borderColor = [UIColor redColor].CGColor;
playerLayer.borderWidth = 5.0;

//play the video
[player play];
}
```

![](./6.17.png)

图6.17 3D视角下的边框和圆角`AVPlayerLayer`

## 总结

这一章我们简要概述了一些专用图层以及用他们实现的一些效果，我们只是了解到这些图层的皮毛，像`CATiledLayer`和`CAEMitterLayer`这些类可以单独写一章的。但是，重点是记住`CALayer`是用处很大的，而且它并没有为所有可能的场景进行优化。为了获得Core Animation最好的性能，你需要为你的工作选对正确的工具，希望你能够挖掘这些不同的`CALayer`子类的功能。
这一章我们通过`CAEmitterLayer`和`AVPlayerLayer`类简单地接触到了一些动画，在第二章，我们将继续深入研究动画，就从隐式动画开始。



