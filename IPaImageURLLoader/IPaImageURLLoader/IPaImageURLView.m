//
//  IPaImageURLView.m
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2014/10/12.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaImageURLView.h"
#import "IPaImageURLLoader.h"
@implementation IPaImageURLView
{
    id imageObserver;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    __weak IPaImageURLView *weakSelf = self;
    imageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:IPA_NOTIFICATION_IMAGE_LOADED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* noti){
        
        if ([noti.userInfo[IPA_NOTIFICATION_KEY_IMAGEID] isEqualToString:weakSelf.imageURL]) {
            [weakSelf setImage:[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:noti.userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL]]]];
        }
    }];
}
-(void)setImageURL:(NSString *)imageURL
{
    [self setImageURL:imageURL withDefaultImage:nil];

    
}
- (void)setImageURL:(NSString *)imageURL withDefaultImage:(UIImage*)defaultImage
{
    imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _imageURL = imageURL;
    UIImage *image = [[IPaImageURLLoader defaultLoader] loadImageFromURL:self.imageURL];
    [self setImage:(image == nil)?defaultImage:image];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:imageObserver];
}
@end
