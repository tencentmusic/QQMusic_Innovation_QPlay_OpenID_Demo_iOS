### 如何配置

本Demo演示如何使用QQ音乐OpenID方案，请在编译之前，务必修改业务参数。

根据QQ音乐提供的OpenID参数，在`ViewController.m`中修改如下变量：

``` objective-c
static NSString * const OPENID_APP_PRIVATEKEY = @"";
static NSString * const OPENID_APPID = @"";
static NSString * const OPENID_PACKAGENAME = @""
```

并请一并修改工程设置里的`Bundle Identifier`的取值，与注册在QQ音乐的PackageName保持一致。

请一定注意：**上述三个数值一定来自OpenID业务，不要与OpenAPI业务混淆**。

本Demo还显示了个别QQ音乐OpenAPI接口如何使用，如要体验，请根据OpenAPI(非OpenID)的值，在`ViewController.m`中修改如下变量：

``` objective-c
static NSString * const OPENAPI_APPID = @"";
static NSString * const OPENAPI_APPKEY = @"";
static NSString * const OPENAPI_APPPRIVATEKEY = @"";
```





