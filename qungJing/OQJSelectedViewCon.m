//
//  OQJSelectedViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJSelectedViewCon.h"
#import "OWTFeedViewCon.h"
#import "OWTFeedManager.h"
#import "OWTSearchViewCon.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import <QBFlatButton/QBFlatButton.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <AppleGrocery/UIKitExt/OLineView.h>


#import "UISearchBar+Blocks.h"

#import "OWTSearchManager.h"

#import "OWTSearchResultsViewCon.h"


#import "OWTActivitiesViewCon.h"

#import "OWTSocialAddViewCon.h"
#import <NBUImagePicker/NBUImagePicker.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import "WYPopoverController.h"
#import "OWTFont.h"

#import "OWTPhotoUploadInfoViewCon.h"
#import "OWTSMSInviteViewCon.h"
#import "OWTImageInfo.h"

#import "OWTPhotoUploadInfoViewCon.h"
#import <NBUImagePicker/NBUImagePicker.h>
typedef enum
{
    kQJSelectedWorkingModeLatest,
    kQJSelectedWorkingModeHottest,
} EQJSelectedImageWorkingMode;

@interface OQJSelectedViewCon ()
{
        
    OWTActivitiesViewCon* _activitiesViewCon;
    NSArray* seArr;
    WYPopoverController* _popoverViewCon;
}
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) NSString* keyword;
@end

@implementation OQJSelectedViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    
    
    [self setupNavBar];
    [self setupAddButton];
   
    
}
- (void)setupAddButton
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemAdd withBlock:^(UIBarButtonItem* sender) {
//        [self socialAddAction];
        
        
        //直接进入 图片发布页
        
        //上传图片页面
        [self uploadPhotosWithFilteredGroupNames:[NSSet setWithObject:@"全景"]];
        
    }];
    

}



