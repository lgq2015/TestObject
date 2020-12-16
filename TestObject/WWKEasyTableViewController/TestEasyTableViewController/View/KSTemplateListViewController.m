//
//  KSTemplateListViewController.m
//  gifMerchantModule
//
//  Created by fengchiwei on 2020/11/16.
//  Copyright © 2020年 tencent. All rights reserved.
//

#import "KSTemplateListViewController.h"
#import "KSTemplateViewModel.h"
#import "KSTemplateListItem.h"
#import "KSTemplateTableViewCell.h"

#define kHeaderHeight 44
#define kBottomHeight 75

@interface KSTemplateListViewController ()

@property (nonatomic, strong) KSTemplateViewModel *viewModel;

@end

//------------------------------------------------------------------------------------
@implementation KSTemplateListViewController

- (instancetype)initWithRequestParameters:(NSDictionary *)parameters {
    if (self = [super init]) {
    }
    return self;
}


- (void)loadView {
    [super loadView];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initMVVM];
    [self.viewModel refreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initMVVM {
    //-----ViewModel初始化
    __weak typeof(self) weakSelf = self;
    self.viewModel = [[KSTemplateViewModel alloc] initWithSucc:^() {
            __strong typeof(&*weakSelf) strongSelf = weakSelf;
            if (nil == strongSelf)
                return;

            [strongSelf configUIData];
        }
        fail:^(BOOL isNetWorkError) {
            if (nil == weakSelf)
                return;
        
            if(isNetWorkError) {
                NSLog(@"网络异常");
            }
        }];
}

- (void)configUIData {
    [self.dataSource removeAllObjects];
    if (self.viewModel.datas.count <= 0) {
        self.tableView.hidden = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    int i = 0;
    WWKEasyTableSectionItem *section = [WWKEasyTableSectionItem new];
    for (KSTemplateListItem *it in self.viewModel.datas) {
        WWKEasyTableItem *item = [[WWKEasyTableItem alloc] init];
        item.cellClass = KSTemplateTableViewCell.class;
        item.autoCalculateHeight = YES;
        item.cellHeight = [KSTemplateTableViewCell cellHeight];
        
        
        if(10 == i){
            item.hover = EasyTableHoverTop;
        }
        i++;
        item.cellClickAction = ^(__kindof WWKEasyTableItem * _Nonnull cellItem) {
            __strong typeof(&*weakSelf) strongSelf = weakSelf;
            if (nil == strongSelf) {
                return;
            }
    
            [self.viewModel selectItem:cellItem.indexPath];
        };
        item.configCellBlock = ^(__kindof KSTemplateTableViewCell * _Nonnull cell, __kindof WWKEasyTableItem * _Nonnull item) {
            __strong typeof(&*weakSelf) strongSelf = weakSelf;
            if (nil == strongSelf) {
                return;
            }
            
            [cell updateWithData:it];
            cell.delegate = strongSelf;
        };
        [section.cellDataSource addObject:item];
    }
    [self.dataSource addObject:section];
    
    section = [WWKEasyTableSectionItem new];
    section.headerView = [[UIView alloc] init];
    section.headerHeight = 20;
    for (KSTemplateListItem *it in self.viewModel.datas) {
        WWKEasyTableItem *item = [[WWKEasyTableItem alloc] init];
        item.cellClass = KSTemplateTableViewCell.class;
        item.autoCalculateHeight = YES;
        item.cellHeight = [KSTemplateTableViewCell cellHeight];
        item.cellClickAction = ^(__kindof WWKEasyTableItem * _Nonnull cellItem) {
            __strong typeof(&*weakSelf) strongSelf = weakSelf;
            if (nil == strongSelf) {
                return;
            }
    
            [self.viewModel selectItem:cellItem.indexPath];
        };
        item.configCellBlock = ^(__kindof KSTemplateTableViewCell * _Nonnull cell, __kindof WWKEasyTableItem * _Nonnull item) {
            __strong typeof(&*weakSelf) strongSelf = weakSelf;
            if (nil == strongSelf) {
                return;
            }
            
            [cell updateWithData:it];
            cell.delegate = strongSelf;
        };
        [section.cellDataSource addObject:item];
    }
    //[self.dataSource addObject:section];
    
    self.tableView.hidden = NO;
    self.OPEN_DEBUG = YES;
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, 100, self.tableView.bounds.size.width, 900);
}


@end
