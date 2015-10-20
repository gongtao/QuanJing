#ifdef DEBUG // 处于开发阶段
#define RRLog(...) NSLog(__VA_ARGS__)
#else // 处于发布阶段
#define RRLog(...)
#endif

#ifdef DEBUG // 调试状态, 打开LOG功能
#define RRLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define RRLog(...)
#endif

#define Xwidth self.view.frame.size.width
#define Yheigh self.view.frame.size.height
#define HWColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define HWColorApha(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:0]

//获取设备的物理高宽
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width

// 是否为iOS7
#define iOS7 ([UIDevice currentDevice].systemVersion.doubleValue >= 7.0)
// 是否为4inch
#define FourInch ([UIScreen mainScreen].bounds.size.height == 568.0)

// 随机色
#define IWRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]



#pragma mark - 图片
#ifndef UIIMAGE
#define UIIMAGE(name) [UIImage imageNamed:(name)]
#endif
//定义UIImage对象(ps:建议使用下面宏变量定义图片对象，解决imageNamed方式无法释放内存）
#define YJ_IMAGE(imaegName,imageType) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imaegName ofType:imageType]]
#define YJ_IMAGE_PNG(imaegName)     [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imaegName ofType:@"png"]]
#define YJ_IMAGE_JPG(imaegName)     [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imaegName ofType:@"jpg"]]



#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

#define kRGBColor(R,G,B)    [UIColor colorWithRed:(R / 255.) green:(G / 255.) blue:(B / 255.) alpha:1]
#define kRGBAColor(R,G,B,A) [UIColor colorWithRed:(R / 255.) green:(G / 255.) blue:(B / 255.) alpha:A]

// 颜色
#define RRColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 随机色
#define RRRandomColor RRColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

// 全局背景色
#define RRGlobalBg RRColor(211, 211, 211)

// 是否为iOS7
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// 是否为4inch
#define FourInch ([UIScreen mainScreen].bounds.size.height == 568.0)

// 导航栏标题的字体
#define RRNavigationTitleFont [UIFont boldSystemFontOfSize:20]

// 屏幕尺寸
#define RRScreenW [UIScreen mainScreen].bounds.size.width

// cell的计算参数
// cell之间的间距
#define RRStatusCellMargin 10

// cell的内边距
#define RRStatusCellInset 10
#pragma mark - 系统版本号判断


//系统版本号判断
//大于等于 8.0
#define IOS8_OR_LATER	([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)

//大于等于 7.0
#define IOS7_OR_LATER	([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)

//大于等于 6.0
#define IOS6_OR_LATER	([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)

//大于等于 5.0
#define IOS5_OR_LATER	([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)

#pragma mark - 判断设备
//iphone5
#define IS_IPHONE5 ([UIScreen mainScreen].bounds.size.height == 568)
//iphone4
#define IS_IPHONE4 ([UIScreen mainScreen].bounds.size.height == 480)

//5.3加
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
