//
//  OWTCommentsViewCon.m
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCommentsViewCon.h"
#import "OWTAsset.h"
#import "OWTCommentCell.h"
#import "OWTServerError.h"
#import "UIViewController+WTExt.h"
#import "OWTInputView.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserViewCon.h"
#import "OWTUserManager.h"
#import <EAMTextView/EAMTextView.h>
#import "AlbumPhotosListView1.h"
#import "NetStatusMonitor.h"
#define COMMENT_INPUTVIEW_OFFSET_FOR_KEYBOARD 0

@interface OWTCommentsViewCon ()
{
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet OWTInputView* inputView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* containerViewBottomConstraint;

@end

@implementation OWTCommentsViewCon

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
    self.navigationItem.title = @"评论";
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text =@"评  论";
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setupInputView];

    UIBarButtonItem* barBackItem = [self createCircleBackBarButtonItemWithTarget:self
                                                                          action:@selector(dismiss)];
    [self.navigationItem setLeftBarButtonItem:barBackItem animated:NO];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [_inputView.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshComments];
}

- (void)setupTableView
{
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.rowHeight = 48;
    _tableView.allowsSelection = NO;

    [_tableView registerNib:[UINib nibWithNibName:@"OWTCommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
}

- (void)setupInputView
{
    __weak OWTCommentsViewCon* wself = self;
    _inputView.sendAction = ^{
        [wself postComment:wself.inputView.text
                   success:^{
                       wself.inputView.text = @"";
                       [wself.inputView endEditing:YES];
                   }
                   failure:^{
                       
                   }];
    };
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillAppear:(NSNotification *)note
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerViewBottomConstraint.constant = -[[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height - COMMENT_INPUTVIEW_OFFSET_FOR_KEYBOARD;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerViewBottomConstraint.constant = -COMMENT_INPUTVIEW_OFFSET_FOR_KEYBOARD;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_asset != nil && _asset.comments != nil)
    {
        return _asset.comments.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTCommentCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    OWTComment* comment = _asset.comments[indexPath.row];
    cell.comment = comment;
    cell.showUserAction = ^{
        OWTUser* ownerUser = [GetUserManager() userForID:comment.userID];
       
        if (ownerUser != nil)
        {
            
//            if ([ownerUser.userID isEqualToString:GetUserManager().currentUser.userID ]) {
//                AlbumPhotosListView1 * userViewCon = [[AlbumPhotosListView1 alloc] initWithNibName:nil bundle:nil];
//                [self.navigationController pushViewController:userViewCon animated:YES];
//                
//            }
//            //        userViewCon.user = ownerUser;
//            else
//            {
                OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:userViewCon1 animated:YES];
                userViewCon1.user =ownerUser;
           
//                
//            }
            
        }
    };
    return cell;
}

- (void)refreshComments
{
    if (_asset == nil)
    {
        return;
    }

    [SVProgressHUD showWithStatus:@"刷新评论中..." maskType:SVProgressHUDMaskTypeClear];

    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"assets/%@/comments", _asset.assetID]
       parameters:nil
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
              [o logResponse];

              NSDictionary* resultObjects = result.dictionary;
              OWTServerError* error = resultObjects[@"error"];
              if (error != nil)
              {
                  
                  [SVProgressHUD showServerError:error];
                  return;
              }

              NSArray* commentDatas = resultObjects[@"comments"];
              if (commentDatas == nil)
              {
                  [SVProgressHUD showGeneralError];
                  return;
              }

              _asset.comments = [NSMutableArray arrayWithCapacity:commentDatas.count];
              for (OWTCommentData* commentData in commentDatas)
              {
                  OWTComment* comment = [OWTComment new];
                  [comment mergeWithData:commentData];
                  [_asset.comments addObject:comment];
              }

              [self.tableView reloadData];

              [SVProgressHUD dismiss];
          }
          failure:^(RKObjectRequestOperation* o, NSError* error) {
              [o logResponse];
              if (![NetStatusMonitor isExistenceNetwork]) {
                  [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                  return ;
              }
              [SVProgressHUD showError:error];
          }
     ];
}

- (void)postComment:(NSString*)content
            success:(void (^)())success
            failure:(void (^)())failure
{
    [SVProgressHUD showWithStatus:@"发送评论中..." maskType:SVProgressHUDMaskTypeClear];

    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"assets/%@/comments", _asset.assetID]
        parameters:@{ @"action" : @"addComment",
                      @"content" : content }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];

               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   [SVProgressHUD showServerError:error];

                   if (failure != nil)
                   {
                       failure();
                   }

                   return;
               }
               
               OWTCommentData* commentData = resultObjects[@"comment"];
               if (commentData == nil)
               {
                   [SVProgressHUD showGeneralError];

                   if (failure != nil)
                   {
                       failure();
                   }

                   return;
               }
               
               OWTComment* comment = [OWTComment new];
               [comment mergeWithData:commentData];

               [_asset addComment:comment];

               [self.tableView reloadData];

               [SVProgressHUD dismiss];

               if (success != nil)
               {
                   success();
               }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (![NetStatusMonitor isExistenceNetwork]) {
                   [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
               }else{
                   [SVProgressHUD showError:error];
               }

               if (failure != nil)
               {
                   failure();
               }
           }
     ];
}

@end
