//
//  ViewController.m
//  SCNetWork
//
//  Created by CSY on 2019/3/5.
//  Copyright © 2019 suychen. All rights reserved.
//

#import "ViewController.h"
#import "SCNetworking.h"

@interface ViewController ()
@property (nonatomic, strong) SCNetworkHelper *requestConvertManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //最好在封装一层业务层，这里做统一的配置
    self.requestConvertManager = [SCNetworkHelper sharedInstance];
    self.requestConvertManager.configuration.baseURL = @"https://www.sojson.com/";
    self.requestConvertManager.configuration.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    //通过configuration来统一处理输出的数据，比如对token失效处理、对需要重新登录拦截
    self.requestConvertManager.configuration.resposeHandle = ^id (NSURLSessionTask *dataTask, id responseObject) {
        return responseObject;
    };
    
    
}
- (IBAction)SCClickRequest1:(id)sender {
    NSDictionary *params = @{@"city":@"成都"};
    [self.requestConvertManager requestMethod:SCRequestMethodGET URLString:@"open/api/weather/json.shtml" parameters:params configurationHandler:^(SCNetworkConfig * _Nonnull configuration) {
        
        configuration.baseURL = @"https://www.sojson.com/";
        
    } success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (IBAction)SCClickRequest2:(id)sender {
    
    NSDictionary *params = @{@"date":@"2017-12-4"};
    [self.requestConvertManager requestMethod:SCRequestMethodGET URLString:@"open/api/lunar/json.shtml" parameters:params configurationHandler:^(SCNetworkConfig * _Nonnull configuration) {
        
    } success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}
- (IBAction)SCClickDownload:(id)sender {
    
    [self.requestConvertManager downloadWithURLString:@"https://mp4.facecast.xyz/storage1/M05/08/26/aPODC1xGD_-AR9FDAEVnvP77jbU565.mp4" fileDirectory:@"music" configurationHandler:^(SCNetworkConfig * _Nonnull configuration) {
        
        configuration.baseURL = @"";
        
    } progress:^(NSProgress * _Nonnull progress) {
        
        CGFloat percent = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
        NSLog(@"-------%.2f",percent);
        
    } success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)SCClickUpload:(id)sender {
    //自行测试
    [self.requestConvertManager uploadWithURLString:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nullable formData) {
        
    } configurationHandler:^(SCNetworkConfig * _Nonnull configuration) {
        
    } progress:^(NSProgress * _Nonnull progress) {
        
    } success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
