//
//  OWTDefaultTableViewCell.m
//  Weitu
//
//  Created by denghs on 15/10/9.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTDefaultTableViewCell.h"


@implementation OWTDefaultTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    //[self creat];
    return self;
}

- (void)creat{
    if (m_checkImageView == nil)
    {
        m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unselected.png"]];
        m_checkImageView.frame = CGRectMake(265, 10, 29, 29);
        [self addSubview:m_checkImageView];
    }
}

- (void)setChecked:(BOOL)checked{
    if (checked)
    {
        m_checkImageView.image = [UIImage imageNamed:@"Selected.png"];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
    else
    {
        m_checkImageView.image = [UIImage imageNamed:@"Unselected.png"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    m_checked = checked;
}

- (void)setCheckImageViewHidden:(BOOL)status
{
    [m_checkImageView setHidden:status];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
