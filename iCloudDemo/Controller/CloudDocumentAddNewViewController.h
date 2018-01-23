//
//  CloudDocumentAddNewViewController.h
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/20.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Document_type)
{
    Document_type_addNew = 0,
    Document_type_edit,
};


@interface CloudDocumentAddNewViewController : UIViewController

@property (nonatomic ,copy) NSString                *fileName;
@property (nonatomic ,assign) Document_type          type;

@end
