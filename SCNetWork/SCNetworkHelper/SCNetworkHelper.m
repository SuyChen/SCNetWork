//
//  SCNetworkHelper.m
//  SCNetWork
//
//  Created by CSY on 2019/3/5.
//  Copyright © 2019 suychen. All rights reserved.
//

#import "SCNetworkHelper.h"
#import "SCNetworkConfig.h"

@interface SCNetworkHelper ()
/**
 是AFURLSessionManager的子类，为HTTP的一些请求提供了便利方法，当提供baseURL时，请求只需要给出请求的路径即可
 */
@property (nonatomic, strong) AFHTTPSessionManager *requestManager;

/**
 将SCRequestMethod（NSInteger）类型转换成对应的方法名（NSString）
 */
@property (nonatomic, strong) NSDictionary *methodMap;
@end
@implementation SCNetworkHelper

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
#pragma mark == 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configInit];
    }
    return self;
}
- (void)configInit
{
    //网络状况检测
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.networkStatus = status;
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //初始化配置文件
    self.configuration = [[SCNetworkConfig alloc] init];
    //简历方法对应关系
    self.methodMap = @{
                       @"0" : @"GET",
                       @"1" : @"HEAD",
                       @"2" : @"POST",
                       @"3" : @"PUT",
                       @"4" : @"PATCH",
                       @"5" : @"DELETE"
                       };
}
#pragma mark == 懒加载
- (AFHTTPSessionManager *)requestManager
{
    if (!_requestManager) {
        _requestManager = [AFHTTPSessionManager manager];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _requestManager.securityPolicy = securityPolicy;
    }
    return _requestManager;
}
#pragma mark == 接口管理
- (NSURLSessionDataTask *)requestMethod:(SCRequestMethod)method
                              URLString:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                   configurationHandler:(configurationHandler)config
                                success:(SCHttpRequestSuccess)success
                                failure:(SCHttpRequestFailed)failure
{
    SCNetworkConfig *configuration = [self disposeConfiguration:config];
    
    if (!URLString) {
        URLString = @"";
    }
    
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:configuration.baseURL]] absoluteString];
    
    parameters = [self disposeRequestParameters:parameters];
    
    //防止数组越界
    if (method > self.methodMap.count - 1) {
        method = self.methodMap.count - 1;
    }
    NSString *methodkey = [NSString stringWithFormat:@"%ld", method];
    NSURLRequest *request = [self.requestManager.requestSerializer
                             requestWithMethod:self.methodMap[methodkey]
                             URLString:requestUrl
                             parameters:parameters
                             error:nil];
    __block NSURLSessionDataTask *dataTask = [self.requestManager
                                              dataTaskWithRequest:request
                                              uploadProgress:nil
                                              downloadProgress:nil
                                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                  if (error) {
                                                      failure(error);
                                                  }else{
                                                      
                                                      //将返回的数据做一层数据拦截
                                                      if (configuration.resposeHandle) {
                                                          responseObject = configuration.resposeHandle(dataTask, responseObject);
                                                      }
                                                      success(responseObject);
                                                  }
                                                  
                                              }];
    [dataTask resume];
    return dataTask;
    
}
- (NSURLSessionTask *)uploadWithURLString:(NSString *_Nullable)URLString
                                        parameters:(NSDictionary *_Nullable)parameters
                         constructingBodyWithBlock:(void (^_Nullable)(id <AFMultipartFormData> _Nullable formData))uploadData
                              configurationHandler:(configurationHandler _Nullable)config
                                          progress:(SCHttpProgress _Nullable)progress
                                           success:(SCHttpRequestSuccess _Nullable )success
                                           failure:(SCHttpRequestFailed _Nullable )failure
{
    SCNetworkConfig *configuration = [self disposeConfiguration:config];
    parameters = [self disposeRequestParameters:parameters];
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString: configuration.baseURL]] absoluteString];
    NSURLSessionDataTask *dataTask = [self.requestManager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        uploadData(formData);
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionTask *)uploadFileWithURLString:(NSString *_Nullable)URLString
                                   parameters:(NSDictionary *_Nullable)parameters
                                         name:(NSString *)name
                                     filePath:(NSString *)filePath
                         configurationHandler:(configurationHandler _Nullable)config
                                     progress:(SCHttpProgress)progress
                                      success:(SCHttpRequestSuccess)success
                                      failure:(SCHttpRequestFailed)failure
{
    SCNetworkConfig *configuration = [self disposeConfiguration:config];
    parameters = [self disposeRequestParameters:parameters];
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString: configuration.baseURL]] absoluteString];
    NSURLSessionDataTask *dataTask = [self.requestManager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionTask *)uploadImagesWithURLString:(NSString *_Nullable)URLString
                                     parameters:(NSDictionary *_Nullable)parameters
                                           name:(NSString *)name
                                         images:(NSArray<UIImage *> *)images
                                      fileNames:(NSArray<NSString *> *)fileNames
                                     imageScale:(CGFloat)imageScale
                                      imageType:(NSString *)imageType
                           configurationHandler:(configurationHandler _Nullable)config
                                       progress:(SCHttpProgress)progress
                                        success:(SCHttpRequestSuccess)success
                                        failure:(SCHttpRequestFailed)failure
{
    SCNetworkConfig *configuration = [self disposeConfiguration:config];
    parameters = [self disposeRequestParameters:parameters];
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString: configuration.baseURL]] absoluteString];
    NSURLSessionDataTask *dataTask = [self.requestManager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSUInteger i = 0; i < images.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
            // 默认图片的文件名, 若fileNames为nil就使用
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str,i,imageType?:@"jpg"];
            
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ?  [NSString stringWithFormat:@"%@.%@",fileNames[i],imageType?:@"jpg"] : imageFileName
                                    mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionTask *)downloadWithURLString:(NSString *_Nullable)URLString
                              fileDirectory:(NSString *)fileDirectory
                       configurationHandler:(configurationHandler _Nullable)config
                                   progress:(SCHttpProgress)progress
                                    success:(SCHttpRequestSuccess)success
                                    failure:(SCHttpRequestFailed)failure
{
    SCNetworkConfig *configuration = [self disposeConfiguration:config];
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString: configuration.baseURL]] absoluteString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
   __block NSURLSessionDownloadTask *dataTask = [self.requestManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
         progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDirectory ? fileDirectory : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failure(error);
        }else{
            if (configuration.resposeHandle) {
                filePath = configuration.resposeHandle(dataTask, filePath);
            }
            success(filePath);
        }
    }];
    [dataTask resume];
    return dataTask;
}

