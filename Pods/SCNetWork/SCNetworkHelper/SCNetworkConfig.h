//
//  SCNetworkConfig.h
//  SCNetWork
//
//  Created by CSY on 2019/3/5.
//  Copyright © 2019 suychen. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat SCRequestTimeoutInterval;

typedef NS_ENUM(NSInteger, SCCachePolicy) {
    //先检查是否有缓存，没有则请求数据并缓存
    SCCachePolicyCacheOrLoad,
    //直接请求数据不做缓存
    SCCachePolicyLoadWithoutCache,
    //可扩展新的缓存策略
    SCCachePolicyWaitToADD
    
};

/**
 网络请求配置类
 */
@interface SCNetworkConfig : NSObject
/**
 所有请求都带的前缀 也可以直接写在urlstring里面
 */
@property (nonatomic, copy, nullable) NSString *baseURL;
/**
 请求的一些配置（默认不变的信息），比如：缓存机制、请求超时、请求头信息等配置
 */
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
/**
 对返回的数据进行序列化，默认使用 AFJSONResponseSerializer，支持AFJSONResponseSerializer、AFXMLParserResponseSerializer、AFXMLDocumentResponseSerializer等
 */
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;
/**
 请求的头部通用配置
 */
@property (nonatomic, strong) NSMutableDictionary *builtinHeaders;
/**
 请求体通用配置
 */
@property (nonatomic, strong) NSMutableDictionary *builtinBodys;
/**
 请求超时时间设置，默认15秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/**
 对请求返回的数据做统一的处理，比如token失效、重新登录等等操作。
 */
@property (nonatomic, copy) id (^ resposeHandle)(NSURLSessionTask *dataTask, id responseObject);
/**
 设置缓存时间，默认86400秒（24小时）。如果 <= 0，表示不启用缓存。单位为秒，表示对于一个请求的结果缓存多长时间
 如果需要根据请求内容做缓存更新的话需要跟后台商议
 */
@property (nonatomic, assign) NSInteger resultCacheDuration;
/**
 缓存策略, 默认是SCCachePolicyCacheOrLoad
 */
@property (nonatomic, assign) SCCachePolicy requestCachePolicy;


@end

NS_ASSUME_NONNULL_END
