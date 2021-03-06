//
//  NBUAssetsLibraryViewController.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/08/17.
//  Copyright (c) 2012-2014 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NBUAssetsLibraryViewController.h"
#import "NBUImagePickerPrivate.h"
#import "NBUAssetsGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUIMAGEPICKER_MODULE
#define NBUIMAGEPICKER_MODULE   NBUIMAGEPICKER_MODULE_ASSETS

@implementation NBUAssetsLibraryViewController
{
    BOOL _shouldUpdateNavigationItemTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customization
    self.scrollView.alwaysBounceVertical = YES;
    
    // Configure object table view
    _objectTableView.nibNameForViews = @"NBUAssetsGroupView";
    
    // Try to load groups asynchronously
    [self loadGroups];
    
    // Should update title?
    _shouldUpdateNavigationItemTitle = !self.navigationItem.titleView && [self.navigationItem.title hasPrefix:@"@@"];
    if (_shouldUpdateNavigationItemTitle)
    {
        self.navigationItem.title = NBULocalizedString(@"NBUImagePickerController LibraryLoadingTitle", @"Loading...");
    }
//    if (_touchCount ==0) {
//        <#statements#>
//    }
}

- (void)loadGroups
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.loading = YES;
                   });
    
    [[NBUAssetsLibrary sharedLibrary] allGroupsWithResultBlock:^(NSArray * groups,
                                                                 NSError * error)
     {
         if (!error)
         {
             if (self.filteredGroupNames != nil)
             {
                 NSMutableArray* filterResultGroups = [NSMutableArray array];
                 for (NBUAssetsGroup* group in groups)
                 {
                     if (![self.filteredGroupNames containsObject:group.name])
                     {
                         [filterResultGroups addObject:group];
                     }
                 }
                 _assetsGroups = filterResultGroups;
             }
             else
             {
                 _assetsGroups = groups;
             }

             NBULogInfo(@"%@ available asset groups", @(_assetsGroups.count));
             
             // Update UI
             if (_shouldUpdateNavigationItemTitle)
             {
                 self.navigationItem.title = (_assetsGroups.count == 1 ?
                                              NBULocalizedString(@"NBUAssetsLibraryViewController Only one album", @"1 album") :
                                              [NSString stringWithFormat:
                                               NBULocalizedString(@"NBUAssetsLibraryViewController Zero or more albums", @"%d albums"),
                                               _assetsGroups.count]);
             }
             _objectTableView.objectArray = _assetsGroups;
             
             // Force ScrollView's sizeToFitContentView
             [self sizeToFitContentView:self];
         }
         else
         {
             NBULogWarn(@"The user has denied access!");
             
             // Update UI
             if (_shouldUpdateNavigationItemTitle)
             {
                 self.navigationItem.title = error.localizedDescription;
             }
             self.accessDeniedView.hidden = NO;
         }
         
         self.loading = NO;
     }];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading; // Enables KVO
	
	if (_loading)
	{
		[_objectTableView setNoContentsViewText:NBULocalizedString(@"NBUAssetsLibraryViewController LoadingLabel", @"Loading albums...")];
	}
	else
	{
		[_objectTableView setNoContentsViewText:NBULocalizedString(@"NBUAssetsLibraryViewController NoAlbumsLabel", @"No albums")];
	}
}

#pragma mark - Show assets group

- (void)assetsGroupViewTapped:(NBUAssetsGroupView *)sender
{
    NBULogVerbose(@"%@ %@", THIS_METHOD, sender);
    
    NBUAssetsGroup * group = sender.assetsGroup;
    if (![group isKindOfClass:[NBUAssetsGroup class]])
        return;
    
    // Custom block?
    if (_groupSelectedBlock)
    {
        _groupSelectedBlock(group);
        return;
    }
    
    // Else just push a our assets controller
    if (!_assetsGroupController)
    {
        _assetsGroupController = [[NBUAssetsGroupViewController alloc] initWithNibName:@"NBUAssetsGroupViewController"
                                                                                bundle:nil];
    }
    _assetsGroupController.assetsGroup = group;
    [self.navigationController pushViewController:_assetsGroupController
                                         animated:YES];
}

@end

