//
//  IPaImageURLLoader.h
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/19.
//  Copyright (c) 2013 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
#define IPA_NOTIFICATION_IMAGE_LOADED @"IPA_NOTIFICATION_IMAGE_LOADED"
#define IPA_NOTIFICATION_KEY_IMAGEFILEURL @"IPA_NOTIFICATION_KEY_IMAGEFILEURL"
#define IPA_NOTIFICATION_KEY_IMAGEID @"IPA_NOTIFICATION_KEY_IMAGEID"
@class UIImage;
@protocol IPaImageURLLoaderDelegate;
@interface IPaImageURLLoader : NSObject
-(UIImage*)loadImageFromURL:(NSString*)url;
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID;
-(void)loadImageWithURL:(NSString*)imgURL withImageID:(NSString*)imageID withCallback:(void (^)(NSURL*))callback;
-(void)cancelLoaderWithImageID:(NSString*)imageID;
-(UIImage*)cacheWithImageID:(NSString*)imageID;
-(void)cancelAllOperation;
-(void)setMaxConcurrentOperation:(NSUInteger)maxConcurrent;
+ (id)defaultLoader;
@property (nonatomic,weak) id <IPaImageURLLoaderDelegate> delegate;
@end

@protocol IPaImageURLLoaderDelegate <NSObject>

-(void)onIPaImageURLLoader:(IPaImageURLLoader*)loader imageID:(NSString*)imageID imageFileURL:(NSURL*)imageFileURL;

@optional
-(void)onIPaImageURLLoader:(IPaImageURLLoader*)loader failWithImageID:(NSString*)imageID;
-(NSString*)IPaImageURLLoader:(IPaImageURLLoader*)loader cacheFilePathWithImageID:(NSString*)imageID;
//-(NSData*)IPaImageURLLoader:(IPaImageURLLoader*)loader createCacheWithImage:(UIImage*)image;
-(UIImage*)modifyImageWithIPaImageURLLoader:(IPaImageURLLoader*)loader originalImageFileURL:(NSURL*)originalImageFileURL withImageID:(NSString*)imageID;

@end