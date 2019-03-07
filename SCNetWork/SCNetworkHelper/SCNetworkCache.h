//
//  SCNetworkCache.h
//  SCNetWork
//
//  Created by CSY on 2019/3/7.
//  Copyright © 2019 suychen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCNetworkCache : NSObject

/**
 异步缓存网络数据 URL与parameters
 做KEY存储数据, 保证key的唯一性
 
 @param httpData 服务器返回的数据
 @param URLString 请求的URL地址
 @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData
           URLString:(NSString *)URLString
          parameters:(NSDictionary *)parameters;


/**
 获取缓存数据
 
 @param cacheValidTime 根据这个时间判断缓存是否过期
 @param URLString 请求的URL地址
 @param parameters 请求的参数
 @return 服务器数据
 */
+ (id)getHttpCacheForCacheValidTime:(NSTimeInterval)cacheValidTime
                          URLString:(NSString *)URLString
                         parameters:(NSDictionary *)parameters;

/**
 获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;

/**
 删除所有网络缓存
 */
+ (void)removeAllHttpCache;

/**
 根据key删除缓存
 
 @param url 和parameters组成key
 @param parameters 和url组成key
 */
+ (void)removeHttpCacheWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
