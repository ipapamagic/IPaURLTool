//
//  IPaConnectionBase.m
//  IPaURLConnection
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaConnectionBase.h"
@interface IPaConnectionBase ()
@property (nonatomic,strong) NSURLResponse *response;

@end
@implementation IPaConnectionBase
static NSMutableArray *connectionList;
+(void)RetainConnection:(IPaConnectionBase*)connection
{
    if (connectionList == nil) {
        connectionList = [@[] mutableCopy];
    }
    if ([connectionList indexOfObject:connection] == NSNotFound)
    {
        [connectionList addObject:connection];
    }
    
}
+(void)ReleaseConnection:(IPaConnectionBase*)connection
{
    [connectionList removeObject:connection];
}
-(id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    NSAssert(NO,@"Don't do this!");
    return nil;
}
-(id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    NSAssert(NO,@"Don't do this!");
    return nil;
}

-(id)initWithRequest:(NSURLRequest *)request
{
    self = [super initWithRequest:request delegate:self startImmediately:NO];
    [self clearCallback];
    [self scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    return self;
}
-(void)clearCallback
{
    self.FinishCallback = nil;
    self.FailCallback = nil;
    
}
-(void) start {
    
    [super start];
    [IPaConnectionBase RetainConnection:self];
}

-(void) cancel {
    [super cancel];
    [IPaConnectionBase ReleaseConnection:self];
}
-(void)dealloc {
    [self cancel];
    [self clearCallback];
}
-(BOOL)isRunning
{
    return ([connectionList indexOfObject:self] != NSNotFound);
}
#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    responseHeader = ((NSHTTPURLResponse*)response).allHeaderFields;
    self.response = response;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.FinishCallback != nil) {
        
        self.FinishCallback();
        
    }
    [IPaConnectionBase ReleaseConnection:self];
    
}
#pragma mark - NSURLConnectionDelegate


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.FailCallback != nil) {
        self.FailCallback(error);
        
    }
    [IPaConnectionBase ReleaseConnection:self];
}
@end