- (void)cancelAllRequest {
    [self.requestManager invalidateSessionCancelingTasks:YES];
}
#pragma mark == 内部方法

/**
 这里把通过属性设置的请求体和传值过来的请求体做了统一处理

 @param parameters 传值的请求体
 @return 处理后的请求体
 */
- (NSDictionary *)disposeRequestParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *bodys = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (self.configuration.builtinBodys.count > 0) {
        for (NSString *key in self.configuration.builtinBodys) {
            [bodys setObject:self.configuration.builtinBodys[key] forKey:key];
        }
    }
    return bodys.copy;
}

/**
 这里把通过属性设置的请求配置和传值过来的配置做统一处理 传值的优先级更高

 @param config 传值的请求配置
 @return 处理后的配置
 */
- (SCNetworkConfig *)disposeConfiguration:(configurationHandler)config {
 
    SCNetworkConfig *configuration = [self.configuration copy];
    //block回调设置configuration
    if (config) {
        config(configuration);
    }
    self.requestManager.requestSerializer = configuration.requestSerializer;
    self.requestManager.responseSerializer = configuration.responseSerializer;
    //请求头
    if (configuration.builtinHeaders.count > 0) {
        for (NSString *key in configuration.builtinHeaders) {
            [self.requestManager.requestSerializer setValue:configuration.builtinHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    [self.requestManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    if (configuration.timeoutInterval > 0) {
        self.requestManager.requestSerializer.timeoutInterval = configuration.timeoutInterval;
    }
    else {
        self.requestManager.requestSerializer.timeoutInterval = SCRequestTimeoutInterval;
    }
    [self.requestManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    return configuration;
}
@end
