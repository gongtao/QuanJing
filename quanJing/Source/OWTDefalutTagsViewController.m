//
//  OWTDefalutTagsViewController.m
//  Weitu
//
//  Created by denghs on 15/10/9.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTDefalutTagsViewController.h"
#import "OWTDefaultTableViewCell.h"
@interface OWTDefalutTagsViewController ()
{
    NSMutableArray *_contacts;
    NSArray *_dataSource;
}

@end

@implementation OWTDefalutTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [[NSMutableArray alloc]init];
    _contacts = [[NSMutableArray alloc]init];

    [self setupDefaultCell];
    // Do any additional setup after loading the view.
}

-(void)setupDefaultCell
{
    _dataSource = [[NSMutableArray alloc]initWithObjects:@"美食",@"风景",@"旅游",@"艺术",@"摄影",@"江河大海",@"徒步",@"很快乐",@"就是爽", nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefalutListCell";
    OWTDefaultTableViewCell *cell = (OWTDefaultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[OWTDefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *tagStr = [_dataSource  objectAtIndex:indexPath.row];
    cell.textLabel.text = tagStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedTag = [_dataSource objectAtIndex:indexPath.row];
    _tagSelectedAction(selectedTag);

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
