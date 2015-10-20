//
//  OWTSMSInviteViewCon.m
//  Weitu
//
//  Created by Su on 6/19/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSMSInviteViewCon.h"
#import "OWTSMSContactTableViewCell.h"
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SIAlertView/SIAlertView.h>
#import "NSString+ContentCheck.h"
#import "UIViewController+WTExt.h"
#import <PinYin4Objc/PinYin4Objc.h>
#import "ChineseToPinyin.h"
static NSString* kWTContactCellID = @"kWTContactCellID";

@interface OWTContact : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* cellphone;

@end

@implementation OWTContact

@end

@interface OWTSMSInviteViewCon ()
{
    NSArray* _contacts;
    NSMutableArray *_allPeoples;
    NSMutableArray *_sectionTitles;
}

@end

@implementation OWTSMSInviteViewCon
{
    UITableView *_tableView;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _allPeoples=[[NSMutableArray alloc]init];
    _sectionTitles=[[NSMutableArray alloc]init];
    [self setUpTableView];
    _tableView.rowHeight = 71;
    _tableView.allowsSelection = NO;
    _tableView.sectionIndexBackgroundColor=[UIColor lightGrayColor];
    [_tableView registerNib:[UINib nibWithNibName:@"OWTSMSContactTableViewCell" bundle:nil]
         forCellReuseIdentifier:kWTContactCellID];
    
    self.title = @"邀请朋友";
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text =@"邀请朋友";
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
}
-(void)setUpTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self substituteNavigationBarBackItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadContactsIfNeeded];
}

- (void)loadContactsIfNeeded
{
    if (_contacts != nil)
    {
        return;
    }

    switch([APAddressBook access])
    {
        case APAddressBookAccessUnknown:
            break;
            
        case APAddressBookAccessGranted:
            break;
            
        case APAddressBookAccessDenied:
        {
            SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"需要访问联系人列表" andMessage:@"为了能够邀请您的朋友使用全景，请允许全景读取您的联系人列表。您可以在系统设置->隐私->通讯录中进行操作。"];
            alertView.transitionStyle = SIAlertViewTransitionStyleFade;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView addButtonWithTitle:@"确认"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView* alertView) {
                                      [alertView dismissAnimated:YES];
                                      if (_failFunc != nil)
                                      {
                                          _failFunc();
                                      }
                                  }];
            [alertView show];
            return;
        }
        default:
            break;
    }

    [SVProgressHUD show];

    APAddressBook* addressBook = [[APAddressBook alloc] init];
    addressBook.fieldsMask = APContactFieldCompositeName | APContactFieldPhones;
    addressBook.filterBlock = ^ BOOL (APContact* contact)
    {
        return contact.phones.count > 0;
    };

    [addressBook loadContacts:^(NSArray* contacts, NSError* error)
    {
        if (error != nil)
        {
            [SVProgressHUD showErrorWithStatus:@"无法获取联系人列表，请确认您已经允许全景访问联系人列表。"];
            return;
        }

        NSMutableArray* wtConacts = [NSMutableArray array];

        for (APContact* apContact in contacts)
        {
            for (NSString* phone in apContact.phones)
            {
                NSString* clearedPhone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                clearedPhone = [clearedPhone stringByReplacingOccurrencesOfString:@"+86" withString:@""];

                if ([clearedPhone isValidChineseCellphoneNumberWithoutPrefix])
                {
                    OWTContact* wtContact = [[OWTContact alloc] init];
                    wtContact.name = apContact.compositeName;
                    wtContact.cellphone = clearedPhone;
                    [wtConacts addObject:wtContact];
                }
            }
        }

        HanyuPinyinOutputFormat* pinyinFormat=[[HanyuPinyinOutputFormat alloc] init];
        [pinyinFormat setToneType:ToneTypeWithoutTone];
        [pinyinFormat setVCharType:VCharTypeWithV];
        [pinyinFormat setCaseType:CaseTypeLowercase];

        [wtConacts sortUsingComparator:^ NSComparisonResult (OWTContact* lhs, OWTContact* rhs) {
            NSString* lhsPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:lhs.name withHanyuPinyinOutputFormat:pinyinFormat withNSString:@" "];
            NSString* rhsPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:rhs.name withHanyuPinyinOutputFormat:pinyinFormat withNSString:@" "];
            return [lhsPinyin compare:rhsPinyin];
        }];

        _contacts = wtConacts;
    [_allPeoples addObjectsFromArray:[self sortDataArray:_contacts]];
        [self deleteEmptyArr];
        [SVProgressHUD dismiss];
        [_tableView reloadData];
    }];
}
- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [_sectionTitles removeAllObjects];
    [_sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [_sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (OWTContact* contact in dataArray) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
        NSString *nameStr=contact.name;
        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:nameStr];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:contact];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(OWTContact *obj1, OWTContact *obj2) {
            NSString *firstLetter1 = [ChineseToPinyin pinyinFromChineseString:obj1.name];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [ChineseToPinyin pinyinFromChineseString:obj2.name];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        //根据nickName的排序，对字典重新排列
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}
-(void)deleteEmptyArr{
    NSMutableArray * existTitles = [NSMutableArray array];
    NSMutableArray * existPeoples=[NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [_sectionTitles count]; i++) {
        if ([[_allPeoples objectAtIndex:i] count] > 0) {
            [existTitles addObject:[_sectionTitles objectAtIndex:i]];
            [existPeoples addObject:[_allPeoples objectAtIndex:i]];
        }
    }
    [_allPeoples removeAllObjects];
    [_sectionTitles removeAllObjects];
    [_allPeoples addObjectsFromArray:existPeoples];
    [_sectionTitles addObjectsFromArray:existTitles];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _allPeoples.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr=_allPeoples[section];
    return arr.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[_sectionTitles objectAtIndex:section]];
    [contentView addSubview:label];
    return contentView;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [_sectionTitles count]; i++) {
        if ([[_allPeoples objectAtIndex:i] count] > 0) {
            [existTitles addObject:[_sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectio
{

    return 22;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OWTSMSContactTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kWTContactCellID forIndexPath:indexPath];
    NSArray *arr=_allPeoples[indexPath.section];
    OWTContact* contact = arr[indexPath.row];
    cell.name = contact.name;
    cell.cellphone = contact.cellphone;
    
    if (cell.inviteFunc == nil)
    {
        cell.inviteFunc = ^(NSString* name, NSString* cellphone)
        {
            [self sendInviteMessageTo:cellphone];
        };
    }

    return cell;
}

- (void)sendInviteMessageTo:(NSString*)cellphone
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
        controller.body = @"全景App里有不少漂亮又专业的图片，挺有意思的，推荐你用一下。下载地址：http://api.tiankong.com";
        controller.recipients = @[ cellphone ];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"无法发送短信" andMessage:@"抱歉，您的设备目前无法发送短信。"];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView* alertView) {
                                  [alertView dismissAnimated:YES];
                              }];

        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        [alertView show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"无法发送短信" andMessage:@"抱歉，您的设备目前无法发送短信。"];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView* alertView) {
                                      [alertView dismissAnimated:YES];
                                  }];

            alertView.transitionStyle = SIAlertViewTransitionStyleFade;
            [alertView show];
            break;
        }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
