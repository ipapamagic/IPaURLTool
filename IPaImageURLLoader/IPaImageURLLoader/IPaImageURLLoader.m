//
//  IPaImageURLLoader.m
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaImageURLLoader.h"
#import <UIKit/UIKit.h>
#import "IPaURLConnection.h"
#import "IPaImageURLOperation.h"
@interface IPaImageURLLoader()
-(BOOL)useCache;
-(NSString*)cachePathWithImageID:(NSString*)imageID;
@end
@implementation IPaImageURLLoader
{
    NSOperationQueue *operationQueue;
    
}
-(id)init
{
    self  = [super init];
    //    loaderQueue = [@[] mutableCopy];
    operationQueue = [[NSOperationQueue alloc] init];
    
    return self;
}
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID
{
    [self loadImageWithURL:imgURL withImageID:imageID withCallback:nil];
}
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID withCallback:(void (^)(UIImage*))callback
{
    NSArray *currentQueue = operationQueue.operations;
    NSUInteger index = [currentQueue indexOfObjectPassingTest:^(IPaImageURLOperation* obj,NSUInteger idx,BOOL *stop) {
        
        return ([obj.imageID  isEqualToString:imageID]);
    }];
    if (index != NSNotFound) {
        IPaImageURLOperation *operation = currentQueue[index];
        [operation cancel];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imgURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    IPaImageURLOperation *operation = [[IPaImageURLOperation alloc] initWithURLRequest:request withImageID:imageID];
    __weak IPaImageURLOperation* weakOperation = operation;
    IPaImageURLLoader *weakSelf = self;
    operation.completionBlock = ^(){
        if (weakOperation.loadedImage == nil) {
            if (callback != nil) {
                callback(nil);
            }
            return;
        }
        UIImage *image = weakOperation.loadedImage;
        UIImage *modifyImage = [weakSelf modifyImageWithOriginalImage:image imageID:imageID];
        if (modifyImage != nil) {
            image = modifyImage;
        }
        NSString *path = [weakSelf cachePathWithImageID:imageID];
        if (path != nil) {
            NSString *directory = [path stringByDeletingLastPathComponent];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:directory]) {
                NSError *error;
                [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                    //                    NSLog(@"%@",error);
                    if (callback != nil) {
                        callback(nil);
                    }
                    return;
                }
            }
            NSData *data = [weakSelf createCacheWithImage:image];
            [data writeToFile:path atomically:YES];
        }
        [weakSelf.delegate onIPaImageURLLoader:weakSelf imageID:imageID image:image];
        if (callback != nil) {
            callback(image);
        }
        
    };
    [operationQueue addOperation:operation];
}

-(UIImage*)cacheWithImageID:(NSString*)imageID
{
    NSString *path = [self cachePathWithImageID:imageID];
    if (path == nil) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}

-(void)cancelLoaderWithImageID:(NSString*)imageID
{
    
    NSArray *currentQueue = operationQueue.operations;
    NSUInteger index = [currentQueue indexOfObjectPassingTest:^(IPaImageURLOperation* obj,NSUInteger idx,BOOL *stop) {
        return ([obj.imageID  isEqualToString:imageID]);
    }];
    
    
    if (index == NSNotFound) {
        return;
    }
    
    IPaImageURLOperation* operation =  currentQueue[index];
    [operation cancel];
    
}
#pragma mark - property
-(BOOL)useCache
{
    return [self.delegate respondsToSelector:@selector(IPaImageURLLoader:cacheFilePathWithImageID:)];
}
-(NSString*)cachePathWithImageID:(NSString*)imageID
{
    if (self.useCache) {
        return [self.delegate IPaImageURLLoader:self cacheFilePathWithImageID:imageID];
    }
    return nil;
}
-(NSData*)createCacheWithImage:(UIImage*)image
{
    NSData *data;
    if ([self.delegate respondsToSelector:@selector(IPaImageURLLoader:createCacheWithImage:)]) {
        data = [self.delegate IPaImageURLLoader:self createCacheWithImage:image];
    }
    else {
        data = UIImageJPEGRepresentation(image, 0);
    }
    return data;
}

-(UIImage*)modifyImageWithOriginalImage:(UIImage*)originalImage imageID:(NSString*)imageID
{
    if ([self.delegate respondsToSelector:@selector(modifyImageWithIPaImageURLLoader:originalImage:withImageID:)]) {
        return [self.delegate modifyImageWithIPaImageURLLoader:self originalImage:originalImage withImageID:imageID];
    }
    return nil;
}
@end
