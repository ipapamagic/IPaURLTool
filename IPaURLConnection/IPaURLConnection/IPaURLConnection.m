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

    
}

+ (id)ConnectionWithURLString:(NSString*)URL
                  cachePolicy:(NSURLRequestCachePolicy)cachePolicy
              timeoutInterval:(NSTimeInterval)timeoutInterval
                     callback:(void (^)(NSURLResponse *,NSData*))callback
                 failCallback:(void (^)(NSError*))failCallback
                     delegate:(id <IPaURLConnectionDelegate>)delegate
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: URL] cachePolicy: cachePolicy timeoutInterval:timeoutInterval];
    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithRequest:theRequest];
    
    __weak IPaURLConnection *weakConnection = connection;
    connection.FinishCallback = ^(){
        callback(weakConnection.response,weakConnection.receiveData);
    };
    connection.FailCallback = failCallback;
    connection.connectionDelegate = delegate;    
    [connection start];
    

    return connection;
    
}
+ (id)ConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse*, NSData *))callback
              failCallback:(void (^)(NSError*))failCallback
{
    return [self ConnectionWithURLString:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:failCallback delegate:nil];
    
}

-(id)initWithRequest:(NSURLRequest *)request
{
    self = [super initWithRequest:request];
    recData = [NSMutableData data];    
    return self;
}



-(void)dealloc {
    recData = nil;
}

-(void) cancel {
    [recData setLength:0];    
    [super cancel];
}
-(NSData*)receiveData
{
    return recData;
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    responseHeader = ((NSHTTPURLResponse*)response).allHeaderFields;
    [super connection:connection didReceiveResponse:response];
	[recData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[recData appendData: data];
    if ([self.connectionDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.connectionDelegate connection:self didReceiveData:data];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.FinishCallback != nil) {
        
        self.FinishCallback();
        
    }
    [super connectionDidFinishLoading:connection];

}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self.connectionDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.connectionDelegate connection:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}



#pragma mark - NSURLConnectionDelegate


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.FailCallback != nil) {
        self.FailCallback(error);
        
    }
    [IPaURLConnection ReleaseConnection:self];
}



@end
