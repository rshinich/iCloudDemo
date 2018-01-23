//
//  iCloudHandle.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/15.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "iCloudHandle.h"
#import "ZZRDocument.h"

#define UbiquityContainerIdentifiers @"iCloud.com.zzr.ZZRiCloudDemo"
#define RECORD_TYPE_NAME @"Note"

@implementation iCloudHandle

#pragma mark - key-value storage

+ (void)setUpKeyValueICloudStoreWithKey:(NSString *)key value:(NSString *)value;
{
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    [keyValueStore setObject:value forKey:key];
    [keyValueStore synchronize];
}

+ (NSString *)getKeyValueICloudStoreWithKey:(NSString *)key
{
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    NSString *testString = [keyValueStore objectForKey:key];
    NSLog(@"%@",testString);
    return testString;
}


#pragma mark - iCloud Document

//获取地址
+ (NSURL *)getUbiquityContauneURLWithFileName:(NSString *)fileName
{
    NSURL *ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UbiquityContainerIdentifiers];
    
    //验证iCloud是否可用
    if(!ubiquityURL)
    {
        NSLog(@"尚未开启iCloud功能");
        return nil;
    }
    
    NSURL *URLWithFileName = [ubiquityURL URLByAppendingPathComponent:@"Documents"];
    URLWithFileName = [URLWithFileName URLByAppendingPathComponent:fileName];
    
    return URLWithFileName;
}


//创建文档
+ (void)createDocumentWithFileName:(NSString *)fileName content:(NSString *)content
{
    NSURL *url = [iCloudHandle getUbiquityContauneURLWithFileName:fileName];
    ZZRDocument *doc = [[ZZRDocument alloc] initWithFileURL:url];
    
    NSString *docContent = content;
    doc.myData = [docContent dataUsingEncoding:NSUTF8StringEncoding];
    [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
       
        if(success)
        {
            NSLog(@"创建文档成功");
        }
        else
        {
            NSLog(@"创建文档失败");
        }
    }];
}


//修改文档 实际上是overwrite重写
+ (void)overwriteDocumentWithFileName:(NSString *)fileName content:(NSString *)content;
{
    NSURL *url = [iCloudHandle getUbiquityContauneURLWithFileName:fileName];
    ZZRDocument *doc = [[ZZRDocument alloc] initWithFileURL:url];
    
    doc.myData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [doc saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"修改文档成功");
        }
        else
        {
            NSLog(@"修改文档失败");
        }
    }];
}


//删除文档
+ (void)removeDocumentWithFileName:(NSString *)fileName
{
    NSURL *url = [iCloudHandle getUbiquityContauneURLWithFileName:fileName];
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    
    if(error)
    {
        NSLog(@"删除文档失败 %@",error);
    }
    else
    {
        NSLog(@"删除文档成功");
    }
}


//获取最新的数据
+ (void)getNewDocument:(NSMetadataQuery *)myMetadataQuery
{
    [myMetadataQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    [myMetadataQuery startQuery];
}


#pragma mark - Cloud Kit

+ (void)saveCloudKitModelWithTitle:(NSString *)title content:(NSString *)content photoImage:(UIImage *)image
{
    CKContainer *container = [CKContainer defaultContainer];

    //公共数据
    CKDatabase *datebase = container.publicCloudDatabase;
//    //私有数据
//    CKDatabase *datebase = container.privateCloudDatabase;

    //创建主键
//    CKRecordID *noteID = [[CKRecordID alloc] initWithRecordName:@"NoteID"];
    
    //创建保存数据
    CKRecord *noteRecord = [[CKRecord alloc] initWithRecordType:RECORD_TYPE_NAME];
    
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData == nil)
    {
        imageData = UIImageJPEGRepresentation(image, 0.6);
    }
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imagesTemp"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:tempPath]) {
        
        [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDate *dateID = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval = [dateID timeIntervalSince1970] * 1000;      //*1000表示到毫秒级，这样可以保证不会同时生成两个同样的id
    NSString *idString = [NSString stringWithFormat:@"%.0f", timeInterval];

    NSString *filePath = [NSString stringWithFormat:@"%@/%@",tempPath,idString];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [imageData writeToURL:url atomically:YES];
    
    CKAsset *asset = [[CKAsset alloc]initWithFileURL:url];
    
    [noteRecord setValue:title forKey:@"title"];
    [noteRecord setValue:content forKey:@"content"];
    [noteRecord setValue:asset forKey:@"image"];
    
    
    [datebase saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        if(!error)
        {
            NSLog(@"保存成功");
        }
        else
        {
            NSLog(@"保存失败");
            NSLog(@"%@",error.description);
        }
    }];
}




//查询数据
+ (void)queryCloudKitData
{
    //获取位置
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    
    //添加查询条件
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:RECORD_TYPE_NAME predicate:predicate];
    
    //开始查询
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        
        NSLog(@"%@",results);
        //把数据做成字典通知出去
        NSDictionary *userinfoDic = [NSDictionary dictionaryWithObject:results forKey:@"key"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloudDataQueryFinished" object:nil userInfo:userinfoDic];
    }];

}


//删除数据
+ (void)removeCloudKitDataWithRecordID:(CKRecordID *)recordID
{
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    
    [database deleteRecordWithID:recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        NSLog(@"删除成功");
    }];

}

//查询单条数据
+ (void)querySingleRecordWithRecordID:(CKRecordID *)recordID
{
    //获取容器
    CKContainer *container = [CKContainer defaultContainer];
    //获取公有数据库
    CKDatabase *database = container.publicCloudDatabase;
    
    [database fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",record);
            //把数据做成字典通知出去
            NSDictionary *userinfoDic = [NSDictionary dictionaryWithObject:record forKey:@"key"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CloudDataSingleQueryFinished" object:nil userInfo:userinfoDic];
        });
    }];
}

//修改数据
+ (void)changeCloudKitWithTitle:(NSString *)title content:(NSString *)content photoImage:(UIImage *)image RecordID:(CKRecordID *)recordID
{
    //获取容器
    CKContainer *container = [CKContainer defaultContainer];
    //获取公有数据库
    CKDatabase *database = container.publicCloudDatabase;
    
    [database fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        
        NSData *imageData = UIImagePNGRepresentation(image);
        if (imageData == nil)
        {
            imageData = UIImageJPEGRepresentation(image, 0.6);
        }
        NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imagesTemp"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:tempPath]) {
            
            [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSDate *dateID = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeInterval = [dateID timeIntervalSince1970] * 1000;      //*1000表示到毫秒级，这样可以保证不会同时生成两个同样的id
        NSString *idString = [NSString stringWithFormat:@"%.0f", timeInterval];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",tempPath,idString];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [imageData writeToURL:url atomically:YES];
        CKAsset *asset = [[CKAsset alloc]initWithFileURL:url];
        [record setObject:title forKey:@"title"];
        [record setObject:content forKey:@"content"];
        [record setValue:asset forKey:@"photo"];
        [database saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            
            if(error)
            {
                
                NSLog(@"修改失败 %@",error.description);
            }
            else
            {
                NSLog(@"修改成功");
            }
        }];
    }];
}
















@end
