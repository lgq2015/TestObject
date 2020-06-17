//
//  RADir.m
//  TestObject
//
//  Created by 冯驰伟 on 2019/1/1.
//  Copyright © 2019 冯驰伟. All rights reserved.
//

#import "RADir.h"

@interface RADir()

@property(nonatomic, strong) NSString* dirPath;

@end

//------------------------------------------------------

@implementation RADir

-(instancetype) init:(NSString*) path
{
    self = [super init];
    if (self)
    {
        _dirPath = path;
    }
    
    return self;
}

-(BOOL) copy:(NSString*) destPath
{
    return NO;
}

-(BOOL) move:(NSString*) destPath
{
    NSString* beforeFolder = _dirPath;
    destPath = [destPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString* afterFolder = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@/", destPath, [beforeFolder lastPathComponent]]];
    
    BOOL bDirectory = NO;
    BOOL bExit = [[NSFileManager defaultManager] fileExistsAtPath:afterFolder isDirectory:&bDirectory];
    if(NO == bExit || NO == bDirectory)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:afterFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:beforeFolder];
    NSString *path;
    while ((path = [dirEnum nextObject]) !=nil)
    {
     if(NO == [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@%@", beforeFolder, path] toPath:[NSString stringWithFormat:@"%@%@", afterFolder, path] error:NULL])
         return NO;
    }

    return [[NSFileManager defaultManager] removeItemAtPath:beforeFolder error:nil];
}

-(NSString*) getPath
{
    return [_dirPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
}

-(int64_t) size
{
    NSString* fileAbsolutePath = [_dirPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    return [self getFileSize:fileAbsolutePath];
}

- (int64_t)getFileSize:(nonnull NSString *)filePath
{
    NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:filePath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
        folderSize += [self getFileSize:fileAbsolutePath];
    }
    return folderSize / (1024.0*1024.0);
}

- (NSArray<id<IRAFile>> *)listFiles
{
    NSArray<NSString *> * stringFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dirPath error:nil];
    NSMutableArray<id<IRAFile>>* raFileList = [NSMutableArray<id<IRAFile>> new];
    for(NSString* name in stringFileList)
    {
        NSString* syntheticPath = [NSString stringWithFormat:@"%@%@", _dirPath, name];
        BOOL bDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:syntheticPath isDirectory:&bDirectory];
        if(bDirectory)
        {
            RADir* raDir = [[RADir alloc] init:syntheticPath];
            [raFileList addObject:raDir];
        }
        else
        {
            RAFile* raFile = [[RAFile alloc] init:syntheticPath];
            [raFileList addObject:raFile];
        }
    }
    
    return raFileList;
}

@end
