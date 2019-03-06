//
//  SCNetworkConfig.m
//  SCNetWork
//
//  Created by CSY on 2019/3/5.
//  Copyright © 2019 suychen. All rights reserved.
//

#import "SCNetworkConfig.h"

const CGFloat SCRequestTimeoutInterval = 15.0f;

@implementation SCNetworkConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeoutInterval = SCRequestTimeoutInterval;
    }
    return self;
}

- (AFHTTPRequestSerializer *)requestSerializer
{
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
        _requestSerializer.timeoutInterval =  _timeoutInterval;
    }
    return _requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializer
{
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SCNetworkConfig *configuration = [[SCNetworkConfig alloc] init];
    configuration.baseURL = [self.baseURL copy];
    configuration.builtinHeaders = [self.builtinHeaders copy];
    configuration.builtinBodys = [self.builtinBodys copy];
    configuration.resposeHandle = [self.resposeHandle copy];
    configuration.requestSerializer = [self.requestSerializer copy];
    configuration.responseSerializer = [self.responseSerializer copy];
    configuration.responseSerializer.acceptableContentTypes = self.responseSerializer.acceptableContentTypes;
    return configuration;
}
@end
