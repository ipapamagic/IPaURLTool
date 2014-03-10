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

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[super connection:connection didReceiveData:data];
    if ([self.connectionDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.connectionDelegate connection:self didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self.connectionDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.connectionDelegate connection:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}





@end
