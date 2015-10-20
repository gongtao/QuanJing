//
//  OWTTextEditViewCon.m
//  Weitu
//
//  Created by Su on 4/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTTextEditViewCon.h"
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>

@interface OWTTextEditViewCon ()
{
    IBOutlet UITextView* _textView;
}

@end

@implementation OWTTextEditViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{

//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithTitle:@"完成"
                                                                                  style:UIBarButtonItemStyleDone
                                                                              withBlock:^(UIBarButtonItem* sender){
                                                                                  if (_doneFunc != nil)
                                                                                  {
                                                                                      _doneFunc();
                                                                                  }
                                                                              }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)setText:(NSString *)text
{
    _textView.text = text;
}

- (NSString*)text
{
    return _textView.text;
}

@end
