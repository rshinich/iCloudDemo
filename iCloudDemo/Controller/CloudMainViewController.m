//
//  CloudMainViewController.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/20.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "CloudMainViewController.h"
#import "CloudKeyValueViewController.h"
#import "CloudDocumentViewController.h"
#import "CloudCloudKitViewController.h"


@interface CloudMainViewController ()


@end

@implementation CloudMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"iCloud Demo";
    
    UIButton *keyValueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    keyValueBtn.frame = CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 50);
    [keyValueBtn setTitle:@"key-value" forState:UIControlStateNormal];
    [keyValueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyValueBtn addTarget:self action:@selector(keyValueBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *documentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    documentBtn.frame = CGRectMake(0, 250, CGRectGetWidth(self.view.frame), 50);
    [documentBtn setTitle:@"Document" forState:UIControlStateNormal];
    [documentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [documentBtn addTarget:self action:@selector(documentBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cloudKitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cloudKitBtn.frame = CGRectMake(0, 350, CGRectGetWidth(self.view.frame), 50);
    [cloudKitBtn setTitle:@"Cloud kit" forState:UIControlStateNormal];
    [cloudKitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cloudKitBtn addTarget:self action:@selector(cloudKitBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    
    [self.view addSubview:keyValueBtn];
    [self.view addSubview:documentBtn];
    [self.view addSubview:cloudKitBtn];
}

#pragma mark -
#pragma mark - evnet

- (void)keyValueBtnClicked
{
    CloudKeyValueViewController *vc = [[CloudKeyValueViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)documentBtnClicked
{
    CloudDocumentViewController *vc = [[CloudDocumentViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cloudKitBtnClicked
{
    CloudCloudKitViewController *vc = [[CloudCloudKitViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
