//
//  RAFileSystem.m
//  TestObject
//
//  Created by 冯驰伟 on 2018/12/31.
//  Copyright © 2018 冯驰伟. All rights reserved.
//

#import "RALocalFileSystem.h"
#import "RAFile.h"
#import "RADir.h"

@interface RALocalFileSystem()

@property(nonatomic, strong) NSString* sysPath;

@end

//------------------------------------------------------
@implementation RALocalFileSystem

-(BOOL) init:(NSString*) path
{
    if(nil == path || [path isEqualToString:@""])
        return NO;
    
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    self.sysPath = [path stringByAppendingString:@"/"];
    
    BOOL bDirectory = NO;
    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&bDirectory] || NO == bDirectory)
        return NO;
    
    return YES;
}

-(void) uninit
{
    self.sysPath = nil;
}

-(void) delete
{
    if(_sysPath)
        [[NSFileManager defaultManager] removeItemAtPath:_sysPath error:nil];
}

- (id<IRAFile>) openFile:(NSString*) path
{
    if(nil == _sysPath || nil == path || [path isEqualToString:@""])
       return nil;
       
    NSString* syntheticPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    syntheticPath = [_sysPath stringByAppendingString:syntheticPath];
    
    BOOL bDirectory = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&bDirectory])
    {
        if(bDirectory)
        {
            syntheticPath = [syntheticPath stringByAppendingString:@"/"];
            RADir* raDir = [[RADir alloc] init:syntheticPath];
            return raDir;
        }
        else
        {
            RAFile* raFile = [[RAFile alloc] init:syntheticPath];
            return raFile;
        }
    }
    
    //对于不存在对象，这里全部当成文件来处理
    RAFile* raFile = [[RAFile alloc] init:syntheticPath];
    return raFile;
}

-(void) setExtraParam:(NSString*) key value:(NSString*) value
{
    
}


@end
