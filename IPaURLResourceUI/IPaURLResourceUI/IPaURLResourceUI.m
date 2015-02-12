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
- (instancetype)init
{
    self  = [super init];
    self.filterNSNull = NO;
    return self;
}


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
-(NSURLSessionDataTask*)apiGet:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
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
    apiURL = [apiURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:apiURL];
    [request setURL:url];
    return [self apiWithRequest:request onComplete:complete failure:failure];
}

-(NSURLSessionDataTask*)apiPost:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"POST" paramInBody:param onComplete:complete failure:failure];
}
-(NSURLSessionDataTask*)apiPut:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{
    return [self api:api method:@"PUT" paramInBody:param onComplete:complete failure:failure];
}
-(NSURLSessionDataTask*)api:(NSString*)api method:(NSString*)method paramInBody:(NSDictionary *)paramInBody onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
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
-(NSURLSessionUploadTask*)api:(NSString*)api uploadWithMethod:(NSString*)method contentType:(NSString*)contentType data:(NSData*)data onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{
    NSString *apiURL = [self.baseURL stringByAppendingString:api];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:apiURL]];
    [request setHTTPMethod:method];
    
    [request setValue:contentType forHTTPHeaderField:@"content-type"];
//    NSString *dataLength = [NSString stringWithFormat:@"%ld", (unsigned long)[data length]];
//    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody:data];
    
    NSURLSessionUploadTask *task = [self.urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData* responseData,NSURLResponse* response,NSError* error){
        if (error != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        NSError *jsonError;
#ifdef DEBUG

        NSString *retString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"IPaURLResourceUI return string :%@",retString);
#endif
        id jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        if (jsonError != nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        if (complete) {
            if (self.filterNSNull) {
                jsonData = [self removeNSNullDataFromObject:jsonData];
            }
            complete(response,jsonData);
        }
        
    }];
    
    [task resume];
    return task;
    

}
-(NSURLSessionUploadTask*)api:(NSString*)api uploadMultipartFormDataWithMethod:(NSString*)method bodyData:(IPaURLMultipartFormData*)bodyData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", bodyData.boundary];
    NSData* data = [bodyData createBodyData];

    
    return [self api:api uploadWithMethod:method contentType:contentType data:data onComplete:complete failure:failure];
}
-(NSURLSessionUploadTask*)apiPut:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{
    return [self api:api uploadWithMethod:@"PUT" contentType:contentType data:postData onComplete:complete failure:failure];
}
-(NSURLSessionUploadTask*)apiPost:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
{
    return [self api:api uploadWithMethod:@"POST" contentType:contentType data:postData onComplete:complete failure:failure];
    
}
-(NSURLSessionDataTask*) apiWithRequest:(NSURLRequest*)request  onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure
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
            
            if (self.filterNSNull) {
                jsonData = [self removeNSNullDataFromObject:jsonData];
            }
            complete(response,jsonData);
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
}
- (id)removeNSNullDataFromObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self removeNSNullDataFromDictionary:object];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        return [self removeNSNullDataFromArray:object];
    }
    return object;
}
- (NSDictionary *)removeNSNullDataFromDictionary:(NSDictionary*)dictionary
{
    NSMutableDictionary *mDict = [@{} mutableCopy];
    for (NSString *key in dictionary.allKeys) {
        id value = dictionary[key];
        if ([value isEqual:[NSNull null]]) {
            continue;
        }
        else if([value isKindOfClass:[NSDictionary class]]) {
            value = [self removeNSNullDataFromDictionary:value];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            value = [self removeNSNullDataFromArray:value];
        }
        mDict[key] = value;
    }
    return mDict;
}
- (NSArray *)removeNSNullDataFromArray:(NSArray*)array
{
    NSMutableArray *mArray = [@[] mutableCopy];
    for (id value in array) {
        id newValue = value;
        if ([value isEqual:[NSNull null]]) {
            continue;
        }
        else if([value isKindOfClass:[NSDictionary class]]) {
            newValue = [self removeNSNullDataFromDictionary:value];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            newValue = [self removeNSNullDataFromArray:value];
        }
        [mArray addObject:newValue];
    }
    return mArray;
}
@end
