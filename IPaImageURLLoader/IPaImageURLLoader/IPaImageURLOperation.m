//
//  IPaImageURLOperation.m
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2014/2/15.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaImageURLOperation.h"
@interface IPaImageURLOperation() <NSURLSessionDataDelegate>
@property (atomic,strong,readwrite) UIImage *loadedImage;
@property (atomic,copy) NSString *imageID;
@property (atomic,strong) NSURLRequest *request;
@property (atomic,strong) NSURLSession *session;
@property (atomic,assign) BOOL isFinished;
@property (nonatomic,strong) NSURLSessionDownloadTask *getImageTask;
@end
@implementation IPaImageURLOperation
{
    
}
-(instancetype)initWithURLRequest:(NSURLRequest*)request withImageID:(NSString*)imageID;
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
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        __weak IPaImageURLOperation *weakSelf = self;
        self.getImageTask = [session downloadTaskWithRequest:self.request completionHandler:^(NSURL *location,NSURLResponse *response,NSError *error) {
            if (error == nil) {
                //finish
                if (self.isCancelled) {
                    
                    return;
                }
                weakSelf.loadedImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:location]];
                [self willChangeValueForKey:@"isExecuting"];
                [self willChangeValueForKey:@"isFinished"];
                self.isFinished = YES;
                [self didChangeValueForKey:@"isFinished"];
                [self didChangeValueForKey:@"isExecuting"];
            }
            else {
                [self willChangeValueForKey:@"isExecuting"];
                [self willChangeValueForKey:@"isFinished"];
                self.isFinished = YES;
                [self didChangeValueForKey:@"isFinished"];
                [self didChangeValueForKey:@"isExecuting"];
            }
        }];
        
        [self.getImageTask resume];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

-(BOOL)isConcurrent
{
    return YES;
}
-(BOOL)isExecuting
{
    return !self.isFinished && (self.getImageTask != nil && self.getImageTask.state == NSURLSessionTaskStateRunning);
}
-(void)cancel
{
    [super cancel];
    
    @synchronized(self) {
        if (self.isExecuting) {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            self.isFinished = YES;
            [self.getImageTask cancel];
            self.getImageTask = nil;
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
            
        }
    }
}


@end
