//
//  CloudCloudKitViewController.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/20.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "CloudCloudKitViewController.h"
#import "iCloudHandle.h"
#import "CloudCloudKitAddNewViewController.h"

@interface CloudCloudKitViewController ()<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView               *mainTableView;
@property (nonatomic ,copy)   NSArray                   *dataArr;

@end

@implementation CloudCloudKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpNotification];
    [self getData];
}

- (void)setUpViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Cloud kit";
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    [self.navigationItem setRightBarButtonItem:addBtnItem];

    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    
    [self.view addSubview:self.mainTableView];

}

- (void)getData
{
    [iCloudHandle queryCloudKitData];
}

- (void)setUpNotification
{
    //获取最新数据完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGetNewCloudData:) name:@"CloudDataQueryFinished" object:nil];
    
}


#pragma mark -
#pragma mark - event

- (void)addBtnClicked
{
    CloudCloudKitAddNewViewController *vc = [[CloudCloudKitAddNewViewController alloc] init];
    vc.type = CloudKit_type_AddNew;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark - notification

- (void)finishedGetNewCloudData:(NSNotification *)notification
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.dataArr = notification.userInfo[@"key"];
        [self.mainTableView reloadData];

    });
    
}

#pragma mark -
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    CKRecord *record = [self.dataArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [record objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CKRecord *record = [self.dataArr objectAtIndex:indexPath.row];
    CKRecordID *recordID = record.recordID;
    
    CloudCloudKitAddNewViewController *vc = [[CloudCloudKitAddNewViewController alloc] init];
    vc.type = CloudKit_type_edit;
    vc.recordID = recordID;
    [self.navigationController pushViewController:vc animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        CKRecord *record = [self.dataArr objectAtIndex:indexPath.row];
        CKRecordID *recordID = record.recordID;
        
        [iCloudHandle removeCloudKitDataWithRecordID:recordID];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
