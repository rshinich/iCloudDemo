//
//  CloudDocumentViewController.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/20.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "CloudDocumentViewController.h"
#import "iCloudHandle.h"
#import "ZZRDocument.h"
#import "CloudDocumentAddNewViewController.h"


@interface CloudDocumentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView               *mainTableView;
@property (nonatomic ,copy)   NSArray                   *dataArr;
@property (nonatomic ,strong) NSMetadataQuery           *myMetadataQuery;


@end

@implementation CloudDocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.myMetadataQuery = [[NSMetadataQuery alloc] init];

    [self setUpViews];
    [self setUpNotification];
    [iCloudHandle getNewDocument:self.myMetadataQuery];
}

- (void)setUpViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Document";
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    [self.navigationItem setRightBarButtonItem:addBtnItem];
    
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    
    [self.view addSubview:self.mainTableView];
}

- (void)setUpNotification
{
    //获取最新数据完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGetNewDocument:) name:NSMetadataQueryDidFinishGatheringNotification object:self.myMetadataQuery];
    
    //数据更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidChange:) name:NSMetadataQueryDidUpdateNotification object:self.myMetadataQuery];
    
}


#pragma mark -
#pragma mark - events

- (void)addBtnClicked
{
    CloudDocumentAddNewViewController *vc = [[CloudDocumentAddNewViewController alloc] init];
    vc.type = Document_type_addNew;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    NSMetadataItem *item = [self.dataArr objectAtIndex:indexPath.row];

    //获取文件名
    NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
    cell.textLabel.text = fileName;
    
//    //获取文件创建日期
//    NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
//
//    NSLog(@"%@,%@",fileName,date);
//
//    ZZRDocument *doc = [[ZZRDocument alloc] initWithFileURL:[iCloudHandle getUbiquityContauneURLWithFileName:fileName]];
//    [doc openWithCompletionHandler:^(BOOL success) {
//
//        if(success)
//        {
//            NSLog(@"读取数据成功。");
//
//            NSString *docConten = [[NSString alloc] initWithData:doc.myData encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",docConten);
//        }
//    }];

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMetadataItem *item = [self.dataArr objectAtIndex:indexPath.row];
    
    //获取文件名
    NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
    
    CloudDocumentAddNewViewController *vc = [[CloudDocumentAddNewViewController alloc] init];
    vc.fileName = fileName;
    vc.type = Document_type_edit;
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
        NSMetadataItem *item = [self.dataArr objectAtIndex:indexPath.row];
        
        //获取文件名
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        [iCloudHandle removeDocumentWithFileName:fileName];
    }
}


#pragma mark -
#pragma mark - NSNotificationCenter


- (void)finishedGetNewDocument:(NSMetadataQuery *)metadataQuery
{
    NSArray *item =self.myMetadataQuery.results;
    self.dataArr = item;
    [self.mainTableView reloadData];
    
    [item enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMetadataItem *item = obj;
        
        //获取文件名
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //获取文件创建日期
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        
        NSLog(@"%@,%@",fileName,date);
        
        ZZRDocument *doc = [[ZZRDocument alloc] initWithFileURL:[iCloudHandle getUbiquityContauneURLWithFileName:fileName]];
        [doc openWithCompletionHandler:^(BOOL success) {
            
            if(success)
            {
                NSLog(@"读取数据成功。");
                
                NSString *docConten = [[NSString alloc] initWithData:doc.myData encoding:NSUTF8StringEncoding];
                NSLog(@"%@",docConten);
            }
        }];
    }];
}


- (void)documentDidChange:(NSMetadataQuery *)metadataQuery
{
    NSLog(@"Document 数据更新");
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
