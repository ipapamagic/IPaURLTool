//
//  IPaURLConnection.h
//  IPaURLConnection
//
//  Created by IPaPa on 11/10/27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaConnectionBase.h"
@protocol IPaURLConnectionDelegate;
@interface IPaURLConnection : IPaConnectionBase {
    

  
}
@property (nonatomic,weak) id <IPaURLConnectionDelegate> connectionDelegate;

+ (id)ConnectionWithURLString:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback
              failCallback:(void (^)(NSError*))failCallback;

+ (id)ConnectionWithURLString:(NSString*)URL
                  cachePolicy:(NSURLRequestCachePolicy)cachePolicy
              timeoutInterval:(NSTimeInterval)timeoutInterval
                     callback:(void (^)(NSURLResponse *,NSData*))callback
                 failCallback:(void (^)(NSError*))failCallback
                     delegate:(id <IPaURLConnectionDelegate>)delegate;


@end
@protocol IPaURLConnectionDelegate <NSObject>

@optional
- (void)connection:(IPaURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)connection:(IPaURLConnection *)connection didReceiveData:(NSData *)data;
@end
