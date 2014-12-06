//
//  IPaURLResourceUI.m
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2014/10/10.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaURLResourceUI.h"
@interface IPaURLResourceUI() <NSURLSessionDelegate>
@end
@implementation IPaURLResourceUI
-(NSURLSessionConfiguration*)sessionConfiguration;
{
    if (_sessionConfiguration == nil) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfiguration;
}
-(NSURLSession*)urlSession
{
    if (_urlSession == nil) {
        _urlSession = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}
-(NSURLSessionDataTask*)apiGet:(NSString*)api param:(NSDictionary *)param onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{

    NSString *apiURL = [self.baseURL stringByAppendingString:api];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setHTTPMethod:@"GET"];

    if ([param count] > 0) {
        apiURL = [apiURL stringByAppendingString:@"?"];
        NSUInteger count = 0;
        for (NSString* key in param.allKeys) {
            NSString* value = param[key];
            
            apiURL = [apiURL stringByAppendingFormat:(count > 0)?@"&%@=%@":@"%@=%@",key,value];
            count++;
            
        }
        
    }
    [request setURL:[NSURL URLWithString:apiURL]];
    return [self apiWithRequest:request onComplete:complete failure:failure];
}

-(NSURLSessionDataTask*)apiPost:(NSString*)api param:(NSDictionary *)param onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"POST" paramInBody:param onComplete:complete failure:failure];
}
-(NSURLSessionDataTask*)apiPut:(NSString*)api param:(NSDictionary *)param onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"PUT" paramInBody:param onComplete:complete failure:failure];
}
-(NSURLSessionDataTask*)api:(NSString*)api method:(NSString*)method paramInBody:(NSDictionary *)paramInBody onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    NSString *apiURL = [self.baseURL stringByAppendingString:api];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:apiURL]];
    [request setHTTPMethod:method];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSUInteger count = 0;
    NSString *postString;
    for (NSString* key in paramInBody.allKeys) {
        NSString* value = paramInBody[key];
        
        postString = [postString stringByAppendingFormat:(count > 0)?@"&%@=%@":@"%@=%@",key,value];
        count++;
        
    }
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //    postString = [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self apiWithRequest:request onComplete:complete failure:failure];
}
-(NSURLSessionUploadTask*)api:(NSString*)api method:(NSString*)method contentType:(NSString*)contentType data:(NSData*)data onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    NSString *apiURL = [self.baseURL stringByAppendingString:api];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:apiURL]];
    [request setHTTPMethod:method];
    
    [request setValue:contentType forHTTPHeaderField:@"content-type"];
    NSURLSessionUploadTask *task = [self.urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData* responseData,NSURLResponse* response,NSError* error){
        if (error != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        NSError *jsonError;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        if (jsonError != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        if (complete) {
            complete(jsonData);
        }
        
    }];
    
    [task resume];
    return task;
    

}
-(NSURLSessionUploadTask*)apiPut:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"PUT" contentType:contentType data:postData onComplete:complete failure:failure];
}
-(NSURLSessionUploadTask*)apiPost:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"POST" contentType:contentType data:postData onComplete:complete failure:failure];
    
}
-(NSURLSessionDataTask*) apiWithRequest:(NSURLRequest*)request  onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure
{
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData* responseData,NSURLResponse* response,NSError* error){
        if (error != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        NSError *jsonError;
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        if (jsonError != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        if (complete) {
            complete(jsonData);
        }
        
    }];
    
    [task resume];
    return task;
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"sadmasdmalksmdksam");
}
@end
