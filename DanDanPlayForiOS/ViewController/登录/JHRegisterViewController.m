//
//  JHRegisterViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHRegisterViewController.h"
#import "JHLinkOriginalAccountViewController.h"

#import "JHTextField.h"
#import "JHBaseScrollView.h"
#import "JHEmailListView.h"
#import "UIApplication+Tools.h"
#import "NSString+Tools.h"
#import "JHEdgeButton.h"
#import "UIApplication+Tools.h"

@interface JHRegisterViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) JHTextField *accountTextField;
@property (strong, nonatomic) JHTextField *userNameTextField;
@property (strong, nonatomic) JHTextField *passwordTextField;
@property (strong, nonatomic) JHTextField *emailTextField;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) JHEmailListView *emailListView;
@property (strong, nonatomic) JHBaseScrollView *scrollView;
@property (strong, nonatomic) JHEdgeButton *linkButton;
@end

@implementation JHRegisterViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.user != nil) {
        self.navigationItem.title = @"快速注册并关联";
        self.linkButton.hidden = NO;
    }
    else {
        self.navigationItem.title = @"注册";
        self.linkButton.hidden = YES;
    }
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.emailListView.alpha = 1;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.1 animations:^{
        self.emailListView.alpha = 0;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //完整的输入内容
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text containsString:@"@"] && string.length > 0) {
        //用户输入的后缀
        NSString *lastStr = [updatedString componentsSeparatedByString:@"@"].lastObject;
        //获取建议邮箱后缀
        NSString *adviseStr = [self.emailListView adviseEmailWithInputString:lastStr];
        if (adviseStr.length) {
            textField.text = [[updatedString componentsSeparatedByString:@"@"].firstObject stringByAppendingFormat:@"@%@", adviseStr];
            
            //选中添加的部分
            UITextPosition *endDocument = textField.endOfDocument;
            UITextPosition *end = [textField positionFromPosition:endDocument offset:0];
            //偏移用户输入的字符串长度
            UITextPosition *start = [textField positionFromPosition:end offset:-adviseStr.length + lastStr.length];
            textField.selectedTextRange = [textField textRangeFromPosition:start toPosition:end];
            
            return NO;
        }
    }
    
    //更新邮箱列表
    if ([updatedString containsString:@"@"]) {
        [self.emailListView setInputString:[updatedString componentsSeparatedByString:@"@"].firstObject];
    }
    else {
        [self.emailListView setInputString:updatedString];
    }
    
    return YES;
}

#pragma mark - 私有方法
- (void)touchRegisterButton:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString *account = self.accountTextField.textField.text;
    NSString *password = self.passwordTextField.textField.text;
    NSString *name = self.userNameTextField.textField.text;
    NSString *email = self.emailTextField.textField.text;
    
    if (account.length == 0) {
        [MBProgressHUD showWithText:@"请输入账号！"];
        return;
    }
    
    if ([account isRightAccount] == NO) {
        [MBProgressHUD showWithText:[NSString stringWithFormat:@"账号为%d~%d位的英文数字下划线！", USER_ACCOUNT_MIN_COUNT, USER_ACCOUNT_MAX_COUNT]];
        return;
    }
    
    if (password.length == 0) {
        [MBProgressHUD showWithText:@"请输入密码！"];
        return;
    }
    
    if ([password isRightPassword] == NO) {
        [MBProgressHUD showWithText:[NSString stringWithFormat:@"密码为%d~%d位！", USER_PASSWORD_MIN_COUNT, USER_PASSWORD_MAX_COUNT]];
        return;
    }
    
    if (name.length == 0) {
        [MBProgressHUD showWithText:@"请输入昵称！"];
        return;
    }
    
    if ([name isRightNickName] == NO) {
        [MBProgressHUD showWithText:[NSString stringWithFormat:@"昵称最长%d个字符！", USER_NAME_MAX_COUNT]];
        return;
    }
    
    if (email.length == 0) {
        [MBProgressHUD showWithText:@"请输入邮箱！"];
        return;
    }
    
    if ([email isRightEmail] == NO) {
        [MBProgressHUD showWithText:@"邮箱格式不正确！"];
        return;
    }
    
    JHRegisterRequest *request = [[JHRegisterRequest alloc] init];
    request.name = name;
    request.account = account;
    request.password = password;
    request.email = email;
    if (self.user != nil) {
        request.userId = self.user.identity > 0 ? [NSString stringWithFormat:@"%ld", self.user.identity] : nil;
        request.token = self.user.token;
    }
    
    MBProgressHUD *aHud = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeIndeterminate InView:self.view];
    aHud.label.text = @"注册中...";
    
    void(^completionAction)(JHRegisterResponse *, NSError *) = ^(JHRegisterResponse *responseObject, NSError *error) {
        //关联失败
        if (error) {
            [aHud hideAnimated:YES];
            [MBProgressHUD showWithError:error];
        }
        else {
            aHud.label.text = @"登录中...";
            //关联成功自动登录
            [LoginNetManager loginWithSource:JHUserTypeDefault userId:account token:password completionHandler:^(JHUser *responseObject1, NSError *error1) {
                [aHud hideAnimated:YES];
                
                if (error1) {
                    [MBProgressHUD showWithError:error1];
                }
                else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [MBProgressHUD showWithText:@"登录成功！"];
                }
            }];
        }
    };
    
    if (self.user != nil) {
        //快速注册并关联
        [LoginNetManager loginRegisterRelateToThirdPartyWithRequest:request completionHandler:completionAction];
    }
    else {
        //普通注册
        [LoginNetManager loginRegisterWithRequest:request completionHandler:completionAction];
    }
}

