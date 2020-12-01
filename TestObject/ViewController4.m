//
//  ViewController4.m
//  MasonryDemo
//
//  Created by TangJR on 15/4/29.
//  Copyright (c) 2015年 tangjr. All rights reserved.
//

#import "ViewController4.h"
#import "ViewController.h"
#import "ViewController2.h"
#import "ViewController3.h"
#import "Masonry.h"

@interface ViewController4 ()

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *viewController;
@property (strong, nonatomic) UIButton *viewController2;
@property (strong, nonatomic) UIButton *viewController3;

@end

@implementation ViewController4

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadView{
    [super loadView];
    
    _textField = [UITextField new];
    _textField.backgroundColor = [UIColor redColor];
    [self.view addSubview:_textField];
    
    _viewController = [[UIButton alloc] init];
    _viewController.backgroundColor = [UIColor blueColor];
    [_viewController setTitle:@"viewController" forState:UIControlStateNormal];
    [_viewController addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewController];
    
    _viewController2 = [[UIButton alloc] init];
    _viewController2.backgroundColor = [UIColor blueColor];
    [_viewController2 setTitle:@"viewController2" forState:UIControlStateNormal];
    [_viewController2 addTarget:self action:@selector(btnClick2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewController2];
    
    _viewController3 = [[UIButton alloc] init];
    _viewController3.backgroundColor = [UIColor blueColor];
    [_viewController3 setTitle:@"viewController3" forState:UIControlStateNormal];
    [_viewController3 addTarget:self action:@selector(btnClick3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewController3];
}

-(void) btnClick:(id) object{
    ViewController* VC = [[ViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void) btnClick2:(id) object{
    ViewController2* VC = [[ViewController2 alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void) btnClick3:(id) object{
    ViewController3* VC = [[ViewController3 alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    [_viewController mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(300);
        make.height.mas_equalTo(40);
    }];
    
    [_viewController2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.centerX.equalTo(self.view);
        //fengchiwei 这是相对其他同层view的写法
        make.top.equalTo(_viewController.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    
    [_viewController3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.centerX.equalTo(self.view);
        //fengchiwei 这是相对其他同层view的写法
        make.top.equalTo(_viewController2.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    // 获取键盘基本信息（动画时长与键盘高度）
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(rect);
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 修改下边距约束
    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-keyboardHeight);
    }];
    
    // 更新约束
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    // 获得键盘动画时长
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 修改为以前的约束（距下边距0）
    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
    }];
    
    // 更新约束
    [UIView animateWithDuration:keyboardDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
