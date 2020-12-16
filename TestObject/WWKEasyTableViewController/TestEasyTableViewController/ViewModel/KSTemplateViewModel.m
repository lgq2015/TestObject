//
//  KSTemplateViewModel.m
//  gifMerchantModule
//
//  Created by fengchiwei on 2020/11/16.
//  Copyright © 2020年 tencent. All rights reserved.
//

#import "KSTemplateViewModel.h"
#import "KSTemplateListItem.h"

NSString *const KSMerchantCustomUpdateNotification = @"KSMerchantCustomUpdateNotification";

#define MaxBatchCount 10

@interface KSTemplateViewModel ()

@property (nonatomic, copy) succ succ; /**<请求成功*/
@property (nonatomic, copy) fail fail; /**<请求失败*/

@end

//------------------------------------------------------------------------------------
@implementation KSTemplateViewModel

- (instancetype)initWithSucc:(succ)succ fail:(fail)fail {
    if (self = [super init]) {
        _succ = succ;
        _fail = fail;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotifyEvent:)
                                                     name:KSMerchantCustomUpdateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData {
    if (NO == [self p_checkNetwork]){
        if (self.fail) {
            self.fail(YES);
        }
        return;
    }

    //获取数据
    [self p_fatchServerData];
}

- (void)selectItem:(NSIndexPath *)indexPath{
    if(indexPath.row >= self.datas.count){
        return;
    }
    
    KSTemplateListItem *item = self.datas[indexPath.row];
    item = nil;
}

- (void)handleNotifyEvent:(NSNotification *)notification {
}

- (void)p_fatchServerData{
    //测试数据
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(action:) userInfo:nil repeats:NO];
}

- (void)action:(id) timer{
    NSMutableArray<KSTemplateListItem*>* result = [[NSMutableArray<KSTemplateListItem*> alloc] initWithCapacity:5];
    for(int i = 0; i < 50; i++){
        KSTemplateListItem* tempItem = [[KSTemplateListItem alloc] init];
        tempItem.customId = i;
        [result addObject:tempItem];
    }
    
    self.datas = result;
    if (self.succ) {
        self.succ();
    }
}

- (BOOL)p_checkNetwork {
    return YES;
}

- (void) p_requestErrorHandle{
    
}

- (void) p_requestSussHandle:(NSArray<KSTemplateListItem*> *) result{
    self.datas = result;
    if (self.succ) {
        self.succ();
    }
}

@end