- (void)touchLinkButton:(UIButton *)sender {
    JHLinkOriginalAccountViewController *vc = [[JHLinkOriginalAccountViewController alloc] init];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (JHBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[JHBaseScrollView alloc] init];
        [_scrollView addSubview:self.accountTextField];
        [_scrollView addSubview:self.passwordTextField];
        [_scrollView addSubview:self.userNameTextField];
        [_scrollView addSubview:self.emailTextField];
        [_scrollView addSubview:self.linkButton];
        [_scrollView addSubview:self.registerButton];
        [_scrollView addSubview:self.emailListView];
        
        CGFloat edge = 15;
        
        if (self.user != nil) {
            [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_offset(edge);
                make.centerX.mas_equalTo(0);
            }];
            
            [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(_scrollView).mas_offset(-50);
                make.height.mas_equalTo(40);
                make.centerX.mas_equalTo(0);
                make.top.equalTo(self.linkButton.mas_bottom).mas_offset(edge);
            }];
        }
        else {
            [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(_scrollView).mas_offset(-50);
                make.height.mas_equalTo(40);
                make.centerX.mas_equalTo(0);
                make.top.mas_offset(edge);
            }];
        }
        
        [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.centerX.mas_equalTo(self.accountTextField);
            make.top.equalTo(self.accountTextField.mas_bottom).mas_offset(edge);
        }];
        
        [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.centerX.mas_equalTo(self.passwordTextField);
            make.top.equalTo(self.passwordTextField.mas_bottom).mas_offset(edge);
        }];
        
        [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.centerX.mas_equalTo(self.userNameTextField);
            make.top.equalTo(self.userNameTextField.mas_bottom).mas_offset(edge);
        }];
        
        //        [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.right.equalTo(self.emailTextField);
        //            make.top.mas_equalTo(self.emailTextField.mas_bottom).mas_equalTo(10);
        //        }];
        
        [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_scrollView).mas_offset(-30);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(44);
            make.top.equalTo(self.emailTextField.mas_bottom).mas_offset(10);
        }];
        
        [self.emailListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.emailTextField);
            make.bottom.equalTo(self.emailTextField.mas_top);
            make.height.mas_equalTo(44 * 4);
        }];
        
        _scrollView.contentSize = CGSizeMake(self.view.width, self.view.height - self.navigationController.navigationBar.bottom);
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (JHTextField *)accountTextField {
    if (_accountTextField == nil) {
        _accountTextField = [[JHTextField alloc] initWithType:JHTextFieldTypeNormal];
        _accountTextField.textField.placeholder = @"用户名";
        _accountTextField.limit = 20;
    }
    return _accountTextField;
}

- (JHTextField *)userNameTextField {
    if (_userNameTextField == nil) {
        _userNameTextField = [[JHTextField alloc] initWithType:JHTextFieldTypeNormal];
        _userNameTextField.textField.placeholder = @"昵称";
        _userNameTextField.limit = 50;
        _userNameTextField.textField.text = self.user.name;
    }
    return _userNameTextField;
}

- (JHTextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[JHTextField alloc] initWithType:JHTextFieldTypePassword];
        _passwordTextField.textField.placeholder = @"密码";
        _passwordTextField.limit = 20;
        //        [_passwordTextField touchSeeButton:_passwordTextField.rightButton];
    }
    return _passwordTextField;
}

- (JHTextField *)emailTextField {
    if (_emailTextField == nil) {
        _emailTextField = [[JHTextField alloc] initWithType:JHTextFieldTypeNormal];
        _emailTextField.textField.placeholder = @"邮箱（用于找回密码）";
        _emailTextField.textField.delegate = self;
        _emailTextField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _emailTextField;
}

- (UIButton *)registerButton {
    if (_registerButton == nil) {
        _registerButton = [[UIButton alloc] init];
        _registerButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerButton.backgroundColor = MAIN_COLOR;
        [_registerButton setTitle:@"完成注册" forState:UIControlStateNormal];
        _registerButton.layer.cornerRadius = 6;
        _registerButton.layer.masksToBounds = YES;
        [_registerButton addTarget:self action:@selector(touchRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (JHEmailListView *)emailListView {
    if (_emailListView == nil) {
        _emailListView = [[JHEmailListView alloc] init];
        _emailListView.alpha = 0;
        @weakify(self)
        _emailListView.didSelectedRowCallBack = ^(NSString *email) {
            @strongify(self)
            if (!self) return;
            
            self.emailTextField.textField.text = email;
        };
    }
    return _emailListView;
}

- (JHEdgeButton *)linkButton {
    if (_linkButton == nil) {
        _linkButton = [[JHEdgeButton alloc] init];
        [_linkButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _linkButton.titleLabel.font = NORMAL_SIZE_FONT;
        [_linkButton setTitle:[NSString stringWithFormat:@"已经有%@账号？登录并关联", [UIApplication sharedApplication].appDisplayName] forState:UIControlStateNormal];
        [_linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkButton;
}

@end

