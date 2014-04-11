//
//  IPaImageURLOperation.m
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2014/2/15.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaImageURLOperation.h"
#import "IPaURLConnection.h"
@interface IPaImageURLOperation()
@property (atomic,strong,readwrite) UIImage *loadedImage;
@property (atomic,copy) NSString *imageID;
@property (atomic,strong) NSURLRequest *request;
@property (atomic,strong) IPaURLConnection *connection;
@property (atomic,assign) BOOL isFinished;
@end
@implementation IPaImageURLOperation
{
    
}
-(instancetype)initWithURLRequest:(NSURLRequest *)request withImageID:(NSString *)imageID
{
    self = [super init];
    self.request = request;
    self.imageID = imageID;
    self.loadedImage = nil;
    self.isFinished = NO;
    return self;
}
-(void)start
{
    if (self.isCancelled)
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        self.isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    @synchronized(self){
        [self willChangeValueForKey:@"isExecuting"];
        IPaURLConnection *urlConnection = [[IPaURLConnection alloc] initWithRequest:self.request];
        __weak IPaImageURLOperation *weakSelf = self;
        
        urlConnection.FinishCallback = ^(NSURLResponse *response,NSData *responseData){
            if (self.isCancelled) {
                
                return;
            }
            weakSelf.loadedImage = [[UIImage alloc] initWithData:responseData];
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            self.isFinished = YES;
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
        };
        urlConnection.FailCallback = ^(NSError* error){
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            self.isFinished = YES;
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
        };
        
        self.connection = urlConnection;
        [urlConnection start];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

-(BOOL)isConcurrent
{
    return YES;
}
-(BOOL)isExecuting
{
    return !self.isFinished && (self.connection != nil && [self.connection isRunning]);
}
-(void)cancel
{
    [super cancel];
    
    @synchronized(self) {
        if (self.isExecuting) {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            self.isFinished = YES;
            [self.connection cancel];
            self.connection = nil;
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
            
        }
    }
}


@end
