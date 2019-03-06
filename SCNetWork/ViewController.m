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
    // Do any additional setup after loading the view, typically from a nib.
    self.requestConvertManager = [SCNetworkHelper sharedInstance];
    self.requestConvertManager.configuration.baseURL = @"xxxxxx";
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
    
    NSDictionary *params = @{@"ip":@"123"};
    [self.requestConvertManager requestMethod:SCRequestMethodGET URLString:@"" parameters:params configurationHandler:^(SCNetworkConfig * _Nonnull configuration) {
        
    } success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


@end
