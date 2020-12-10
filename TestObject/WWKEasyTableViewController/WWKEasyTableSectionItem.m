//
//  WWKEasyTableSectionItem.m
//  WWKEasyTableView
//
//  Created by wyman on 2019/4/28.
//  Copyright © 2019 wyman. All rights reserved.
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
