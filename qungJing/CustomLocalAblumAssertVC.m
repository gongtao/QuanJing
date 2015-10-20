//
//  CustomLocalAblumAssertVC.m
//  Weitu
//
//  Created by denghs on 15/6/12.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "CustomLocalAblumAssertVC.h"
#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"

@interface CustomLocalAblumAssertVC ()
{
    NSMutableArray *_assetsGroups;
    __ag_weak AGImagePickerController *_imagePickerController;
    BOOL ifFistEnter;
    ALAssetsLibrary *_libarary;

}

@end

@interface CustomLocalAblumAssertVC ()

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;

- (void)reloadData;

- (void)cancelAction:(id)sender;

@end

@implementation CustomLocalAblumAssertVC

#pragma mark - Properties

@synthesize imagePickerController = _imagePickerController;

- (NSMutableArray *)assetsGroups
{
    if (_assetsGroups == nil)
    {
        _assetsGroups = [[NSMutableArray alloc] init];
    }
    
    return _assetsGroups;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController
{
    
    self.imagePickerController = imagePickerController;
    self.imagePickerController.shouldShowSavedPhotosOnTop = YES;
    [self assetsGroups];
        
        // avoid deadlock on ios5, delay to handle in viewDidLoad, springox(20140612)
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.f) {
            [self loadAssetsGroups];
        }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Albums", nil, [NSBundle mainBundle], @"Albums", nil);
    
    // avoid deadlock on ios5, delay to handle in viewDidLoad, springox(20140612)
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.f) {
        [self loadAssetsGroups];
    }
    
    // Setup Notifications
    [self registerForNotifications];
    
    // Navigation Bar Items
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
    [self unregisterFromNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - Private 加载本地相册里的照片
- (void)loadAssetsGroups
{
    __ag_weak CustomLocalAblumAssertVC *weakSelf = self;
    
    [self.assetsGroups removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                // filter the value==0, springox(20140502)
                if (group == nil || group.numberOfAssets == 0)
                {
                    return;
                }
                
                @synchronized(weakSelf) {
                    
                    [self.assetsGroups addObject:group];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goPupuseChildView];
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                [self.imagePickerController performSelector:@selector(didFail:) withObject:error];
            };
            _libarary = [[ALAssetsLibrary alloc]init];
            [_libarary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
            
        }
        
    });

}

- (void)cancelAction:(id)sender
{
    [self.imagePickerController performSelector:@selector(didCancelPickingAssets)];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeLibrary:)
                                                 name:ALAssetsLibraryChangedNotification
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self loadAssetsGroups];
}


-(void)goPupuseChildView
{
 
    if (!ifFistEnter) {
        AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithImagePickerController:self.imagePickerController andAssetsGroup:[_assetsGroups firstObject]];
        controller.blockPopRootView = ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        };
        [self.navigationController pushViewController:controller animated:NO];
        ifFistEnter = true;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
