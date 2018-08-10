
#import "DrawViewController.h"

@interface DrawViewController () <NSURLSessionDataDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableData *haveReceivedData;

@end

@implementation DrawViewController

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 319, 200)];
        [self.view addSubview:self.imageView];
        self.imageView.center = self.view.center;
    }
    return _imageView;
}

- (NSMutableData *)haveReceivedData {
    if (_haveReceivedData == nil) {
        _haveReceivedData = [NSMutableData data];
    }
    return _haveReceivedData;
}

- (void)add_task {
    
    NSURL *url = [NSURL URLWithString:@"http://c.hiphotos.baidu.com/zhidao/pic/item/7aec54e736d12f2e0bd5528c48c2d5628435680e.jpg"];
    //创建NSURLSession对象，代理方法在self(控制器)执行，代理方法队列传的nil，表示和下载在一个队列里，也就是在子线程中执行。
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    //创建一个dataTask任务
    NSURLSessionDataTask *task = [session dataTaskWithURL:url];
    
    //启动任务
    [task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    //存储已经下载的图片二进制数据。
    [self.haveReceivedData appendData:data];
    
    //总共需要下载的图片数据的大小。
    int64_t totalSize = dataTask.countOfBytesExpectedToReceive;
    
    //创建一个递增的ImageSource，一般传NULL。
    CGImageSourceRef imageSource = CGImageSourceCreateIncremental(NULL);
    
    //使用最新的数据更新递增的ImageSource，第二个参数是已经接收到的Data，第三个参数表示是否已经是最后一个Data了。
    CGImageSourceUpdateData(imageSource, (__bridge CFDataRef)self.haveReceivedData, totalSize == self.haveReceivedData.length);
    
    //通过关联到ImageSource上的Data来创建一个CGImage对象，第一个参数传入更新数据之后的imageSource；第二个参数是图片的索引，一般传0；第三个参数跟创建的时候一样，传NULL就行。
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    
    //释放创建的CGImageSourceRef对象
    CFRelease(imageSource);
    
    //在主线程中更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        //其实可以直接把CGImageRef对象赋值给layer的contents属性，翻开苹果的头文件看就知道，一个UIView之所以能显示内容，就是因为CALayer的原因，而CALayer显示内容的属性就是contents，而contents通常就是CGImageRef。
        self.imageView.layer.contents = (__bridge id _Nullable)(image);
        //        self.imageView.image = [UIImage imageWithCGImage:image];
        
        //释放创建的CGImageRef对象
        CGImageRelease(image);
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 70)];
    myLabel.text = @"Hi,小韩哥!";
    myLabel.font = [UIFont systemFontOfSize:20.0];
    myLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:myLabel];
    
    CGFloat radius = 21.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:myLabel.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shape  = [CAShapeLayer layer];
    shape.lineWidth = 5;
    shape.lineCap = kCALineCapSquare;
    
    // 带边框则两个颜色不要设置成一样即可
    shape.strokeColor = [UIColor redColor].CGColor;
    shape.fillColor = [UIColor yellowColor].CGColor;
    shape.path = path.CGPath;
    
    shape.contents = (__bridge id)[UIImage imageNamed:@"contents.jpg"].CGImage;
    shape.contentsGravity = kCAGravityResizeAspect;
    shape.contentsScale = UIScreen.mainScreen.scale;
//    shape.mask = layer;
    shape.shouldRasterize = true;
    
    
    self.view.layer.affineTransform = CGAffineTransformMakeScale(0.5, 0.5);
    self.view.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_4);
    self.view.layer.affineTransform = CGAffineTransformMakeTranslation(100, 100);
    
//    view.transform <=> layer.affineTransform
    self.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.view.transform = CGAffineTransformMakeRotation(M_PI_4);
    self.view.transform = CGAffineTransformMakeTranslation(100, 100);
    

    
    CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
    transform = CGAffineTransformTranslate(transform, 100, 100);
    transform = CGAffineTransformRotate(transform, M_PI_4);
    self.view.layer.affineTransform = transform;
    
    
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D.m34 = -1.f /500.f;
    transform3D = CATransform3DRotate(transform3D, M_PI_4, 0, 1, 0);
    self.view.layer.transform = transform3D;
    

}


- (void)addBlockOperation {
    //按照顺序
    NSBlockOperation *operation_1 = [NSBlockOperation blockOperationWithBlock:^{

    }];
    NSBlockOperation *operation_2 = [NSBlockOperation blockOperationWithBlock:^{

    }];
    NSBlockOperation *operation_3 = [NSBlockOperation blockOperationWithBlock:^{
        [self request3];
    }];
    //设置依赖
    [operation_2 addDependency:operation_1];
    [operation_3 addDependency:operation_1];
    //创建队列并添加任务
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperations:@[operation_3,operation_2,operation_1] waitUntilFinished:YES];
}


//测试请求
- (void)request {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    }) ;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request3];
    }) ;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面");
    });
}


- (void)request3{
    //创建信号量并设置计数默认为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    //计数加1
    dispatch_semaphore_signal(semaphore);

    //若计数为0则一直等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

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
