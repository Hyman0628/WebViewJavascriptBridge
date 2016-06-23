WebViewJavascriptBridge
=======================

###给官方示例Demo添加了中文注释,方便大家阅读学习
Usage
-----

1) 导入头文件,声明变量:

```objc
#import "WebViewJavascriptBridge.h"
```

...

```objc
@property WebViewJavascriptBridge* bridge;
```

2) 用 UIWebView (iOS) or WebView (OSX)来初始化 WebViewJavascriptBridge :

```objc
self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
```

3) 在OC中注册事件句柄,调用JS句柄:

```objc
[self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"ObjC Echo called with: %@", data);
	responseCallback(data);
}];
[self.bridge callHandler:@"JS Echo" responseCallback:^(id responseData) {
	NSLog(@"ObjC received response: %@", responseData);
}];
```

4)复制粘贴 `setupWebViewJavascriptBridge` 到JS中:
	
```javascript
function setupWebViewJavascriptBridge(callback) {
	if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
	if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
	window.WVJBCallbacks = [callback];
	var WVJBIframe = document.createElement('iframe');
	WVJBIframe.style.display = 'none';
	WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
	document.documentElement.appendChild(WVJBIframe);
	setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}
```

5) 最后, 调用 `setupWebViewJavascriptBridge` 并使用bridge 注册事件句柄,来调用OC句柄:

```javascript
setupWebViewJavascriptBridge(function(bridge) {
	
	/* Initialize your app here */

	bridge.registerHandler('JS Echo', function(data, responseCallback) {
		console.log("JS Echo called with:", data)
		responseCallback(data)
	})
	bridge.callHandler('ObjC Echo', function responseCallback(responseData) {
		console.log("JS received response:", responseData)
	})
})
```

支持WKWebView (iOS 8+ & OS 10.10+)
--------------------------------------

(WARNING: WKWebView still has [bugs and missing network APIs.](https://github.com/ShingoFukuyama/WKWebViewTips/blob/master/README.md) It may not be a simple drop-in replacement).

WebViewJavascriptBridge supports [WKWebView](http://nshipster.com/wkwebkit/) for iOS 8 and OSX Yosemite. In order to use WKWebView you need to instantiate the `WKWebViewJavascriptBridge`. The rest of the `WKWebViewJavascriptBridge` API is the same as `WebViewJavascriptBridge`.

1) 导入头文件:

```objc
#import "WKWebViewJavascriptBridge.h"
```

2) 用 WKWebView 对象初始化 WKWebViewJavascriptBridge 

```objc
WKWebViewJavascriptBridge* bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
```
*************************


Automatic reference counting (ARC)
----------------------------------
This library relies on ARC, so if you use ARC in you project, all works fine.
But if your project have no ARC support, be sure to do next steps:

本框架依赖于ARC,如果你是ARC的项目,那么一切正常.但是如果你的项目不支持ARC,请按下列步骤操作:

1) In your Xcode project open project settings -> 'Build Phases'

1)在Xcode项目中打开project settings -> 'Build Phases'

2) Expand 'Compile Sources' header and find all *.m files which are belongs to this library. Make attention on the 'Compiler Flags' in front of each source file in this list

2)展开'Compile Sources'标题,找到所有属于本框架的*.m文件.注意列表中每个源文件前面的'Compiler Flags'

3) For each file add '-fobjc-arc' flag

3)为每个文件添加'-fobjc-arc'

Now all WVJB files will be compiled with ARC support.

现在所有的WVJB文件都能编译支持ARC了

Contributors & Forks
--------------------
Contributors: https://github.com/marcuswestin/WebViewJavascriptBridge/graphs/contributors

Forks: https://github.com/marcuswestin/WebViewJavascriptBridge/network/members

API Reference
-------------

### ObjC API

##### `[WebViewJavascriptBridge bridgeForWebView:(UIWebView/WebView*)webview`

Create a javascript bridge for the given web view.

为指定的web view创建javascript bridge

Example:

```objc	
[WebViewJavascriptBridge bridgeForWebView:webView];
```

##### `[bridge registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler]`

Register a handler called `handlerName`. The javascript can then call this handler with `WebViewJavascriptBridge.callHandler("handlerName")`.

注册名为`handlerName`的句柄.这样javascript就能在`WebViewJavascriptBridge.callHandler("handlerName")`中调用这个句柄

Example:

```objc
[self.bridge registerHandler:@"getScreenHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
	responseCallback([NSNumber numberWithInt:[UIScreen mainScreen].bounds.size.height]);
}];
[self.bridge registerHandler:@"log" handler:^(id data, WVJBResponseCallback responseCallback) {
	NSLog(@"Log: %@", data);
}];

```

##### `[bridge callHandler:(NSString*)handlerName data:(id)data]`
##### `[bridge callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)callback]`

Call the javascript handler called `handlerName`. If a `responseCallback` block is given the javascript handler can respond.

调用javascript中名为`handlerName`的句柄.如果`responseCallback`这个block有值,那么javascript句柄会回调

Example:

```objc
[self.bridge callHandler:@"showAlert" data:@"Hi from ObjC to JS!"];
[self.bridge callHandler:@"getCurrentPageUrl" data:nil responseCallback:^(id responseData) {
	NSLog(@"Current UIWebView page URL is: %@", responseData);
}];
```

#### `[bridge setWebViewDelegate:UIWebViewDelegate*)webViewDelegate]`

Optionally, set a `UIWebViewDelegate` if you need to respond to the [web view's lifecycle events](http://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html).




### Javascript API

##### `bridge.registerHandler("handlerName", function(responseData) { ... })`

Register a handler called `handlerName`. The ObjC can then call this handler with `[bridge callHandler:"handlerName" data:@"Foo"]` and `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`

注册名为`handlerName`的句柄.这样ObjC就能在 `[bridge callHandler:"handlerName" data:@"Foo"]` 和 `[bridge callHandler:"handlerName" data:@"Foo" responseCallback:^(id responseData) { ... }]`中调用这个句柄

Example:

```javascript
bridge.registerHandler("showAlert", function(data) { alert(data) })
bridge.registerHandler("getCurrentPageUrl", function(data, responseCallback) {
	responseCallback(document.location.toString())
})
```


##### `bridge.callHandler("handlerName", data)`
##### `bridge.callHandler("handlerName", data, function responseCallback(responseData) { ... })`

Call an ObjC handler called `handlerName`. If a `responseCallback` function is given the ObjC handler can respond.

调用OC中名为`handlerName`的句柄.如果`responseCallback`函数有值,那么OC句柄会回调

Example:

```javascript
bridge.callHandler("Log", "Foo")
bridge.callHandler("getScreenHeight", null, function(response) {
	alert('Screen height:' + response)
})
```
