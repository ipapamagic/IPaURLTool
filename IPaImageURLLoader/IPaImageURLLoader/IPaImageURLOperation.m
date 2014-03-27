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
@property (nonatomic,strong,readwrite) UIImage *loadedImage;
@property (nonatomic,copy) NSString *imageID;
@property (nonatomic,strong) NSURLRequest *request;
@property (nonatomic,strong) IPaURLConnection *connection;
@end
@implementation IPaImageURLOperation
{
    dispatch_semaphore_t semaphore;
}
-(instancetype)initWithURLRequest:(NSURLRequest *)request withImageID:(NSString *)imageID
{
    self = [super init];
    self.request = request;
    self.imageID = imageID;
    self.loadedImage = nil;
    semaphore = NULL;
    return self;
}
-(void)start
{
    semaphore = dispatch_semaphore_create(0);
    IPaURLConnection *urlConnection = [[IPaURLConnection alloc] initWithRequest:self.request];
    __weak IPaImageURLOperation *weakSelf = self;
    
    urlConnection.FinishCallback = ^(NSURLResponse *response,NSData *responseData){
        weakSelf.loadedImage = [[UIImage alloc] initWithData:responseData];
        dispatch_semaphore_signal(semaphore);
        
    };
    urlConnection.FailCallback = ^(NSError* error){
        dispatch_semaphore_signal(semaphore);
    };
    
    self.connection = urlConnection;
    [urlConnection start];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

-(NSString*)imageID
{
    return _imageID;
}
-(BOOL)isConcurrent
{
    return YES;
}
-(BOOL)isExecuting
{
    return (self.connection != nil && [self.connection isRunning]);
}
-(BOOL)isFinished
{
    //    BOOL isFinished = (self.connection != nil && ![self.connection isRunning]);
    //    if (isFinished) {
    //        NSLog(@"YES finished");
    //    }
    //    else {
    //        NSLog(@"No not finished");
    //    }
    
    return (self.connection != nil && ![self.connection isRunning]);
}
-(void)cancel
{
    if (semaphore != NULL)
    {
        dispatch_semaphore_signal(semaphore);
        semaphore = NULL;
    }
    [self.connection cancel];
}
@end
