#import "OTextFormCell.h"

@implementation OTextFormCell

@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        // Adding the text field
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.clearsOnBeginEditing = NO;
        textField.textAlignment = NSTextAlignmentRight;
        textField.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:textField];
    }
    return self;
}


#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews
{
    CGRect rect = CGRectMake(self.contentView.bounds.size.width - 5.0, 
                             12.0, 
                             -CellTextFieldWidth, 
                             25.0);
    [textField setFrame:rect];
    CGRect rect2 = CGRectMake(MarginBetweenControls,
                              12.0,
                              self.contentView.bounds.size.width - CellTextFieldWidth - MarginBetweenControls,
                              25.0);
    UILabel *theTextLabel = (UILabel *)[self textLabel];
    [theTextLabel setFrame:rect2];
}

@end