//
//  OWTActivityTableViewCell.m
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTActivityTableViewCell.h"
#import "OThumbnailListViewCon.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTActivity.h"
#import "OWTUserManager.h"
#import "OWTAssetManager.h"
#import "OWTImageView.h"
#import "OWTAsset.h"
#import "ORoundRectLineView.h"

@interface OWTActivityTableViewCell()
{
    IBOutlet UIView* _bgShapeView;

    IBOutlet OWTImageView* _avatarView;
    IBOutlet TTTAttributedLabel* _descriptionLabel;
    
    __weak IBOutlet UILabel *relatinLbel;
    IBOutlet OWTImageView* _bigThumbnailView;

    IBOutlet OWTImageView* _thumbnailView0;
    IBOutlet OWTImageView* _thumbnailView1;
    IBOutlet OWTImageView* _thumbnailView2;
    IBOutlet OWTImageView* _thumbnailView3;
    IBOutlet OWTImageView* _thumbnailView4;
    IBOutlet OWTImageView* _thumbnailView5;
    IBOutlet OWTImageView* _thumbnailView6;
    IBOutlet OWTImageView* _thumbnailView7;
    IBOutlet OWTImageView* _thumbnailView8;
    
    NSArray* _thumbnailViews;
    NSMutableDictionary* _thumbnailView2AssetIDs;

    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint0;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint1;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint2;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint3;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint4;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint5;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint6;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint7;
    IBOutlet NSLayoutConstraint* _thumbnailHeightConstraint8;
    
    NSArray* _thumbnailHeightConstraints;

    IBOutlet UILabel* _timestampLabel;

    IBOutlet NSLayoutConstraint* _timestamp2ThumbnailDistanceConstraint;
}

@end

@implementation OWTActivityTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupBackgroundView];
    [self setupDescriptionLabel];
    [self setupAvatarView];
    [self setupThumbnailViews];
}

- (void)setupAvatarView
{
    _avatarView.layer.cornerRadius = 2;
    _avatarView.layer.masksToBounds = YES;

    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarPressed)]];
}

- (void)setupDescriptionLabel
{
    _descriptionLabel.linkAttributes = @{ NSForegroundColorAttributeName: GetThemer().themeColor };
    _descriptionLabel.delegate = self;
}

- (void)setupBackgroundView
{
}

- (void)setupThumbnailViews
{
    [_bigThumbnailView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigThumbnailPressed)]];
    
    _thumbnailViews = @[_thumbnailView0,
                        _thumbnailView1,
                        _thumbnailView2,
                        _thumbnailView3,
                        _thumbnailView4,
                        _thumbnailView5,
                        _thumbnailView6,
                        _thumbnailView7,
                        _thumbnailView8];

    [_thumbnailView0 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed0)]];
    [_thumbnailView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed1)]];
    [_thumbnailView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed2)]];
    [_thumbnailView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed3)]];
    [_thumbnailView4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed4)]];
    [_thumbnailView5 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed5)]];
    [_thumbnailView6 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed6)]];
    [_thumbnailView7 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed7)]];
    [_thumbnailView8 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailPressed8)]];

    _thumbnailView2AssetIDs = [NSMutableDictionary dictionaryWithCapacity:9];

    _thumbnailHeightConstraints = @[_thumbnailHeightConstraint0,
                                    _thumbnailHeightConstraint1,
                                    _thumbnailHeightConstraint2,
                                    _thumbnailHeightConstraint3,
                                    _thumbnailHeightConstraint4,
                                    _thumbnailHeightConstraint5,
                                    _thumbnailHeightConstraint6,
                                    _thumbnailHeightConstraint7,
                                    _thumbnailHeightConstraint8];
}

#pragma mark - 

- (void)avatarPressed
{
    if (_mergedActivity == nil)
    {
        return;
    }

    if (_userClickedAction != nil)
    {
        _userClickedAction(_mergedActivity.userID);
    }
}

