//
//  IPaServerAPI.m
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2015/2/14.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import "IPaServerAPI.h"

@implementation IPaServerAPI
{
    NSURLSessionDataTask *currentAPITask;
}
- (instancetype) init
{
    return nil;
}
- (instancetype)initWithResourceUI:(IPaURLResourceUI*)resourceUI
{
    self = [super init];
    self.resourceUI = resourceUI;
    return self;
}
- (void) api:(NSString *)api Method:(NSString *)method Param:(NSDictionary *)aParam success:(IPaURLResourceUISuccessHandler)success
     failure:(void (^)(NSError *error))failure {
    if (currentAPITask != nil && currentAPITask.state == NSURLSessionTaskStateRunning) {
        [currentAPITask cancel];
    }
    method = [method uppercaseString];
    if ([method isEqualToString:@"GET"]) {
        currentAPITask = [self.resourceUI apiGet:api param:aParam onComplete:success failure:failure];
    }
    else if ([method isEqualToString:@"POST"]) {
        currentAPITask = [self.resourceUI apiPost:api param:aParam onComplete:success failure:failure];
    }
    
}
-(void) api:(NSString*)api putJSON:(id)jsonObject success:(IPaURLResourceUISuccessHandler)success
    failure:(void (^)(NSError *error))failure {
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&jsonError];
    if (jsonError != nil) {
        if (failure) {
            failure(jsonError);
        }
        return;
    }
    
    
    if (currentAPITask != nil && currentAPITask.state == NSURLSessionTaskStateRunning) {
        [currentAPITask cancel];
    }
    
    currentAPITask = [self.resourceUI apiPut:api contentType:@"application/json" postData:jsonData onComplete:success failure:failure];
}

-(void) api:(NSString*)api postJSON:(id)jsonObject success:(IPaURLResourceUISuccessHandler)success
    failure:(void (^)(NSError *error))failure {
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&jsonError];
    if (jsonError != nil) {
        if (failure) {
            failure(jsonError);
        }
        return;
    }
    
    
    if (currentAPITask != nil && currentAPITask.state == NSURLSessionTaskStateRunning) {
        [currentAPITask cancel];
    }
    
    currentAPITask = [self.resourceUI apiPost:api contentType:@"application/json" postData:jsonData onComplete:success failure:failure];
}
@end
