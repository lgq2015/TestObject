//
//  KSTemplateListItem.m
//  gifMerchantModule
//
//  Created by maxcw on 2020/11/16.
//

#import "KSTemplateListItem.h"

@implementation KSTemplateListItem

//Response指定了最外层，但是具体的类型返序列要在类型的内部做哈，其实就是一层层下来解析。
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"customId" : @"id"};
}

@end
