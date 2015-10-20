//
//  OWTDefaultTableViewCell.h
//  Weitu
//
//  Created by denghs on 15/10/9.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTDefaultTableViewCell : UITableViewCell
{
    BOOL			m_checked;
    UIImageView*	m_checkImageView;
}

- (void)setChecked:(BOOL)checked;
- (void)setCheckImageViewHidden:(BOOL)status;
@end
