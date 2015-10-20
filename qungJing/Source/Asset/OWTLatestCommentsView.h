//
//  OWTBriefCommentsView.h
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface OWTLatestCommentsView : UIView<TTTAttributedLabelDelegate>

- (void)setComments:(NSArray *)comments commentNum:(NSInteger)commentNum;

@property (nonatomic, strong) void ((^showAllCommentsAction)());

@end