- (void)bigThumbnailPressed { [self handleBigThumbnailPressed]; }
- (void)thumbnailPressed0 { [self handleThumbnailPressed:0]; }
- (void)thumbnailPressed1 { [self handleThumbnailPressed:1]; }
- (void)thumbnailPressed2 { [self handleThumbnailPressed:2]; }
- (void)thumbnailPressed3 { [self handleThumbnailPressed:3]; }
- (void)thumbnailPressed4 { [self handleThumbnailPressed:4]; }
- (void)thumbnailPressed5 { [self handleThumbnailPressed:5]; }
- (void)thumbnailPressed6 { [self handleThumbnailPressed:6]; }
- (void)thumbnailPressed7 { [self handleThumbnailPressed:7]; }
- (void)thumbnailPressed8 { [self handleThumbnailPressed:8]; }

- (void)handleBigThumbnailPressed
{
    OWTImageView* thumbnailView = _bigThumbnailView;
    NSString* assetID = [_thumbnailView2AssetIDs objectForKey:[NSValue valueWithPointer:(void*)thumbnailView]];
    if (assetID != nil)
    {
        if (_assetClickedAction != nil)
        {
            _assetClickedAction(assetID);
        }
    }
}

- (void)handleThumbnailPressed:(int)index
{
    OWTImageView* thumbnailView = _thumbnailViews[index];
    NSString* assetID = [_thumbnailView2AssetIDs objectForKey:[NSValue valueWithPointer:(void*)thumbnailView]];
    if (assetID != nil)
    {
        if (_assetClickedAction != nil)
        {
            _assetClickedAction(assetID);
        }
    }
}

#pragma mark -

- (void)setMergedActivity:(OWTMergedActivity *)mergedActivity
{
    _mergedActivity = mergedActivity;
    [self updateUserAvatar];
    [self updaterelationLabel];
    [self updateDescriptionLabel];
    [self updateThumbnailImages];
    [self updateTimestampLabel];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [_bgShapeView setNeedsDisplay];
}
- (void)updaterelationLabel
{
    if (![_mergedActivity.friendsOrFans isEqualToString:@""]) {
        relatinLbel.text =_mergedActivity.friendsOrFans;
    }
    else
    relatinLbel.hidden =YES;
}


- (void)updateUserAvatar
{
    if (_mergedActivity == nil)
    {
        [_avatarView clearImageAnimated:NO];
        return;
    }
    
    OWTUserManager* um = GetUserManager();
    
    OWTUser* originatingUser = [um userForID:_mergedActivity.userID];
    if (originatingUser != nil)
    {
        [_avatarView setImageWithInfoAsThumbnail:originatingUser.avatarImageInfo];
    }
    else
    {
        [_avatarView setImageWithImageAsThumbnail:[UIImage imageNamed:@"default_avatar.jpg"]];
    }
}

