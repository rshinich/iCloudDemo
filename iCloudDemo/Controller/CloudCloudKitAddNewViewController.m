//
//  CloudCloudKitAddNewViewController.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/22.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "CloudCloudKitAddNewViewController.h"
#import "iCloudHandle.h"

@interface CloudCloudKitAddNewViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic ,strong) UITextField               *titleText;
@property (nonatomic ,strong) UITextView                *contentText;
@property (nonatomic ,strong) UIButton                  *addPhotoBtn;
@property (nonatomic ,strong) UIImageView               *photoImageView;


@end

@implementation CloudCloudKitAddNewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpViews];
    [self setUpNotification];
}

- (void)setUpViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    [self.navigationItem setRightBarButtonItem:addBtnItem];

    self.titleText = [[UITextField alloc] init];
    self.titleText.frame = CGRectMake(10, 74, CGRectGetWidth(self.view.frame)-20, 40);
    self.titleText.textAlignment = NSTextAlignmentCenter;
    self.titleText.placeholder = @"请输入标题";
    
    self.contentText = [[UITextView alloc] init];
    self.contentText.frame = CGRectMake(10, 124, CGRectGetWidth(self.view.frame)-20, 200);
    self.contentText.layer.borderWidth = 1;
    self.contentText.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.frame = CGRectMake(10, 334, CGRectGetWidth(self.view.frame)-20, 100);
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoImageView.userInteractionEnabled = YES;
    
    
    self.addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addPhotoBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame)-20, 100);
    [self.addPhotoBtn setTitle:@"修改/添加图片" forState:UIControlStateNormal];
    [self.addPhotoBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.addPhotoBtn addTarget:self action:@selector(addPhotoBtnClikced) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.titleText];
    [self.view addSubview:self.contentText];
    [self.view addSubview:self.photoImageView];
    [self.photoImageView addSubview:self.addPhotoBtn];
    
}

- (void)setUpNotification
{
    //获取最新数据完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGetNewCloudData:) name:@"CloudDataSingleQueryFinished" object:nil];
    
}


#pragma mark -
#pragma mark - events

- (void)addBtnClicked
{
    if(self.type == CloudKit_type_AddNew)
    {
        [iCloudHandle saveCloudKitModelWithTitle:self.titleText.text
                                         content:self.contentText.text
                                      photoImage:self.photoImageView.image];
    }
    else if(self.type == CloudKit_type_edit)
    {
        [iCloudHandle changeCloudKitWithTitle:self.titleText.text
                                      content:self.contentText.text
                                   photoImage:self.photoImageView.image
                                     RecordID:self.recordID];
    }
    
}

- (void)addPhotoBtnClikced
{
    UIImagePickerController *imagePicker= [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark - notification

- (void)finishedGetNewCloudData:(NSNotification *)notification
{
    CKRecord *record = notification.userInfo[@"key"];
    
    self.titleText.text = [record objectForKey:@"title"];
    self.contentText.text = [record objectForKey:@"content"];
    
    CKAsset *asset = [record objectForKey:@"photo"];
    UIImage *image = [UIImage imageWithContentsOfFile:asset.fileURL.path];
    self.photoImageView.image = image;
}


#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    self.photoImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
