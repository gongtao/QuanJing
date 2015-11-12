//
//  AGIPCAssetsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

#import "AGImagePickerController.h"
#import "AGIPCGridItem.h"

@interface AGIPCAssetsController : UIViewController <UITableViewDataSource, UITableViewDelegate, AGIPCGridItemDelegate>

@property (strong) ALAssetsGroup * assetsGroup;
@property (ag_weak, readonly) NSArray * selectedAssets;
// change strong to weak, springox(20140422)
@property (ag_weak) AGImagePickerController * imagePickerController;

@property (nonatomic, strong) void (^blockPopRootView)();
@property(nonatomic, strong) UITableView * tableView;
- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end