- (void)updateDescriptionLabel
{
    if (_mergedActivity == nil)
    {
        _descriptionLabel.text = @"";
        return;
    }
    
    OWTUserManager* um = GetUserManager();

    OWTUser* originatingUser = [um userForID:_mergedActivity.userID];
    NSString* originatingUserName;
    if (originatingUser == nil)
    {
        originatingUserName = @"全景用户";
    }
    else
    {
        originatingUserName = originatingUser.displayName;
    }

    switch (_mergedActivity.activityType)
    {
        case nWTActivityTypeUPLOAD:
        {
            NSUInteger uploadNum = _mergedActivity.subjectAssetIDs.count;
            NSString* description = [NSString stringWithFormat:@"%@上传了%lu张照片", originatingUserName, (unsigned long)uploadNum];

            if (_mergedActivity.subjectAssetIDs.count > 0)
            {
                NSString* assetID = [_mergedActivity.subjectAssetIDs firstObject];
                OWTAsset* firstAsset = [GetAssetManager() getAssetWithID:assetID];

                NSString* caption = firstAsset.caption;
                if (caption != nil && firstAsset.caption.length > 0)
                {
                    description = [NSString stringWithFormat:@"%@\n%@", description, caption];
                }
            }
            _descriptionLabel.text = description;
            NSRange range = NSMakeRange(0, originatingUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", originatingUser.userID]]
                                  withRange:range];
            break;
        }

        case nWTActivityTypeLIKE:
        {
            OWTUser* subjectUser = nil;
            if (_mergedActivity.subjectUserIDs != nil)
            {
                subjectUser = [um userForID:_mergedActivity.subjectUserIDs.firstObject];
            }
            NSString* subjectUserName;
            if (subjectUser != nil)
            {
                subjectUserName = subjectUser.displayName;
            }
            else
            {
                subjectUserName = @"全景用户";
            }

            _descriptionLabel.text = [NSString stringWithFormat:@"%@喜欢了%@的照片", originatingUserName, subjectUserName];
            NSRange range = NSMakeRange(0, originatingUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", originatingUser.userID]]
                                  withRange:range];

            NSRange subjectUserNameRange = NSMakeRange(originatingUserName.length + [@"喜欢了" length], subjectUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", subjectUser.userID]]
                                  withRange:subjectUserNameRange];
            break;
        }

        case nWTActivityTypeCOMMENT:
        {
            OWTUser* subjectUser = nil;
            if (_mergedActivity.subjectUserIDs != nil)
            {
                subjectUser = [um userForID:_mergedActivity.subjectUserIDs.firstObject];
            }
            NSString* subjectUserName;
            if (subjectUser != nil)
            {
                subjectUserName = subjectUser.displayName;
            }
            else
            {
                subjectUserName = @"全景用户";
            }

            _descriptionLabel.text = [NSString stringWithFormat:@"%@评论了%@的照片", originatingUserName, subjectUserName];
            NSRange range = NSMakeRange(0, originatingUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", originatingUser.userID]]
                                  withRange:range];

            NSRange subjectUserNameRange = NSMakeRange(originatingUserName.length + [@"评论了" length], subjectUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", subjectUser.userID]]
                                  withRange:subjectUserNameRange];
            break;
        }
            
        case nWTActivityTypeFOLLOW:
        {
            NSMutableArray* ranges = [NSMutableArray arrayWithCapacity:_mergedActivity.subjectUserIDs.count];
            NSMutableArray* urls = [NSMutableArray arrayWithCapacity:_mergedActivity.subjectUserIDs.count];

            NSMutableString* text = [NSMutableString stringWithFormat:@"%@关注了", originatingUserName];

            int subjectUserCounter = 0;
            for (NSString* subjectUserID in _mergedActivity.subjectUserIDs)
            {
                OWTUser* subjectUser = [um userForID:subjectUserID];
                if (subjectUser != nil)
                {
                    if (subjectUserCounter != 0)
                    {
                        [text appendString:@"、"];
                    }
                    subjectUserCounter++;

                    NSString* subjectUserName = subjectUser.displayName;
                    NSUInteger start = text.length;
                    NSUInteger length = subjectUserName.length;
                    [text appendString:subjectUserName];

                    NSRange subjectUserNameRange = NSMakeRange(start, length);
                    [ranges addObject:[NSValue valueWithRange:subjectUserNameRange]];

                    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"user://%@", subjectUser.userID]];
                    [urls addObject:url];
                }
            }

            _descriptionLabel.text = text;
            NSRange originatingUserNameRange = NSMakeRange(0, originatingUserName.length);
            [_descriptionLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"user://%@", originatingUser.userID]]
                                  withRange:originatingUserNameRange];

            for (int i = 0; i < ranges.count; ++i)
            {
                NSRange range = ((NSValue*)ranges[i]).rangeValue;
                NSURL* url = urls[i];

                [_descriptionLabel addLinkToURL:url
                                      withRange:range];
            }

            break;
        }

        default:
            break;
    }
}

