//
//  IPaURLResourceUI.h
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2014/10/10.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaURLResourceUI : NSObject
@property (nonatomic,copy) NSString *baseURL;
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic,strong) NSURLSession* urlSession;
-(NSURLSessionDataTask*)api:(NSString*)api method:(NSString*)method param:(NSDictionary *)param onComplete:(void (^)(id responseObject))complete failure:(void (^)(NSError*))failure;
@end