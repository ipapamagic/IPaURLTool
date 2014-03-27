//
//  IPaImageURLLoader.h
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@protocol IPaImageURLLoaderDelegate;
@interface IPaImageURLLoader : NSObject
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID;
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID withCallback:(void (^)(UIImage*))callback;
-(void)cancelLoaderWithImageID:(NSString*)imageID;
-(UIImage*)cacheWithImageID:(NSString*)imageID;
-(void)cancelAllOperation;
-(void)setMaxConcurrentOperation:(NSUInteger)maxConcurrent;
@property (nonatomic,weak) id <IPaImageURLLoaderDelegate> delegate;
@end

@protocol IPaImageURLLoaderDelegate <NSObject>

-(void)onIPaImageURLLoader:(IPaImageURLLoader*)loader imageID:(NSString*)imageID image:(UIImage*)image;

@optional
-(void)onIPaImageURLLoader:(IPaImageURLLoader*)loader failWithImageID:(NSString*)imageID;
-(NSString*)IPaImageURLLoader:(IPaImageURLLoader*)loader cacheFilePathWithImageID:(NSString*)imageID;
-(NSData*)IPaImageURLLoader:(IPaImageURLLoader*)loader createCacheWithImage:(UIImage*)image;
-(UIImage*)modifyImageWithIPaImageURLLoader:(IPaImageURLLoader*)loader originalImage:(UIImage*)originalImage withImageID:(NSString*)imageID;
@end