- (void)updateThumbnailImages
{
    [_thumbnailView2AssetIDs removeAllObjects];

    NSUInteger assetNum = 0;
    if (_mergedActivity != nil && _mergedActivity.subjectAssetIDs != nil)
    {
        assetNum = _mergedActivity.subjectAssetIDs.count;
    }

    OWTAssetManager* am = GetAssetManager();

    if (assetNum == 1)
    {
        for (int thumbnailIndex = 0; thumbnailIndex < 9; thumbnailIndex++)
        {
            OWTImageView* thumbnailView = _thumbnailViews[thumbnailIndex];
            
            thumbnailView.hidden = YES;
            [thumbnailView clearImageAnimated:NO];

            NSLayoutConstraint* heightConstraint = _thumbnailHeightConstraints[thumbnailIndex];
            heightConstraint.constant = 0;
        }

        NSString* assetID = _mergedActivity.subjectAssetIDs[0];
        OWTAsset* subjectAsset = [am getAssetWithID:assetID];
        if (subjectAsset != nil)
        {
            _bigThumbnailView.hidden = NO;
            [_bigThumbnailView setImageWithInfo:subjectAsset.imageInfo];
            [_thumbnailView2AssetIDs setObject:subjectAsset.assetID forKey:[NSValue valueWithPointer:(void*)_bigThumbnailView]];
        }
        else
        {
            _bigThumbnailView.hidden = YES;
            [_bigThumbnailView clearImageAnimated:NO];
        }
    }
    else
    {
        _bigThumbnailView.hidden = YES;
        [_bigThumbnailView clearImageAnimated:NO];

        int thumbnailIndex = 0;
        for (int assetIndex = 0; thumbnailIndex < 9 && assetIndex < assetNum; ++assetIndex)
        {
            NSString* assetID = _mergedActivity.subjectAssetIDs[assetIndex];
            OWTAsset* subjectAsset = [am getAssetWithID:assetID];
            if (subjectAsset != nil)
            {
                OWTImageView* thumbnailView = _thumbnailViews[thumbnailIndex];
                thumbnailView.hidden = NO;
                [thumbnailView setImageWithInfoAsThumbnail:subjectAsset.imageInfo];
                NSLayoutConstraint* heightConstraint = _thumbnailHeightConstraints[thumbnailIndex];
                heightConstraint.constant = 75;
                
                [_thumbnailView2AssetIDs setObject:subjectAsset.assetID forKey:[NSValue valueWithPointer:(void*)thumbnailView]];
                
                thumbnailIndex++;
            }
        }

        for ( ; thumbnailIndex < 9; thumbnailIndex++)
        {
            OWTImageView* thumbnailView = _thumbnailViews[thumbnailIndex];
            
            thumbnailView.hidden = YES;
            [thumbnailView clearImageAnimated:NO];
            
            NSLayoutConstraint* heightConstraint = _thumbnailHeightConstraints[thumbnailIndex];
            heightConstraint.constant = 0;
        }
    }
}

- (void)updateTimestampLabel
{
    if (_mergedActivity == nil)
    {
        _timestampLabel.text = @"";
    }

    long timeDiff = (long)[[NSDate date] timeIntervalSinceDate:_mergedActivity.timestamp];//!!!!!

    if (timeDiff < 0) timeDiff = 0;
    
    long seconds = timeDiff % 60;
    long minutes = (long)(timeDiff / 60);
    long hours = minutes / 60;
    long days = hours / 24;

    NSString* text;
    if (days != 0)
    {
        text = [NSString stringWithFormat:@"%ld天前", days];
    }
    else if (hours != 0)
    {
        text = [NSString stringWithFormat:@"%ld小时前", hours];
    }
    else if (minutes != 0)
    {
        text = [NSString stringWithFormat:@"%ld分钟前", minutes];
    }
    else if (seconds != 0)
    {
        text = [NSString stringWithFormat:@"%ld秒前", days];
    }
    else
    {
        text = @"刚刚";
    }

    _timestampLabel.text = text;
}

- (void)prepareForReuse
{
    self.mergedActivity = nil;
}

- (void)hideThumbnailView
{
    _thumbnailView0.hidden = YES;
    _thumbnailHeightConstraint0.constant = 0;
    _timestamp2ThumbnailDistanceConstraint.constant = 0;
    [self setNeedsUpdateConstraints];
}

- (void)showThumbnailView
{
    _thumbnailView0.hidden = NO;
    _thumbnailHeightConstraint0.constant = 75;
    _timestamp2ThumbnailDistanceConstraint.constant = 8;
    [self setNeedsUpdateConstraints];
}

#pragma mark - TTTAttributedText delegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString* urlStr = [url absoluteString];
    if ([urlStr hasPrefix:@"user://"])
    {
        NSString* userID = [urlStr substringFromIndex:[@"user://" length]];
        if (_userClickedAction != nil)
        {
            _userClickedAction(userID);
        }
    }
}

@end
