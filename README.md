# SCNetWork
基于AFN3.2.1网络请求封装，实现网络请求，上传文件，上传多图片，下载功能。

## demo

![效果图](test.png)

## 特点

* 适用于大部分网络请求使用场景（请求，上传，下载，缓存）
* 全局配置所有请求的公共信息，适应不同需求
* 对网络请求做拦截，统一处理业务逻辑
* 支持自定义缓存策略，支持设置缓存有效时间

## 安装说明

#### CocoaPods

在你工程的 `Podfile` 文件中添加如下一行，并执行 `pod install` 或 `pod update`。

```
pod 'SCNetWork', '~> 0.0.2'
```

**注意：** `XMNetworking` 会自动依赖 `AFNetworking`  和 `YYCache` ，所以你工程里的 `Podfile` 文件**无需**再添加 。

## 联系

Email：15756377633@163.com
Wechat：v268743

## License

The SCNetWork project is available for free use, as described by the LICENSE (Apache 2.0).
