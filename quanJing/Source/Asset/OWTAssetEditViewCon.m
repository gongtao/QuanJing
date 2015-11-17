//
//  OWTAssetEditViewCon.m
//  Weitu
//
//  Created by Su on 6/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetEditViewCon.h"
#import "OWTAsset.h"
#import "OWTAssetManager.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserManager.h"
#import "OWTAlbum.h"

#import "OWTPhotoUploadDesCell.h"
#import "OWTPhotoUploadCustomCell.h"
#import "OWTPhotoUploadTagView.h"

#import <UIColor+HexString.h>
#import <RETableViewManager/RETableViewManager.h>
#import <SIAlertView/SIAlertView.h>
#import <SDWebImage/SDWebImageManager.h>
#import "SVProgressHUD+WTError.h"
#import "UIImage+Resize.h"
#import "OWTAlbumInfoEditViewCon.h"
#import "QuanJingSDK.h"
#define kPhotoUploadNavBarColor                 [UIColor colorWithHexString:@"#2b2b2b"]
#define kPhotoUploadNavButtonHighlightedColor   [UIColor colorWithHexString:@"#fb0c09"]
#define kPhotoUploadVCBackgroundColor           [UIColor colorWithHexString:@"#f2f4f5"]

@interface OWTAssetEditViewCon () <OWTPhotoUploadTagViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate> {
    BOOL _isPrivate;
    NSString *_caption;
    NSString *_keywords;
    NSString *_locationString;
    
    CGFloat _tagHeight;
    
    dispatch_queue_t _workingQueue;
    
    NSMutableSet *_belongingAlbums;
    
    UITapGestureRecognizer *_tapGesture;
    NSURLConnection *_connection;
    NSMutableData *_data;
}

@property (nonatomic, strong) QJImageObject* asset;
@property (nonatomic, assign) BOOL deletionAllowed;

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) OWTPhotoUploadDesCell *addDesCell;
@property (nonatomic, strong) UITableViewCell *tagsCell;
@property (nonatomic, strong) OWTPhotoUploadTagView *uploadTagView;
@property (nonatomic, strong) UITableViewCell *deleteCell;

@end

@implementation OWTAssetEditViewCon

- (id)initWithAsset:(QJImageObject*)asset deletionAllowed:(BOOL)deletionAllowed
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _deletionAllowed = deletionAllowed;
        _data=[[NSMutableData alloc]init];
        [self setupWithAsset:asset];
    }
    return self;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupInterface];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.barTintColor =[UIColor blackColor];
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setupInterface {
    self.title = @"编辑图片";
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kPhotoUploadVCBackgroundColor;
    
    CGRect btnRect = CGRectMake(0.0, 0.0, 32.0, 32.0);
    // 取消按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:btnRect];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:kPhotoUploadNavButtonHighlightedColor forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    // 完成按钮
    UIButton *rightButton = [[UIButton alloc] initWithFrame:btnRect];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:kPhotoUploadNavButtonHighlightedColor forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)setupWithAsset:(QJImageObject*)asset
{
    _asset = asset;
    
    if (!_addDesCell) {
        _addDesCell = [[OWTPhotoUploadDesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addDesCell.textView.delegate = self;
    }
    
    if (!_uploadTagView) {
        _uploadTagView = [[OWTPhotoUploadTagView alloc] initWithFrame:CGRectZero];
        _uploadTagView.textField.delegate = self;
        _uploadTagView.delegate = self;
    }
    
    __weak __typeof(self) weakSelf = self;
    _caption=_asset.captionCn;
    _locationString=_asset.position;
    _keywords=_asset.tag;
    _isPrivate=_asset.open.boolValue;
    _addDesCell.textView.text=_caption;
    _uploadTagView.tagStr = _keywords;
    [self textViewDidChange:_addDesCell.textView];
    [self.tableView reloadData];
}


#pragma mark - Action

- (void)tap {
    [self.view endEditing:YES];
}

- (void)cancel
{
    if (_doneAction != nil)
    {
        _doneAction(nWTDoneTypeCancelled);
    }
}

- (void)save
{
    [self.view endEditing:YES];
    
    [SVProgressHUD showWithStatus:@"正在修改图片"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error = [[QJInterfaceManager sharedManager] requestImageModify:_asset.imageId
                                                                           title:_caption
                                                                             tag:_keywords
                                                                        position:_locationString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"修改失败"];
            }
            else {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            }
            
            if (_doneAction != nil)
            {
                _doneAction(nWTDoneTypeUpdated);
            }
        });
    });
}

