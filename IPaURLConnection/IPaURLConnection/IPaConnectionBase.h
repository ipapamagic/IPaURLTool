//
//  IPaConnectionBase.h
//  IPaURLConnection
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaConnectionBase : NSURLConnection  <NSURLConnectionDataDelegate>
@property (nonatomic,readonly) NSURLResponse* response;
@property (nonatomic,readonly) NSData* receiveData;
@property (nonatomic,copy) void (^FinishCallback)(NSURLResponse*,NSData*);
@property (nonatomic,copy) void (^FailCallback)(NSError*);
//if urlconnection is running
-(BOOL)isRunning;
-(void)clearCallback;
-(id)initWithRequest:(NSURLRequest *)request;
@end
