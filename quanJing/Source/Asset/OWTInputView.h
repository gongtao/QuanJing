//
//  OWTInputView.h
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EAMTextView/EAMTextView.h>

@interface OWTInputView : UIToolbar<EAMTextViewDelegate>

@property (nonatomic, strong) IBOutlet EAMTextView* textView;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, strong) void (^sendAction)();

@end
