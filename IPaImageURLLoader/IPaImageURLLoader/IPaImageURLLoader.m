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
@interface IPaImageURLLoader()
-(BOOL)useCache;
-(NSString*)cachePathWithImageID:(NSString*)imageID;
@property (nonatomic,strong) IPaURLConnection *currentConnection;
@end
@implementation IPaImageURLLoader
{
    NSMutableArray *loaderQueue;
}
-(id)init
{
    self  = [super init];
    loaderQueue = [@[] mutableCopy];
    
    
    return self;
}
-(void)insertLoadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID
{
    NSUInteger index = [loaderQueue indexOfObjectPassingTest:^(id obj,NSUInteger idx,BOOL *stop) {
        NSArray *item = (NSArray*)obj;
        return ([item[0] isEqualToString:imageID]);
    }];
    if (index == NSNotFound) {
        if (loaderQueue.count >= 1) {
            [loaderQueue insertObject:@[imageID,imgURL] atIndex:1];
        }
        else {
            [loaderQueue addObject:@[imageID,imgURL]];
        }
        [self processLoaderQueue];
        return;
    }
    NSArray *item = loaderQueue[index];
    
    
    if (![item[1] isEqualToString:imgURL]) {
        if (index == 0) {
            [self.currentConnection cancel];
            self.currentConnection = nil;
            [self processLoaderQueue];
            return;
        }
        else if (index == 1) {
            [loaderQueue replaceObjectAtIndex:index withObject:@[imageID,imgURL]];
            return;
        }
    }
    
    
    [loaderQueue removeObjectAtIndex:index];
    [loaderQueue insertObject:@[imageID,imgURL] atIndex:1];

    


}
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID
{
    NSUInteger index = [loaderQueue indexOfObjectPassingTest:^(id obj,NSUInteger idx,BOOL *stop) {
        NSArray *item = (NSArray*)obj;
        return ([item[0] isEqualToString:imageID]);
    }];
    
    if (index == NSNotFound) {
        [loaderQueue addObject:@[imageID,imgURL]];
        [self processLoaderQueue];
        return;
    }
    NSArray *item = loaderQueue[index];
    if ([item[1] isEqualToString:imgURL]) {
        return;
    }
    if (index == 0) {
        [self.currentConnection cancel];
        self.currentConnection = nil;
    }
    
    [loaderQueue replaceObjectAtIndex:index withObject:@[imageID,imgURL]];
    
    [self processLoaderQueue];
    
}
-(UIImage*)cacheWithImageID:(NSString*)imageID
{
    NSString *path = [self cachePathWithImageID:imageID];
    if (path == nil) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}
-(void)processLoaderQueue
{
    
    if (loaderQueue.count == 0) {
        return;
    }
    if (self.currentConnection != nil) {
        return;
    }
    NSArray *items = loaderQueue[0];
    NSString *imageID = items[0];
    NSString *imageURL = items[1];
    self.currentConnection = [[IPaURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
    
    __weak IPaImageURLLoader *weakSelf = self;
    __weak NSMutableArray *weakLoaderQueue = loaderQueue;
    self.currentConnection.FinishCallback = ^(){
        NSArray *items = weakLoaderQueue[0];
        if (![items[0] isEqualToString:imageID]) {
            weakSelf.currentConnection = nil;
            [weakSelf processLoaderQueue];
            return;
        }
        
        IPaURLConnection *connection = weakSelf.currentConnection;
        UIImage *image = [[UIImage alloc] initWithData:connection.receiveData];
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
                    NSLog(@"%@",error);
                    return;
                }
            }
            NSData *data = [weakSelf createCacheWithImage:image];
            [data writeToFile:path atomically:YES];
        }
        [weakSelf.delegate onIPaImageURLLoader:weakSelf imageID:imageID image:image];        

        weakSelf.currentConnection = nil;
        [weakLoaderQueue removeObjectAtIndex:0];
        
        [weakSelf processLoaderQueue];
    };
    self.currentConnection.FailCallback = ^(NSError* error){
        NSArray *items = weakLoaderQueue[0];
        if (![items[0] isEqualToString:imageID]) {
            weakSelf.currentConnection = nil;
            [weakSelf processLoaderQueue];
            return;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(onIPaImageURLLoader:failWithImageID:)]) {
            [weakSelf.delegate onIPaImageURLLoader:weakSelf failWithImageID:imageID];
        }
        
        weakSelf.currentConnection = nil;
        [weakLoaderQueue removeObjectAtIndex:0];
        [weakSelf processLoaderQueue];
    };
    [self.currentConnection start];
    
}
-(void)cancelLoaderWithImageID:(NSString*)imageID
{
    NSUInteger index = [loaderQueue indexOfObjectPassingTest:^(id obj,NSUInteger idx,BOOL *stop) {
        NSArray *item = (NSArray*)obj;
        return ([item[0] isEqualToString:imageID]);
    }];
    if (index == NSNotFound) {
        return;
    }

    if (index == 0) {
        return;
    }
    [loaderQueue removeObjectAtIndex:index];        
    
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