- (void)setupPopoverMenu
{
//    [WYPopoverController setDefaultTheme:[WYPopoverTheme theme]];
//    
//    WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];
//    
//    [popoverAppearance setOuterCornerRadius:4];
//    [popoverAppearance setOuterShadowBlurRadius:0];
//    [popoverAppearance setOuterShadowColor:[UIColor clearColor]];
//    [popoverAppearance setOuterShadowOffset:CGSizeMake(0, 0)];
//    
//    [popoverAppearance setGlossShadowColor:[UIColor clearColor]];
//    [popoverAppearance setGlossShadowOffset:CGSizeMake(0, 0)];
//    
//    [popoverAppearance setBorderWidth:4];
//    [popoverAppearance setArrowHeight:10];
//    [popoverAppearance setArrowBase:16];
//    
//    [popoverAppearance setInnerCornerRadius:4];
//    [popoverAppearance setInnerShadowBlurRadius:0];
//    [popoverAppearance setInnerShadowColor:[UIColor clearColor]];
//    [popoverAppearance setInnerShadowOffset:CGSizeMake(0, 0)];
//    
//    //    UIColor* popoverColor = GetThemer().themeColor;
//    UIColor* popoverColor = GetThemer().themeTintColor;//view的颜色
//    //    UIColor* popoverColor = GetThemer().themeTintColor;
//    
//    [popoverAppearance setFillTopColor:popoverColor];
//    [popoverAppearance setFillBottomColor:popoverColor];
//    [popoverAppearance setOuterStrokeColor:popoverColor];
//    [popoverAppearance setInnerStrokeColor:popoverColor];
    
    OWTSocialAddViewCon* addViewCon = [[OWTSocialAddViewCon alloc] initWithNibName:nil bundle:nil];
    _popoverViewCon = [[WYPopoverController alloc] initWithContentViewController:addViewCon];
    addViewCon.uploadAction = ^{
        [_popoverViewCon dismissPopoverAnimated:NO];
        [self uploadPhotosWithFilteredGroupNames:nil];
    };
    
    addViewCon.captureAction = ^{
        [_popoverViewCon dismissPopoverAnimated:NO];
        
        OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
        [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
        
        NBUImagePickerResultBlock resultBlock = ^(NSArray* images)
        {
            if (images == nil || images.count == 0)
            {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            else
            {
                [photoUploadInfoViewCon setPendingUploadImages:images];
                photoUploadInfoViewCon.doneAction = ^{
                };
            }
        };
        
        NBUImagePickerOptions options = NBUImagePickerOptionSingleImage |
        NBUImagePickerOptionReturnImages |
        NBUImagePickerOptionStartWithCamera |
        NBUImagePickerOptionDisableEdition |
        NBUImagePickerOptionDisableLibrary |
        NBUImagePickerOptionDoNotSaveImages;
        
        [NBUImagePickerController startPickerWithTarget:self
                                                options:options
                                       customStoryboard:nil
                                            resultBlock:resultBlock];
    };
    
    addViewCon.inviteFriendsAction = ^{
        [_popoverViewCon dismissPopoverAnimated:NO];
        OWTSMSInviteViewCon* inviteViewCon = [[OWTSMSInviteViewCon alloc] init];
        inviteViewCon.failFunc = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:inviteViewCon
                                             animated:YES];
    };
    
    _popoverViewCon.popoverContentSize = CGSizeMake(100, 108);
    _popoverViewCon.delegate = self;
}

- (void)uploadPhotosWithFilteredGroupNames:(NSSet*)filteredGroupNames
{
    OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
    [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
    
    
    
    NBUImagePickerResultBlock resultBlock = ^(NSArray* mediaInfos)
    {
        
        if (mediaInfos == nil || mediaInfos.count == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
            
            return;
        }
        else
        {
            NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:mediaInfos.count];
            for (NBUMediaInfo* mediaInfo in mediaInfos)
            {
                NSURL* url = mediaInfo.attributes[NBUMediaInfoOriginalMediaURLKey];
                OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
                imageInfo.url = [url absoluteString];
                imageInfo.primaryColorHex = @"DDDDDD";
                imageInfo.width = 64;
                imageInfo.height = 64;
                [imageInfos addObject:imageInfo];
            }
            [photoUploadInfoViewCon setPendingUploadImageInfos:imageInfos];
            photoUploadInfoViewCon.doneAction = ^{
            };
        }
    };
    
    NBUImagePickerOptions options = NBUImagePickerOptionMultipleImages |
    NBUImagePickerOptionReturnMediaInfo |
    NBUImagePickerOptionStartWithLibrary |
    NBUImagePickerOptionDisableEdition |
    NBUImagePickerOptionDisableCamera |
    NBUImagePickerOptionDisableConfirmation;
    
    NBUImagePickerController* viewCon = [NBUImagePickerController startPickerWithTarget:self
                                                                                options:options
                                                                       customStoryboard:nil
                                                                            resultBlock:resultBlock];
    
    
    viewCon.assetsGroupController.selectionCountLimit = 9;
    viewCon.libraryController.filteredGroupNames = filteredGroupNames;
    
//    [[NBUALAssetsGroup alloc] initWithALAssetsGroup:ALAssetsGroup];
//    [self.navigationController pushViewController:_assetsGroupController
//                                         animated:YES];

}

- (void)socialAddAction
{
    [_popoverViewCon presentPopoverFromRect:CGRectMake(260, 0, 44, 44)
                                     inView:self.navigationController.navigationBar
                   permittedArrowDirections:WYPopoverArrowDirectionUp
                                   animated:YES];
}



-(void)viewwillAppear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
- (void)setupNavBar
{
    
//        UIImage* tabBarIconImage = [[OWTFont chatBubbleIconWithSize:32] imageWithSize:CGSizeMake(32, 32)];
//        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:tabBarIconImage selectedImage:nil];
    self.title = @"圈子";
    _activitiesViewCon = [[OWTActivitiesViewCon alloc] initWithDefaultStyle];
    _activitiesViewCon.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);//UIEdgeInsetsMake    第二个是往左移动
    _activitiesViewCon.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:_activitiesViewCon.view];
    [self addChildViewController:_activitiesViewCon];
    [_activitiesViewCon manualRefresh];
    
}


- (void)setupSearchBarActions
{
    __weak OQJSelectedViewCon* wself = self;
    _searchBar.tintColor = GetThemer().themeColor;
    
    [_searchBar setSearchBarCancelButtonClickedBlock:^(UISearchBar* searchBar) {
        [wself.searchBar resignFirstResponder];
    }];
    
    [_searchBar setSearchBarSearchButtonClickedBlock:^(UISearchBar* searchBar) {
        [wself performSearch];
    }];
    for (UIView *obj in self.view.subviews)
    {if ([obj isKindOfClass:[UISearchBar class]])
    {
        
    }
    else
    {
        obj.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap =
        
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whenClickImage)];
        
        [obj addGestureRecognizer:singleTap];
        
        
    }
    }
   
}


-(void)whenClickImage
{
    [_searchBar resignFirstResponder];
    
}
-(void)btnclick:(UIButton*)button
{
    
    NSLog(@"aaaaaaaaa%d",button.tag);
    _searchBar.text =seArr[button.tag];
   // NSLog(@"搜索栏的文字： %@", _searchBar.text);
    [self performSearch];
    _searchBar.text=@"";
    [_searchBar resignFirstResponder];
    
}

- (void)performSearch
{
    NSString* keyword = _searchBar.text;
    if (keyword == nil || keyword.length == 0)
    {
        [_searchBar resignFirstResponder];
        
        return;
    }
    
    
    
    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    //
    [searchResultsViewCon setKeyword:keyword ];
    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    
}

@end
