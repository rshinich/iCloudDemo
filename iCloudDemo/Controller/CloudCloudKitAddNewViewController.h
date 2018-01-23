//
//  CloudCloudKitAddNewViewController.h
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/22.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

typedef NS_ENUM(NSInteger, CloudKit_type)
{
    CloudKit_type_AddNew = 0,
    CloudKit_type_edit,
};


@interface CloudCloudKitAddNewViewController : UIViewController

@property (nonatomic ,assign) CloudKit_type         type;
@property (nonatomic ,strong) CKRecordID            *recordID;

@end
