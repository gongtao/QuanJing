//
//  OMultiTableViewCon.m
//  Weitu
//
//  Created by Su on 7/17/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OMultiTableViewCon.h"
#import <NYSegmentedControl/NYSegmentedControl.h>

@interface OMultiTableViewCon ()
{
    NYSegmentedControl* _segmentedControl;
    NSMutableDictionary* _cachedScrollPosition;
}

@end

@implementation OMultiTableViewCon

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationBar];
    [self setupTableView];
}

- (void)setupNavigationBar
{
    UIColor* color = GetThemer().themeColor;

    _segmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"A", @"B"]];
    _segmentedControl.backgroundColor = color;
    _segmentedControl.segmentIndicatorBackgroundColor = [UIColor whiteColor];
    _segmentedControl.segmentIndicatorInset = 0.0f;
    _segmentedControl.titleTextColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _segmentedControl.selectedTitleTextColor = color;
    _segmentedControl.borderWidth = 0.0f;
    _segmentedControl.borderColor = color;
    _segmentedControl.segmentIndicatorInset = 2.0f;
    _segmentedControl.segmentIndicatorBorderWidth = 0.0;
    _segmentedControl.cornerRadius = 6.f;
    [_segmentedControl sizeToFit];

    [_segmentedControl addTarget:self action:@selector(segmentSelected) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.selectedSegmentIndex = 0;

    [self reloadSegmentedControl];

    self.navigationItem.titleView = _segmentedControl;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)setupTableView
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.allowsSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)segmentSelected
{
    NSUInteger selectedIndex = _segmentedControl.selectedSegmentIndex;
    NSString* tableID;
    if (selectedIndex < _tableIDs.count)
    {
        tableID = _tableIDs[selectedIndex];
    }
    else
    {
        tableID = nil;
    }

    [self switchToTableWithID:tableID];
}

- (void)switchToTableWithID:(NSString*)tableID
{
    if (_activeTableID == tableID)
    {
        // TODO notify segment selected again
        return;
    }
    
    if (_activeTableID != nil)
    {
        NSNumber* position = [NSNumber numberWithFloat:self.tableView.contentOffset.y];
        [_cachedScrollPosition setValue:position
                                 forKey:_activeTableID];
    }
    
    _activeTableID = tableID;
    
    [self reloadData];
    
    NSNumber* newPosition = _cachedScrollPosition[_activeTableID];
    if (newPosition != nil)
    {
        self.tableView.contentOffset = CGPointMake(0, newPosition.floatValue);
    }
    else
    {
        self.tableView.contentOffset = CGPointMake(-self.tableView.contentInset.left, -self.tableView.contentInset.top);
    }
    
    [self didSwitchToTableWithID:tableID];
}

- (void)reloadData
{
    if (self.tableView != nil)
    {
        [self.tableView reloadData];
    }
}

- (void)setTableIDs:(NSArray *)tableIDs titles:(NSArray*)titles
{
    if (tableIDs.count != titles.count)
    {
        return;
    }

    _tableIDs = tableIDs;
    _titles = titles;
    [self reloadSegmentedControl];

    NSMutableDictionary* cachedScrollPosition = [NSMutableDictionary dictionary];
    for (NSString* tableID in _tableIDs)
    {
        NSObject* value = [_cachedScrollPosition valueForKey:tableID];
        if (value != nil)
        {
            [cachedScrollPosition setValue:value forKeyPath:tableID];
        }
    }
    _cachedScrollPosition = cachedScrollPosition;

    if (_tableIDs.count > 0)
    {
        _segmentedControl.selectedSegmentIndex = 0;
        [self switchToTableWithID:[_tableIDs firstObject]];
    }
}

- (void)reloadSegmentedControl
{
    if (_segmentedControl == nil)
    {
        return;
    }
    
    NSInteger titleNum = _titles.count;
    
    while (_segmentedControl.numberOfSegments > titleNum)
    {
        NSInteger lastIndex = _segmentedControl.numberOfSegments - 1;
        [_segmentedControl removeSegmentAtIndex:lastIndex];
    }
    
    while (_segmentedControl.numberOfSegments < titleNum)
    {
        [_segmentedControl insertSegmentWithTitle:@"" atIndex:_segmentedControl.numberOfSegments];
    }
    
    for (NSInteger i = 0; i < titleNum; ++i)
    {
        [_segmentedControl setTitle:_titles[i] forSegmentAtIndex:i];
    }
}

#pragma mark - Multi table view methods

- (void)didSwitchToTableWithID:(NSString*)tableID
{
    
}

- (NSInteger)numberOfSectionsInTableWithID:(NSString*)tableID
{
    return 0;
}

- (NSInteger)tableWithID:(NSString*)tableID numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableWithID:(NSString*)tableID cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableWithID:(NSString*)tableID heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSString *)tableWithID:(NSString*)tableID titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_activeTableID == nil)
    {
        return 0;
    }

    return [self numberOfSectionsInTableWithID:_activeTableID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_activeTableID == nil)
    {
        return 0;
    }

    return [self tableWithID:_activeTableID numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_activeTableID == nil)
    {
        return [[UITableViewCell alloc] init];
    }

    return [self tableWithID:_activeTableID cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_activeTableID == nil)
    {
        return 0;
    }
    
    return [self tableWithID:_activeTableID heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_activeTableID == nil)
    {
        return nil;
    }
    
    return [self tableWithID:_activeTableID titleForHeaderInSection:section];
}

@end
