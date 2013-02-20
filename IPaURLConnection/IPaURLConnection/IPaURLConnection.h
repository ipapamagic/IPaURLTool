//
//  IPaURLConnection.h
//  IPaURLConnection
//
//  Created by IPaPa on 11/10/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaURLConnection : NSURLConnection <NSURLConnectionDelegate,NSURLConnectionDataDelegate> {
    

  
}
@property (nonatomic,readonly) NSData* receiveData;
@property (nonatomic,copy) void (^Callback)(NSURLResponse*,NSData*);
@property (nonatomic,copy) void (^FailCallback)(NSError*);
@property (nonatomic,copy) void (^RecCallback)(NSURLResponse*,NSData*,NSData*);
@property (nonatomic,copy) void (^SendCallback)(NSInteger,NSInteger,NSInteger);
@property (nonatomic,copy) void (^RecAuthenticationChallengeCallback)(NSURLAuthenticationChallenge*);

- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback;

- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback
     failCallback:(void (^)(NSError*))failCallback;

- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback
     failCallback:(void (^)(NSError*))failCallback
  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback;


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback;


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback
            sendCallback:(void (^)(NSInteger,NSInteger,NSInteger))sendCallback;

-(id)initWithRequest:(NSURLRequest *)request;
+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback;

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback
              failCallback:(void (^)(NSError*))failCallback;

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData* ))callback
              failCallback:(void (^)(NSError*))failCallback
           receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData* ))receiveCallback;




+ (id)IPaURLConnectionWithURLRequest:(NSURLRequest*)request
                         callback:(void (^)(NSURLResponse *,NSData*))callback
                     failCallback:(void (^)(NSError*))failCallback
                     receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback;



@end
