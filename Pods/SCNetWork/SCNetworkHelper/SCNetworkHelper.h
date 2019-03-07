//
//  SCNetworkHelper.h
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

@class SCNetworkConfig;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SCRequestMethod) {
    //GET
    SCRequestMethodGET = 0,
    //HEAD
    SCRequestMethodHEAD,
    //POST
    SCRequestMethodPOST,
    //PUT
    SCRequestMethodPUT,
    //PATCH
    SCRequestMethodPATCH,
    //DELETE
    SCRequestMethodDELETE
};

/**
 请求成功的回调
 
 @param responseObject 返回请求到的数据
 */
typedef void(^SCHttpRequestSuccess)(id responseObject);

/**
 请求失败的回调
 
 @param error 返回失败信息
 */
typedef void(^SCHttpRequestFailed)(NSError *error);

/**
 上传或者下载的进度
 
 @param progress 返回进度类 Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
 */
typedef void(^SCHttpProgress)(NSProgress *progress);


/**
 将默认的配置给到外面
 
 @param configuration 默认配置类
 */
typedef void(^configurationHandler)(SCNetworkConfig *configuration);

@interface SCNetworkHelper : NSObject
/**
 当前的网络状态
 */
@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;
/**
 上层的请求配置，通过该属性传递，保证该类内部不处理上层的逻辑
 */
@property(nonatomic, strong) SCNetworkConfig * _Nullable configuration;

/**
 网络请求单利
 
 @return 网络请求单利
 */
+ (instancetype _Nullable )sharedInstance;
/**
 网络请求主要方法
 
 @param method 请求类型 默认为GET
 @param URLString URL地址，不包含baseURL
 @param parameters 请求参数
 @param config 配置请求
 @param success 请求成功
 @param failure 请求失败
 @return 返回该请求的任务管理者，用于取消该次请求
 */
- (NSURLSessionDataTask *)requestMethod:(SCRequestMethod)method
                              URLString:(NSString *_Nullable)URLString
                             parameters:(NSDictionary *_Nullable)parameters
                   configurationHandler:(configurationHandler _Nullable)config
                                success:(SCHttpRequestSuccess _Nullable)success
                                failure:(SCHttpRequestFailed _Nullable)failure;


/**
 上传资源主要方法
 
 @param URLString URL地址，不包含baseURL
 @param parameters 请求参数
 @param uploadData 要上传的资源，这里没有区分上传文件还是图片，可以自定义
 @param config 配置请求
 @param progress 上传进度
 @param success 请求成功
 @param failure 请求失败
 @return 返回的对象可取消请求,调用cancel方法
 */
- (NSURLSessionTask *)uploadWithURLString:(NSString *_Nullable)URLString
                               parameters:(NSDictionary *_Nullable)parameters
                constructingBodyWithBlock:(void (^_Nullable)(id <AFMultipartFormData> _Nullable formData))uploadData
                     configurationHandler:(configurationHandler _Nullable)config
                                 progress:(SCHttpProgress _Nullable)progress
                                  success:(SCHttpRequestSuccess _Nullable )success
                                  failure:(SCHttpRequestFailed _Nullable )failure;


/**
 上传文件
 
 @param URLString URL地址，不包含baseURL
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件本地的沙盒路径
 @param config 配置请求
 @param progress 上传进度
 @param success 请求成功
 @param failure 请求失败
 @return 返回的对象可取消请求,调用cancel方法
 */

- (NSURLSessionTask *)uploadFileWithURLString:(NSString *_Nullable)URLString
                                   parameters:(NSDictionary *_Nullable)parameters
                                         name:(NSString *)name
                                     filePath:(NSString *)filePath
                         configurationHandler:(configurationHandler _Nullable)config
                                     progress:(SCHttpProgress)progress
                                      success:(SCHttpRequestSuccess)success
                                      failure:(SCHttpRequestFailed)failure;


/**
 上传图片
 
 @param URLString URL地址，不包含baseURL
 @param parameters 请求参数
 @param names 图片对应服务器上的字段
 @param images 图片数组
 @param fileNames 图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 @param imageType 图片文件的类型,例:png、jpg(默认类型)....
 @param config 配置请求
 @param progress 上传进度
 @param success 请求成功
 @param failure 请求失败
 @return 返回的对象可取消请求,调用cancel方法
 */
- (NSURLSessionTask *)uploadImagesWithURLString:(NSString *_Nullable)URLString
                                     parameters:(NSDictionary *_Nullable)parameters
                                          names:(NSArray *)names
                                         images:(NSArray<UIImage *> *)images
                                      fileNames:(NSArray<NSString *> *)fileNames
                                     imageScale:(CGFloat)imageScale
                                      imageType:(NSString *)imageType
                           configurationHandler:(configurationHandler _Nullable)config
                                       progress:(SCHttpProgress)progress
                                        success:(SCHttpRequestSuccess)success
                                        failure:(SCHttpRequestFailed)failure;

/**
 下载资源
 
 @param URLString URL地址，不包含baseURL
 @param fileDirectory 文件存储目录(默认存储目录为Download)
 @param config 配置请求
 @param progress 下载进度
 @param success 请求成功
 @param failure 请求失败
 @return 返回该请求的任务管理者，用于取消该次请求
 */
- (NSURLSessionTask *)downloadWithURLString:(NSString *_Nullable)URLString
                              fileDirectory:(NSString *)fileDirectory
                       configurationHandler:(configurationHandler _Nullable)config
                                   progress:(SCHttpProgress)progress
                                    success:(SCHttpRequestSuccess)success
                                    failure:(SCHttpRequestFailed)failure;
/**
 取消所有请求
 */
- (void)cancelAllRequest;

/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发
 的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外
 一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */

- (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;
@end

NS_ASSUME_NONNULL_END
