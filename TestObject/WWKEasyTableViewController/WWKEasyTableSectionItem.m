//
//  WWKEasyTableSectionItem.m
//  WWKEasyTableView
//
//  Created by maxcwfeng on 2020/8/28.
//  Copyright © 2020 maxcwfeng. All rights reserved.
//

#import "WWKEasyTableSectionItem.h"

@implementation WWKEasyTableSectionItem

- (NSMutableArray<WWKEasyTableItem *> *)cellDataSource {
    if (!_cellDataSource) {
        _cellDataSource = [NSMutableArray array];
    }
    return _cellDataSource;
}

@end
