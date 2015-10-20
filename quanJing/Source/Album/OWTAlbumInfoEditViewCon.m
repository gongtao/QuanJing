//
//  OWTAlbumInfoEditViewCon.m
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAlbumInfoEditViewCon.h"
#import "UIViewController+WTExt.h"
#import "OWTAlbum.h"
#import "OWTUserManager.h"
#import "SVProgressHUD+WTError.h"
#import <RETableViewManager/RETableViewManager.h>
#import <SIAlertView/SIAlertView.h>

@interface OWTAlbumInfoEditViewCon ()
{
    OWTAlbum* _album;
    
    RETableViewManager* _tableViewManager;
    
    RETableViewSection* _nameInputSection;
    RETextItem* _nameInputItem;

    RETableViewSection* _descriptionInputSection;
    RELongTextItem* _descriptionInputItem;

    RETableViewSection* _categoryInputSection;
    RETableViewItem* _categorySelectItem;
    
    RETableViewSection* _deleteSection;
    RETableViewItem* _deleteItem;
}

@property (nonatomic, assign) BOOL isEditingAlbum;

@end

@implementation OWTAlbumInfoEditViewCon

- (id)initForCreation
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [self setupForCreation];
    }
    return self;
}

- (id)initForEditingAlbum:(OWTAlbum*)album
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [self setupForEditingAlbum:album];
    }
    return self;
}

- (void)setupForCreation
{
    _isEditingAlbum = NO;

    self.title = @"创建相册";

//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text =@"创建相册";
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
//
    
    [self setupCancelButton];

    UIBarButtonItem* doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(create)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;

    _tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    [self setupNameInputSection];
    [self setupDescriptionInputSection];
}

- (void)setupForEditingAlbum:(OWTAlbum*)album
{
    _album = album;
    _isEditingAlbum = YES;

    self.title = @"编辑相册";
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text =@"编辑相册";
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
    
    [self setupCancelButton];

    UIBarButtonItem* doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(save)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;

    _tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    [self setupNameInputSection];
    [self setupDescriptionInputSection];
    [self setupDeleteSection];

    _nameInputItem.value = album.albumName;
    _descriptionInputItem.value = album.albumDescription;
}

- (void)setupCancelButton
{
    UIBarButtonItem* cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

- (void)setupNameInputSection
{
    _nameInputSection = [[RETableViewSection alloc] initWithHeaderTitle:@"名称"];
    _nameInputItem = [[RETextItem alloc] initWithTitle:nil value:@"" placeholder:@"请输入相册名称"];
    _nameInputItem.cellHeight = 36;
    _nameInputItem.charactersLimit = 16;
    [_nameInputSection addItem:_nameInputItem];
    [_tableViewManager addSection:_nameInputSection];
}

- (void)setupDescriptionInputSection
{
    _descriptionInputSection = [[RETableViewSection alloc] initWithHeaderTitle:@"简介"];
    _descriptionInputItem = [[RELongTextItem alloc] initWithValue:@"" placeholder:@"请输入相册简介"];
    _descriptionInputItem.cellHeight = 132;
    _descriptionInputItem.charactersLimit = 160;
    [_descriptionInputSection addItem:_descriptionInputItem];
    [_tableViewManager addSection:_descriptionInputSection];
}

- (void)setupDeleteSection
{
    _deleteSection = [RETableViewSection section];
    _deleteItem = [RETableViewItem itemWithTitle:@"删除相册"
                                   accessoryType:UITableViewCellAccessoryNone
                                selectionHandler:^(RETableViewItem *item) {
                                    
                                    [item deselectRowAnimated:YES];

                                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"请确认"
                                                                                     andMessage:@"确认删除相册吗？"];

                                    [alertView addButtonWithTitle:@"确定"
                                                             type:SIAlertViewButtonTypeDestructive
                                                          handler:^(SIAlertView *alert) {
                                                              [self delete];
                                                          }];

                                    [alertView addButtonWithTitle:@"取消"
                                                             type:SIAlertViewButtonTypeCancel
                                                          handler:^(SIAlertView *alert) {
                                                          }];

                                    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                                    
                                    [alertView show];
                                }];
    _deleteItem.textAlignment = NSTextAlignmentCenter;
    [_deleteSection addItem:_deleteItem];
    [_tableViewManager addSection:_deleteSection];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (void)cancel
{
    if (_doneAction != nil)
    {
        _doneAction(nWTDoneTypeCancelled);
    }
}

- (void)create
{
    NSString* albumName = _nameInputItem.value;
    if (albumName == nil || albumName.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入相册名称"];
        return;
    }
    
    NSString* albumDescription = _descriptionInputItem.value;
    if (albumDescription == nil)
    {
        albumDescription = @"";
    }

    OWTUserManager* um = GetUserManager();

    [SVProgressHUD show];
    [um createAlbumWithName:albumName
                description:albumDescription
                 categoryID:@""
                    success:^{
                        [SVProgressHUD dismiss];
                        if (_doneAction != nil)
                        {
                            _doneAction(nWTDoneTypeCreated);
                        }
                    }
                    failure:^(NSError* error) {
                        [SVProgressHUD showError:error];
                    }];
}

- (void)save
{
    NSString* updatedName = _nameInputItem.value;
    if (updatedName == nil || updatedName.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入相册名称"];
        return;
    }

    NSString* updatedDescription = _descriptionInputItem.value;
    if (updatedDescription == nil)
    {
        updatedDescription = @"";
    }

    OWTUserManager* um = GetUserManager();

    [SVProgressHUD show];
    [um modifyAlbumWithID:_album.albumID
              updatedName:updatedName
       updatedDescription:updatedDescription
                  success:^{
                      [SVProgressHUD dismiss];
                      if (_doneAction != nil)
                      {
                          _doneAction(nWTDoneTypeUpdated);
                      }
                  }
                  failure:^(NSError* error) {
                      [SVProgressHUD showError:error];
                  }];
}

- (void)delete
{
    OWTUserManager* um = GetUserManager();

    [SVProgressHUD show];
    [um deleteAlbumWithID:_album.albumID
                  success:^{
                      [SVProgressHUD dismiss];
                      if (_doneAction != nil)
                      {
                          _doneAction(nWTDoneTypeDeleted);
                      }
                  }
                  failure:^(NSError* error) {
                      [SVProgressHUD showError:error];
                  }];

}

@end
