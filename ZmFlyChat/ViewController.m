//
//  ViewController.m
//  ZmFlyChat
//
//  Created by beepay on 2019/5/23.
//  Copyright © 2019 XG. All rights reserved.
//

#import "ViewController.h"
#import <Accelerate/Accelerate.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ViewController{
    CGFloat image_w;
    CGFloat image_h;
    CGFloat screen_w;
    CGFloat screen_h;
    UIImage *newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    newImage = [self blurryImage:[UIImage imageNamed:@"timg.jpeg"] withBlurLevel:0.4];
    image_w = newImage.size.width;
    image_h = newImage.size.height;
    screen_w = CGRectGetWidth(self.view.frame);
    
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200);
    headerView.image = newImage;
    headerView.contentMode = UIViewContentModeBottom;
    self.tableView.tableHeaderView = headerView;
    
    CGRect copyRect = CGRectMake((image_w-screen_w)/2 , image_h-200-64, screen_w, 64);
    UIImage *barImage = [self cutImage:copyRect];
    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:(UIBarMetricsDefault)];
    // Do any additional setup after loading the view, typically from a nib.
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"111";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat off_y = scrollView.contentOffset.y;
    if(off_y > 200){
        CGRect copyRect = CGRectMake((image_w-screen_w)/2 , image_h-200-64+200, screen_w, 64);
        UIImage *barImage = [self cutImage:copyRect];
        [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:(UIBarMetricsDefault)];
    }
    else{
        CGRect copyRect = CGRectMake((image_w-screen_w)/2 , image_h-200-64+off_y, screen_w, 64);
        UIImage *barImage = [self cutImage:copyRect];
        [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:(UIBarMetricsDefault)];
    }
    
}


-(UIImage *)cutImage:(CGRect)cropRect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], cropRect);
    UIImage * copyImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return copyImage;
}


- (UIImage *)coreBlueImage:(UIImage *)image {
    //创建输入CIImage对象
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    //创建滤镜(可以更换不同的滤镜,滤镜名称可以从以上代码获取
    CIFilter *filter = [CIFilter filterWithName:@"CIBoxBlur"];
    //设置滤镜属性值为默认值
    [filter setDefaults];
    
    [filter setValue:[NSNumber numberWithFloat:15] forKey:@"inputRadius"];
    
    //设置输入图像
    [filter setValue:inputImage forKey:kCIInputImageKey];
    //获取输出图像
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //创建CIContex上下文对象
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage: result fromRect:[result extent]];
    UIImage *blurImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
    
}


-(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (blur <0.f || blur > 1.f)
    {
        blur = 0.5f;
    }
    //判断曝光度
    int boxSize = (int)(blur * 100);//放大100 小数点后面2位有效
    boxSize = boxSize - (boxSize % 2) + 1;//如果是偶数 变奇数
    CGImageRef img = image.CGImage;//获取图片指针
    vImage_Buffer inBuffer,outBuffer;//获取缓冲区
    vImage_Error error;//一个错误类，调用画图函数的时候调用
    void *pixelBuffer;
    CGDataProviderRef inprovider = CGImageGetDataProvider(img);//放回一个数组图片
    CFDataRef inbitmapData = CGDataProviderCopyData(inprovider);//拷贝数据
    inBuffer.width = CGImageGetWidth(img);//放回位图的宽度
    inBuffer.height = CGImageGetHeight(img);//放回位图的高度
    
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);//算出位图的字节
    
    inBuffer.data = (void*)CFDataGetBytePtr(inbitmapData);//填写图片信息
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));//创建一个空间
    
    if (pixelBuffer == NULL)
    {
        NSLog(@"NO Pixelbuffer");
    }
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error)
    {
        NSLog(@"%zd",error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inbitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}



@end
