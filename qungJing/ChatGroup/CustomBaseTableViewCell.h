//
//  CustomBaseTableViewCell.h
//  Weitu
//
//  Created by denghs on 15/5/29.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface CustomBaseTableViewCell : BaseTableViewCell
{
    BOOL			m_checked;
    UIImageView*	m_checkImageView;
}

- (void)setChecked:(BOOL)checked;
- (void)setCheckImageViewHidden:(BOOL)status;
@end
