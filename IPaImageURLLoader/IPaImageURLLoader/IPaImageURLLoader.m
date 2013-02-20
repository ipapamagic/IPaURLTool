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
@property (nonatomic,strong) IPaURLConnection *currentConnection;
@property (nonatomic,copy) NSString *currentImgURL;

@end
@implementation IPaImageURLLoader
-(void)loadImageWithURL:(NSString*)imgURL withCallback:(void (^)(UIImage*))callback
{
    self.currentImgURL = imgURL;
    if (self.currentConnection != nil) {
        [self.currentConnection cancel];
        
    }
    self.currentConnection = [[IPaURLConnection alloc] initWithURLString:self.currentImgURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10 callback:nil];
    
    
    __weak IPaImageURLLoader *weakSelf = self;
    self.currentConnection.Callback = ^(NSURLResponse* response,NSData* retData){
        if (![imgURL isEqualToString:weakSelf.currentImgURL]) {
            callback(nil);
            return;
        }
        
        UIImage *image = [[UIImage alloc] initWithData:retData];
        callback(image);
        weakSelf.currentConnection = nil;
    };
    self.currentConnection.FailCallback = ^(NSError* error){
        weakSelf.currentConnection = nil;
        callback(nil);
    };
    [self.currentConnection start];
}
-(void)cancel
{
    if (self.currentConnection != nil) {
        [self.currentConnection cancel];
        
    }
    self.currentConnection = nil;
    self.currentImgURL = nil;
}
@end
