//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.

//官方Demo添加中文注释--XanderXu
//https://github.com/XanderXu/WebViewJavascriptBridge.git

#import "ExampleUIWebViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ExampleUIWebViewController ()
@property WebViewJavascriptBridge* bridge;
@end

@implementation ExampleUIWebViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) { return; }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    // 开启日志，方便调试
    [WebViewJavascriptBridge enableLogging];
    // 给哪个webview建立JS与OjbC的沟通桥梁
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    //注册oc方法名,,用来给js调用
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback js传过来的data: %@", data);
        responseCallback(@"OC方法testObjcCallback的响应response");
    }];
    
    //页面一出现就调用js的testJavascriptHandler方法,并传过去参数data
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    //添加两个OC的按钮
    [self renderButtons:webView];
    //载入html页面
    [self loadExamplePage:webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

//添加两个OC的按钮
- (void)renderButtons:(UIWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    //OC按钮,点击调用js
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"OC按钮,调用js" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 140, 35);
    callbackButton.titleLabel.font = font;
    
    //刷新按钮,点击刷新webview
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"刷新webview" forState:UIControlStateNormal];
    //调用UIWebView的reload方法,重新载入页面
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(150, 400, 140, 35);
    reloadButton.titleLabel.font = font;
}
//点击OC按钮时,用bridge调用js方法
- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    //调用js的testJavascriptHandler方法,传入data参数,并拿到js的响应response
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler js的响应: %@", response);
    }];
}

//载入网页ExampleApp.html
- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
