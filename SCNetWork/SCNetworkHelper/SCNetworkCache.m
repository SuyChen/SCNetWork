//
//  SCNetworkCache.m
//  SCNetWork
//
//  Created by CSY on 2019/3/7.
//  Copyright © 2019 suychen. All rights reserved.
//

#import "SCNetworkCache.h"
#import "YYCache.h"

static NSString *const SCCacheDurationKey = @"SCCacheDurationKey";

static YYCache *_dataCache;

@implementation SCNetworkCache

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:@"httpDB"];
}
/**
 写入缓存
 */
+ (void)setHttpCache:(id)httpData
           URLString:(NSString *)URLString
          parameters:(NSDictionary *)parameters
{
    
    NSString *cacheKey = [self cacheKeyWithURL:URLString parameters:parameters];
    //写入缓存
    [_dataCache setObject:httpData forKey:cacheKey];
    //写入缓存时间，用于后面判断缓存是否过期
    [self setCacheTimeWithCacheKey:cacheKey];
    
}

/**
 获取缓存
 */
+ (id)getHttpCacheForCacheValidTime:(NSTimeInterval)cacheValidTime
                          URLString:(NSString *)URLString
                         parameters:(NSDictionary *)parameters
{
    NSString *cacheKey = [self cacheKeyWithURL:URLString parameters:parameters];
    
    id cacheData = [_dataCache objectForKey:cacheKey];
    
    if (!cacheData) {
        return nil;
    }
    //判断缓存时间是否过期
    if ([self verifyInvalidCache:cacheKey resultCacheDuration:cacheValidTime]) {
        
        return cacheData;
        
    }else{
        //清除缓存
        [_dataCache removeObjectForKey:cacheKey];
        NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, SCCacheDurationKey];
        [_dataCache removeObjectForKey:cacheDurationKey];
        return nil;
    }
}
+ (NSInteger)getAllHttpCacheSize {
    return [_dataCache.diskCache totalCost];
}
+ (void)removeAllHttpCache {
    
    [_dataCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
        NSLog(@"删除数量 = %d ，总数量 = %d",removedCount , totalCount);
    } endBlock:^(BOOL error) {
        NSLog(@"删除http完成 = %d",error);
    }];
}

+ (void)removeHttpCacheWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters{
    
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:parameters];
    [_dataCache removeObjectForKey:cacheKey withBlock:^(NSString * _Nonnull key) {
        
    }];
}
#pragma mark == Tool
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return [NSString stringWithFormat:@"%@",cacheKey];
}

/**
 写入缓存时间
 
 @param cacheKey 缓存时间的key
 */
+ (void)setCacheTimeWithCacheKey:(NSString *)cacheKey{
    
    NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, SCCacheDurationKey];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    //    NSTimeInterval invalidTime = nowTime + resultCacheDuration;
    [_dataCache setObject:@(nowTime) forKey:cacheDurationKey withBlock:nil];
}

/**
 判断缓存是否有效，有效则返回YES
 */
+ (BOOL)verifyInvalidCache:(NSString *)cacheKey
       resultCacheDuration:(NSTimeInterval )resultCacheDuration{
    //获取该次请求失效的时间戳
    NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, SCCacheDurationKey];
    id oldTime = [_dataCache objectForKey:cacheDurationKey];
    NSTimeInterval oldTimeInterval = [oldTime doubleValue];
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if ((nowTimeInterval - oldTimeInterval) < resultCacheDuration) {
        return YES;
    }
    return NO;
}
@end
