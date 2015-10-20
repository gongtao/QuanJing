//
//  OWTCaptureViewCon.m
//  Weitu
//
//  Created by Su on 5/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCaptureSourceSelectViewCon.h"
#import "OWTFont.h"
#import "OWTPhotoSourceSelectionView.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTPhotoUploadInfoViewCon.h"
#import "OWTImageInfo.h"
#import <NBUImagePicker/NBUImagePicker.h>

static const NSTimeInterval kWTCaptureAnimationDuration = 0.3;

@interface OWTCaptureSourceSelectViewCon ()
{
}

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView* blurImageView;
@property (nonatomic, strong) UIView* dimView;
@property (nonatomic, strong) OWTPhotoSourceSelectionView* photoSourceSelectionView;
@property (nonatomic, strong) NSLayoutConstraint* selectionViewConstraint;
@property (nonatomic, strong) CIFilter* blurFilter;
@property (nonatomic, strong) CIFilter* cropFilter;
@property (nonatomic, assign) BOOL isInExpandedState;

@end

@implementation OWTCaptureSourceSelectViewCon

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
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _dimView = [[UIView alloc] initWithFrame:CGRectZero];

    UINib* nib = [UINib nibWithNibName:@"OWTPhotoSourceSelectionView" bundle:nil];
    _photoSourceSelectionView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];

    __weak OWTCaptureSourceSelectViewCon* wself = self;
    _photoSourceSelectionView.cameraSelectedAction = ^{ [wself beginCameraCapture]; };
    _photoSourceSelectionView.albumSelectedAction = ^{ [wself beginAlbumUpload]; };

    _isInExpandedState = NO;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_blurImageView];
    _blurImageView.alpha = 0.0;

    [self.view addSubview:_dimView];
    _dimView.backgroundColor = [UIColor blackColor];
    _dimView.opaque = YES;
    _dimView.alpha = 0.0;
    _dimView.hidden = YES;
    [_dimView easyFillSuperview];

    [self.view addSubview:_photoSourceSelectionView];
    _photoSourceSelectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* parameters = @{ @"view" : _photoSourceSelectionView };
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.height = 132" parameters:parameters]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.width = superview.width" parameters:parameters]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.centerX = superview.centerX" parameters:parameters]];

    _selectionViewConstraint = [NSLayoutConstraint constraintWithItem:_photoSourceSelectionView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0];
    [self.view addConstraint:_selectionViewConstraint];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_isInExpandedState)
    {
        [self performEnterAnimation];
    }

    [self.navigationController setNavigationBarHidden:YES  animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setEnterViewShotImage:(UIImage *)enterViewShotImage
{
    CGSize imageSize = enterViewShotImage.size;
    CGRect imageViewRect = CGRectMake(0, 0, imageSize.width, imageSize.height);

    _backgroundImageView.image = enterViewShotImage;
    _backgroundImageView.frame = imageViewRect;

    _blurImageView.image = [self blurImageForImage:enterViewShotImage];
    _blurImageView.frame = imageViewRect;
}

- (void)setExitViewShotImage:(UIImage *)exitViewShotImage
{
    _backgroundImageView.image = exitViewShotImage;
}

- (void)performEnterAnimation
{
    _blurImageView.alpha = 0.0;
    _dimView.hidden = NO;
    _photoSourceSelectionView.hidden = NO;
    _dimView.alpha = 0.0;
    _photoSourceSelectionView.alpha = 0.0;
    [UIView animateWithDuration:kWTCaptureAnimationDuration
                     animations:^{
                         _blurImageView.alpha = 1.0;
                         _dimView.alpha = 0.3;
                         _photoSourceSelectionView.alpha = 1.0;
                     }
                     completion:^(BOOL ignored) {
                         _isInExpandedState = YES;
                     }];
}

- (void)performExitAnimationWithDoneAction:(void (^)())doneAction
{
    _blurImageView.alpha = 1.0;
    _dimView.hidden = NO;
    _photoSourceSelectionView.hidden = NO;
    [UIView animateWithDuration:kWTCaptureAnimationDuration
                     animations:^{
                         _blurImageView.alpha = 0.0;
                         _dimView.alpha = 0.0;
                         _photoSourceSelectionView.alpha = 0.0;
                     }
                     completion:^(BOOL ignored) {
                         _dimView.hidden = YES;
                         _photoSourceSelectionView.hidden = YES;
                         _isInExpandedState = NO;
                         if (doneAction != nil)
                         {
                             doneAction();
                         }
                     }
     ];
}

- (UIImage*)blurImageForImage:(UIImage*)image
{
    if (_blurFilter == nil)
    {
        _blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [_blurFilter setDefaults];
        [_blurFilter setValue:@5.0f forKey:@"inputRadius"];    // set value for blur level
        
        _cropFilter = [CIFilter filterWithName:@"CICrop"];
    }

    CIImage* inputImage = [[CIImage alloc] initWithImage:image];
    [_blurFilter setValue:inputImage forKey:@"inputImage"];
    [_cropFilter setValue:_blurFilter.outputImage forKey:@"inputImage"];
    [_cropFilter setValue:[CIVector vectorWithCGRect:inputImage.extent]
                   forKey:@"inputRectangle"];

    UIImage* endImage = [[UIImage alloc] initWithCIImage:_cropFilter.outputImage scale:image.scale orientation:image.imageOrientation];
    return endImage;
}

- (void)beginCameraCapture
{
    OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
    [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];

    NBUImagePickerResultBlock resultBlock = ^(NSArray* images)
    {
        if (images == nil || images.count == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
            [self exitToLastViewCon];
            return;
        }
        else
        {
            [photoUploadInfoViewCon setPendingUploadImages:images];
            photoUploadInfoViewCon.doneAction = ^{
                [self exitToLastViewCon];
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
}

- (void)beginAlbumUpload
{
    OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
    [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];

    NBUImagePickerResultBlock resultBlock = ^(NSArray* mediaInfos)
    {
        if (mediaInfos == nil || mediaInfos.count == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
            [self exitToLastViewCon];
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
                [self exitToLastViewCon];
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
}

- (void)exitToLastViewCon
{
    if (_exitToLastViewConAction != nil)
    {
        _exitToLastViewConAction();
    }
}

@end