- (void)delete {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示"
                                                 message:@"确定要删除这张照片吗？"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0: {
            cell = _addDesCell;
            break;
        }
            
        case 2: {
            if (!_tagsCell) {
                _tagsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                _tagsCell.backgroundColor = [UIColor clearColor];
                _tagsCell.contentView.backgroundColor = [UIColor clearColor];
                [_tagsCell.contentView addSubview:_uploadTagView];
            }
            // 标签界面
            CGRect frame = CGRectMake(0.0, 10.0, self.view.bounds.size.width, 0.0);
            _tagHeight = [OWTPhotoUploadTagView heightFromTagString:_keywords width:frame.size.width - 20.0 font:[UIFont systemFontOfSize:13.0]];
            frame.size.height = _tagHeight;
            _uploadTagView.frame = frame;
            [_uploadTagView updateTagButtons];
            cell = _tagsCell;
            break;
        }
            
        case 3: {
            if (!_deleteCell) {
                _deleteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                _deleteCell.backgroundColor = [UIColor clearColor];
                _deleteCell.contentView.backgroundColor = [UIColor clearColor];
                
                _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.bounds.size.width, 44.0)];
                [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
                [_deleteButton setTitleColor:kPhotoUploadNavButtonHighlightedColor forState:UIControlStateNormal];
                _deleteButton.backgroundColor = [UIColor whiteColor];
                [_deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
                [_deleteCell.contentView addSubview:_deleteButton];
            }
            cell = _deleteCell;
            break;
        }
            
        default: {
            static NSString *identifier = @"OWTPhotoUploadCell";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[OWTPhotoUploadCustomCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:identifier];
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            }
            OWTPhotoUploadCustomCell *customCell = (OWTPhotoUploadCustomCell *)cell;
            customCell.upLineView.hidden = YES;
            customCell.customSwitch.hidden = YES;
            if (indexPath.row == 1) {
                if (![_locationString isEqualToString:@"(null)"]) {
                cell.textLabel.text = _locationString;
                }
                cell.imageView.image = [UIImage imageNamed:@"上传图片位置icon.png"];
                customCell.upLineView.hidden = NO;
            }
            else if (indexPath.row == 3) {
                cell.textLabel.text = @"私有照片";
                cell.imageView.image = [UIImage imageNamed:@"上传图片私有照片icon.png"];
                // 开关
                customCell.accessoryView = customCell.customSwitch;
                customCell.customSwitch.hidden = NO;
                [customCell.customSwitch setOn:!_isPrivate animated:NO];
                [customCell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                    _isPrivate = isOn;
                }];
            }
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    switch (indexPath.row) {
        case 0: {
            height = 70.0;
            break;
        }
            
        case 2: {
            CGRect frame = CGRectMake(0.0, 10.0, self.view.bounds.size.width, 0.0);
            _tagHeight = [OWTPhotoUploadTagView heightFromTagString:_keywords width:frame.size.width - 20.0 font:[UIFont systemFontOfSize:13.0]];
            height = _tagHeight + 20.0;
            break;
        }
            
        case 4: {
            height = 54.0;
            break;
        }
            
        default: {
            height = 44.0;
            break;
        }
    }
    return height;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:_tapGesture];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.view removeGestureRecognizer:_tapGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_uploadTagView addTagStr:textField.text];
    textField.text = nil;
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        // 显示placeholder
        _addDesCell.placeHolderLabel.hidden = (_addDesCell.textView.text && _addDesCell.textView.text.length > 0);
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self.view addGestureRecognizer:_tapGesture];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        [self.view removeGestureRecognizer:_tapGesture];
    }
}

#pragma mark - OWTPhotoUploadTagViewDelegate

- (void)didTagsValueChanged:(NSString *)tag {
    _keywords = tag;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"确定"]) {
        [SVProgressHUD showSuccessWithStatus:@"正在删除图片"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * error = [[QJInterfaceManager sharedManager] requestImageDelete:_asset.imageId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [SVProgressHUD showErrorWithStatus:@"删除失败"];
                }
                else {
                    [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                }
                
                if (_doneAction != nil) {
                    _doneAction(nWTDoneTypeDeleted);
                }
            });
        });
    }
    
}

@end
