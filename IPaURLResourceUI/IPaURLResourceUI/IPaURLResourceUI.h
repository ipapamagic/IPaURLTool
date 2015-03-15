//
//  IPaURLResourceUI.h
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2014/10/10.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPaURLMultipartFormData.h"
typedef void (^IPaURLResourceUISuccessHandler)(NSURLResponse*,id);
@interface IPaURLResourceUI : NSObject
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,assign) BOOL filterNSNull;
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic,strong) NSURLSession* urlSession;
-(NSURLSessionDataTask*)apiGet:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
-(NSURLSessionDataTask*)apiPost:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;

-(NSURLSessionUploadTask*)apiPost:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
-(NSURLSessionDataTask*)apiPut:(NSString*)api param:(NSDictionary *)param onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
-(NSURLSessionUploadTask*)apiPut:(NSString*)api contentType:(NSString*)contentType postData:(NSData*)postData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;

-(NSURLSessionUploadTask*)api:(NSString*)api uploadMultipartFormDataWithMethod:(NSString*)method bodyData:(IPaURLMultipartFormData*)bodyData onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
-(NSURLSessionDataTask*)api:(NSString*)api method:(NSString*)method paramInHeader:(NSDictionary *)paramInHeader paramInBody:(NSDictionary *)paramInBody onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
-(NSURLSessionUploadTask*)api:(NSString*)api uploadWithMethod:(NSString*)method headerParam:(NSDictionary *)headerParam data:(NSData*)data onComplete:(IPaURLResourceUISuccessHandler)complete failure:(void (^)(NSError*))failure;
@end