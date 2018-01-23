//
//  ZZRDocument.m
//  iCloudDemo
//
//  Created by 张忠瑞 on 2018/1/16.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "ZZRDocument.h"

@implementation ZZRDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    self.myData = [contents copy];
    
    return YES;
}

- (nullable id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    if(!self.myData)
    {
        self.myData = [[NSData alloc] init];
    }
    
    return self.myData;
}

@end
