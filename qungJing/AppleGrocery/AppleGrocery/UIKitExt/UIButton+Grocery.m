#import "UIButton+Grocery.h"

@implementation UIButton (Grocery)

+ (id)buttonWithImage:(UIImage*)image
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];

    if (image != nil)
    {
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateHighlighted];
        button.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    }

	return button;
}

+ (id)buttonWithImageNamed:(NSString*)imageName
{
    UIImage* image = [UIImage imageNamed:imageName];
    return [UIButton buttonWithImage:image];
}

+ (id)buttonWithFrame:(CGRect)frame
{
	return [UIButton buttonWithFrame:frame title:nil];
}

+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title
{
	return [UIButton buttonWithFrame:frame title:title backgroundImage:nil];
}

+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage
{
	return [UIButton buttonWithFrame:frame title:title backgroundImage:backgroundImage highlightedBackgroundImage:nil];
}

+ (id)buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage highlightedBackgroundImage:(UIImage*)highlightedBackgroundImage
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	[button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	[button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
	return button;
}

+ (id)buttonWithFrame:(CGRect)frame image:(UIImage*)image
{
	return [UIButton buttonWithFrame:frame image:image highlightedImage:nil];
}

+ (id)buttonWithFrame:(CGRect)frame image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	[button setImage:image forState:UIControlStateNormal];
	[button setImage:image forState:UIControlStateHighlighted];
	return button;
}

@end
