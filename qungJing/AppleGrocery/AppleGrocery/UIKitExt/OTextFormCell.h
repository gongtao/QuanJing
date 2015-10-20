#import <UIKit/UIKit.h>

#define CellTextFieldWidth 90.0
#define MarginBetweenControls 20.0

@interface OTextFormCell : UITableViewCell
{
    UITextField *textField;
}

@property (nonatomic) UITextField *textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
