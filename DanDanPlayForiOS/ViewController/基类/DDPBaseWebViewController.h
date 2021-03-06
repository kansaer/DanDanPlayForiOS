//
//  DDPBaseWebViewController.h
//  BiliBili
//
//  Created by apple-jd44 on 15/10/28.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"
#import <WebKit/WebKit.h>

@interface DDPBaseWebViewController : DDPBaseViewController<WKNavigationDelegate, WKUIDelegate>
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithRequest:(NSURLRequest *)request;
/**
 显示顶部的进度条 默认YES
 */
@property (assign, nonatomic) BOOL showProgressView;

@property (copy, nonatomic) void(^clickMagnetCallBack)(NSString *);
@end
