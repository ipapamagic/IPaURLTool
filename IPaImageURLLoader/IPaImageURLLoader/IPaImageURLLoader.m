//
//  IPaImageURLLoader.m
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/19.
//  Copyright (c) 2013 IPaPa. All rights reserved.
//

#import "IPaImageURLLoader.h"
#import <UIKit/UIKit.h>
#import "IPaImageURLOperation.h"
#import "NSString+IPaSecurity.h"
@interface IPaImageURLLoader() <IPaImageURLLoaderDelegate>
-(BOOL)useCache;
-(NSString*)cachePathWithImageID:(NSString*)imageID;
@end
@implementation IPaImageURLLoader
{
    NSOperationQueue *operationQueue;
    NSMutableArray *imageCallbackList;
    
}
static IPaImageURLLoader *instance;
const NSUInteger IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER = 3;
-(id)init
{
    self  = [super init];
    //    loaderQueue = [@[] mutableCopy];
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER;
    imageCallbackList = [@[] mutableCopy];
    return self;
}
+ (id)defaultLoader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil){
            instance = [[IPaImageURLLoader alloc] init];
        }
    });
    
    return instance;
}

-(id <IPaImageURLLoaderDelegate>)delegate
{
    if (_delegate == nil) {
        return self;
    }
    return _delegate;
}
-(void)setMaxConcurrentOperation:(NSUInteger)maxConcurrent
{
    operationQueue.maxConcurrentOperationCount = maxConcurrent;
}
-(UIImage*)loadImageFromURL:(NSString*)url
{
    UIImage *image = [self cacheWithImageID:url];
    if (image != nil) {
        return image;
    }
    
    [self loadImageWithURL:url withImageID:url];
    return nil;
}
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID
{
    [self loadImageWithURL:imgURL withImageID:imageID withCallback:nil];
}

-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID withCallback:(void (^)(NSURL*))callback
{
    if (imgURL == nil) {
        return;
    }
    NSArray *currentQueue = operationQueue.operations;
    NSUInteger index = [currentQueue indexOfObjectPassingTest:^(IPaImageURLOperation* obj,NSUInteger idx,BOOL *stop) {
        return ([obj.imageID  isEqualToString:imageID]);
    }];
    if (index != NSNotFound) {
        IPaImageURLOperation *operation = currentQueue[index];
        if (!operation.isCancelled) {
            if (![[operation.request.URL absoluteString] isEqualToString:imgURL]) {
                [operation cancel];
            }
            else{
                if (callback != nil) {
                    [imageCallbackList addObject:[callback copy]];
                }
                return;
            }
        }
        
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imgURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    IPaImageURLOperation *operation = [[IPaImageURLOperation alloc] initWithURLRequest:request withImageID:imageID];
    __weak IPaImageURLOperation* weakOperation = operation;
    IPaImageURLLoader *weakSelf = self;
    operation.completionBlock = ^(){
        if (weakOperation.loadedImageURL == nil) {
            if (callback != nil) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    callback(nil);
                });
                
            }
            for (id callbackItem in imageCallbackList )
            {
                void (^blockItem)(UIImage*) = callbackItem;
                dispatch_async(dispatch_get_main_queue(), ^(){
                    blockItem(nil);
                });
            }
            
            return;
        }
//        UIImage *image = weakOperation.loadedImage;
        NSURL *imageURL = weakOperation.loadedImageURL;
        
        UIImage *modifyImage = [weakSelf modifyImageWithOriginalImageFileURL:imageURL imageID:imageID];
        if (modifyImage != nil) {
            NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            path = [path stringByAppendingPathComponent:@"IPaImageCache.imageCache"];
            NSData *data = UIImagePNGRepresentation(modifyImage);
            [data writeToFile:path atomically:YES];
            
            imageURL = [NSURL fileURLWithPath:path];
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
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            callback(nil);
                        });
                    }
                    for (id callbackItem in imageCallbackList )
                    {
                        void (^blockItem)(UIImage*) = callbackItem;
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            blockItem(nil);
                        });
                    }
                    return;
                }
            }
            NSError *error;
            [fileManager copyItemAtURL:imageURL toURL:[NSURL fileURLWithPath:path] error:&error];
            
            
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:IPA_NOTIFICATION_IMAGE_LOADED object:nil userInfo:@{IPA_NOTIFICATION_KEY_IMAGEFILEURL:imageURL,IPA_NOTIFICATION_KEY_IMAGEID:imageID}];
            
            
            [weakSelf.delegate onIPaImageURLLoader:weakSelf imageID:imageID imageFileURL:imageURL];
            if (callback != nil) {
                callback(imageURL);
                
            }
            for (id callbackItem in imageCallbackList )
            {
                void (^blockItem)(NSURL*) = callbackItem;
                blockItem(imageURL);
            }
            
        });
        
        
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
-(void)cancelAllOperation
{
    [operationQueue cancelAllOperations];
    [imageCallbackList removeAllObjects];
    
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


-(UIImage*)modifyImageWithOriginalImageFileURL:(NSURL*)originalImageFileURL imageID:(NSString*)imageID
{
    if ([self.delegate respondsToSelector:@selector(modifyImageWithIPaImageURLLoader:originalImageFileURL:withImageID:)]) {
        return [self.delegate modifyImageWithIPaImageURLLoader:self originalImageFileURL:originalImageFileURL withImageID:imageID];
    }
    return nil;
}

#pragma mark - IPaImageURLLoaderDelegate
-(void)onIPaImageURLLoader:(IPaImageURLLoader*)loader imageID:(NSString*)imageID imageFileURL:(NSURL*)imageFileURL
{
}

-(NSString*)IPaImageURLLoader:(IPaImageURLLoader*)loader cacheFilePathWithImageID:(NSString*)imageID
{
    static NSString *cachepath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        cachepath = [cachepath stringByAppendingPathComponent:@"cacheImage"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:cachepath]) {
            NSError *error;
            [fileMgr createDirectoryAtPath:cachepath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
        }
        
    });
    
    NSString *filePath;
    NSString *imgUrl = imageID;
    filePath = [cachepath stringByAppendingPathComponent:[imgUrl MD5String]];
    return filePath;
    
}
@end
