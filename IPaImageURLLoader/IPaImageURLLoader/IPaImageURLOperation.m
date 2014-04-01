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
@synthesize isFinished;
-(instancetype)initWithURLRequest:(NSURLRequest *)request withImageID:(NSString *)imageID
{
    self = [super init];
    self.request = request;
    self.imageID = imageID;
    self.loadedImage = nil;
    return self;
}
- (void)main
{
    [self willChangeValueForKey:@"isExecuting"];
    IPaURLConnection *urlConnection = [[IPaURLConnection alloc] initWithRequest:self.request];
    __weak IPaImageURLOperation *weakSelf = self;

    urlConnection.FinishCallback = ^(NSURLResponse *response,NSData *responseData){
        if (self.isCancelled) {
   
            return;
        }
        weakSelf.loadedImage = [[UIImage alloc] initWithData:responseData];
        [self willChangeValueForKey:@"isFinished"];
        self.isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    };
    urlConnection.FailCallback = ^(NSError* error){
        [self willChangeValueForKey:@"isFinished"];
        self.isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    };
    
    self.connection = urlConnection;
    [urlConnection start];
    [self didChangeValueForKey:@"isExecuting"];
}


-(BOOL)isConcurrent
{
    return YES;
}
-(BOOL)isExecuting
{
    return (self.connection != nil && [self.connection isRunning]);
}

-(void)cancel
{
    [super cancel];
  
    [self.connection cancel];
}
@end
