//
//  CloudKeyValueViewController.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/20.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "CloudKeyValueViewController.h"
#import "iCloudHandle.h"

@interface CloudKeyValueViewController ()

@property (nonatomic ,strong) UITextField           *keyTextField;
@property (nonatomic ,strong) UITextField           *valueTextField;
@property (nonatomic ,strong) UIButton              *saveBtn;
@property (nonatomic ,strong) UIButton              *getBtn;

@end

@implementation CloudKeyValueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpNotification];
    
}

- (void)setUpViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"key-value";
    
    self.keyTextField = [[UITextField alloc] init];
    self.keyTextField.frame = CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 50);
    self.keyTextField.textAlignment = NSTextAlignmentCenter;
    self.keyTextField.textColor = [UIColor blackColor];
    self.keyTextField.placeholder = @"请输入要保存或是要查询的key";
    
    self.valueTextField = [[UITextField alloc] init];
    self.valueTextField.frame = CGRectMake(0, 250, CGRectGetWidth(self.view.frame), 50);
    self.valueTextField.textAlignment = NSTextAlignmentCenter;
    self.valueTextField.textColor = [UIColor blackColor];
    self.valueTextField.placeholder = @"请输入要保存的value";
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(0, 350, CGRectGetWidth(self.view.frame), 50);
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.getBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getBtn.frame = CGRectMake(0, 450, CGRectGetWidth(self.view.frame), 50);
    [self.getBtn setTitle:@"查询" forState:UIControlStateNormal];
    [self.getBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.getBtn addTarget:self action:@selector(getBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTap)];
    [self.view addGestureRecognizer:tapGes];
    
    
    [self.view addSubview:self.keyTextField];
    [self.view addSubview:self.valueTextField];
    [self.view addSubview:self.saveBtn];
    [self.view addSubview:self.getBtn];
    
}


- (void)setUpNotification
{
    //监听字符串变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];
}


#pragma mark -
#pragma mark - event


- (void)saveBtnClicked
{
    NSString *keyStr = self.keyTextField.text;
    NSString *valueStr = self.valueTextField.text;
    
    if([keyStr length] == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入key" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:alertAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }
    
    if([valueStr length] == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入value" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:alertAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }
    
    
    [iCloudHandle setUpKeyValueICloudStoreWithKey:keyStr value:valueStr];
}

- (void)getBtnClicked
{
    NSString *keyStr = self.keyTextField.text;
    
    if([keyStr length] == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入key" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:alertAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    NSString *valueStr = [iCloudHandle getKeyValueICloudStoreWithKey:keyStr];
    
    if([valueStr length] == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有查询到value" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:alertAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    self.valueTextField.text = valueStr;
}

- (void)screenTap
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - NSNotificationCenter

- (void)storeDidChange:(NSUbiquitousKeyValueStore *)defaultStore
{
    NSLog(@"%@",defaultStore);
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
