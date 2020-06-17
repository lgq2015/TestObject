//
//  RAFile.m
//  TestObject
//
//  Created by 冯驰伟 on 2019/1/1.
//  Copyright © 2019 冯驰伟. All rights reserved.
//

#import "RAFile.h"

@interface RAFile()

@property(nonatomic, strong) NSString* filePath;
@property(nonatomic, assign) BOOL isExit;

@end

//------------------------------------------------------
@implementation RAFile

-(instancetype) init:(NSString*) path
{
    self = [super init];
    if (self)
    {
        _filePath = path;
        _isExit = [[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:nil];
    }
    
    return self;
}

-(void) create
{
    //这里是个疑问，妈蛋创建什么名字的文件。
}

-(BOOL) delete
{
    return [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
}

-(BOOL) exists
{
    return _isExit;
}

-(BOOL) makedir
{
    //这里是个疑问，妈蛋创建什么名字的文件夹。
    return NO;
}

-(BOOL) copy:(NSString*) destPath
{
    if(NO == _isExit)
        return NO;
    
    return [[NSFileManager defaultManager] copyItemAtPath:_filePath toPath:destPath error:nil];
}

-(BOOL) move:(NSString*) destPath
{
    if(NO == _isExit)
        return NO;
    
    return [[NSFileManager defaultManager] moveItemAtPath:_filePath toPath:destPath error:nil];
}

-(NSString*) getPath
{
    return _filePath;
}

-(NSString*) getParent
{
    if(NO == _isExit)
        return @"";
    
    return [_filePath stringByDeletingLastPathComponent];
}

-(NSString*) getName
{
    if(NO == _isExit)
        return @"";
    
    return [_filePath lastPathComponent];
}

-(int64_t) size
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] fileSize];
}

- (NSArray<id<IRAFile>> *)listFiles
{
    return nil;
}
//#返回一个文件数组，
//#这些路径名表示此抽象路径名所表示目录中的文件。
//#如果是一个文件，则返回NULL。
//listFiles():list<IRAFile>;
//
//#判断是一个文件还是一个目录。
//#@return 如果是一个目录则返回True，否则返回False。
//isDirectory():bool;
//
//#读取文件的二进制内容。
//#打开文件，并将文件内容以二进制返回， 之后关闭文件。
//#如果文件读取失败， 或此文件是一个目录则返回一个NULL。
//readAllBytes():binary;
//
//#将二进制数据写入文件。
//#打开文件，并将data对应的二进制数据写入文件， 之后关闭文件。
//#写入成功后，文件的原内容将被覆盖。
//#如果写入文件失败，则返回false， 否则返回true。
//writeAllBytes(data:binary):bool;
//
//#获取文件的创建时间。(自1970年1月1日午夜起的毫秒数)
//#@return 文件的创建时间，如果没有创建时间则返回-1。
//getCreateTime():i64;
//
//#获取文件的修改时间。(自1970年1月1日午夜起的毫秒数)
//#@return 文件的修改时间，如果没有修改时间则返回-1。
//getLastModifiedTime():i64;
//
//#获取文件的访问时间。(自1970年1月1日午夜起的毫秒数)
//#@return 文件的访问时间，如果没有访问时间则返回-1。
//getLastAccessTime():i64;
//
//#打开一个文件流
//#@return 返回所打开的文件流，如果失败则返回NULL。
//openFileSteam():IRAFileStream;

@end
