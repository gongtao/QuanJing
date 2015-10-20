#import <UIKit/UIKit.h>

@interface UIButton (Grocery)

+ (id)buttonWithImage:(UIImage*)image;
+ (id)buttonWithImageNamed:(NSString*)imageName;

+ (id)buttonWithFrame:(CGRect)frame;
+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title;
+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage;
+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage highlightedBackgroundImage:(UIImage*)highlightedBackgroundImage;
+ (id)buttonWithFrame:(CGRect)frame image:(UIImage*)image;
+ (id)buttonWithFrame:(CGRect)frame image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;

@end
