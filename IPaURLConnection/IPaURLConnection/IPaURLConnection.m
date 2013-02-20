//
//  IPaURLConnection.m
//  IPaURLConnection
//
//  Created by IPaPa on 11/10/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IPaURLConnection.h"
@interface IPaURLConnection ()

@end
@implementation IPaURLConnection
{
    NSMutableData* recData;
    NSURLResponse *response;
    
}
static NSMutableArray *connectionList;
+(void)RetainConnection:(IPaURLConnection*)connection
{
    if (connectionList == nil) {
        connectionList = [@[] mutableCopy];
    }
    if ([connectionList indexOfObject:connection] == NSNotFound)
    {
        [connectionList addObject:connection];
    }
    
}
+(void)ReleaseConnection:(IPaURLConnection*)connection
{
    [connectionList removeObject:connection];
}

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData *))callback
{
    return [IPaURLConnection IPaURLConnectionWithURLString:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:nil receiveCallback:nil];
}

+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse*, NSData *))callback
              failCallback:(void (^)(NSError*))failCallback
{
    return [IPaURLConnection IPaURLConnectionWithURLString:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback
                                  failCallback:failCallback receiveCallback:nil];
    
}


+ (id)IPaURLConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse*, NSData*))callback
              failCallback:(void (^)(NSError*))failCallback
           receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData *))receiveCallback
{
    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithURLString:URL
                                                       cachePolicy:cachePolicy
                                                   timeoutInterval:timeoutInterval
                                                          callback:callback
                                                      failCallback:failCallback
                                                   receiveCallback:receiveCallback];
    
    [connection start];
    
    
    return connection;
}

+ (id)IPaURLConnectionWithURLRequest:(NSURLRequest*)request
                         callback:(void (^)(NSURLResponse *,NSData*))callback
                     failCallback:(void (^)(NSError*))failCallback
                  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback
{
    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithURLRequest:request
                                                                 callback:callback
                                                             failCallback:failCallback
                                                          receiveCallback:receiveCallback];
    
    [connection start];
    
    
    return connection;
}


- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
{
    return [self initWithURLString:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:nil receiveCallback:nil];
    
}

- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
     failCallback:(void (^)(NSError*))failCallback
{
    return [self initWithURLString:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:failCallback receiveCallback:nil];
    
}

- (id)initWithURLString:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
     failCallback:(void (^)(NSError*))failCallback
  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData *))receiveCallback
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: URL] cachePolicy: cachePolicy timeoutInterval:timeoutInterval];
    return [self initWithURLRequest:theRequest callback:callback failCallback:failCallback receiveCallback:receiveCallback];
}


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback

{
    return [self initWithURLRequest:request callback:callback failCallback:failCallback receiveCallback:receiveCallback sendCallback:nil];
}
- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback
            sendCallback:(void (^)(NSInteger,NSInteger,NSInteger))sendCallback
{
    self = [self initWithRequest:request];
    self.Callback = [callback copy];
    self.FailCallback = [failCallback copy];
    self.RecCallback = [receiveCallback copy];
    self.SendCallback = [sendCallback copy];
    return self;
}

-(id)initWithRequest:(NSURLRequest *)request
{
    self = [super initWithRequest:request delegate:self startImmediately:NO];
    recData = [NSMutableData data];
    self.Callback = nil;
    self.FailCallback = nil;
    self.RecCallback = nil;
    self.SendCallback = nil;
    [self scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    return self;
}



-(void)dealloc {
    [self cancel];
    recData = nil;
    response = nil;

    self.Callback = nil;
    self.FailCallback = nil;
    self.RecCallback = nil;
    self.SendCallback = nil;
    
}

-(void) start {
    [super start];
    [IPaURLConnection RetainConnection:self];
}

-(void) cancel {
    [super cancel];
    [recData setLength:0];
    [IPaURLConnection ReleaseConnection:self];
}
-(NSData*)receiveData
{
    return recData;
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    //    responseHeader = ((NSHTTPURLResponse*)response).allHeaderFields;
    response = _response;
	[recData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[recData appendData: data];
    
    if (self.RecCallback != nil) {
        self.RecCallback(response,recData,data);
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.FailCallback != nil) {
        self.FailCallback(error);
        
    }
    [IPaURLConnection ReleaseConnection:self];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.Callback != nil) {

        self.Callback(response,recData);
        
    }
    [IPaURLConnection ReleaseConnection:self];

}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.SendCallback != nil) {
        self.SendCallback(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Challenge !!");
    if (self.RecAuthenticationChallengeCallback) {
        self.RecAuthenticationChallengeCallback(challenge);
    }
}

@end
