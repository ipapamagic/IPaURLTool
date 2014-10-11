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
    imageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:IPA_NOTIFICATION_IMAGE_LOADED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* noti){
        
        if ([noti.userInfo[IPA_NOTIFICATION_KEY_IMAGEID] isEqualToString:self.imageURL]) {
            [self setImage:noti.userInfo[IPA_NOTIFICATION_KEY_IMAGE]];
        }
    }];
}
-(void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    [self setImage:[[IPaImageURLLoader defaultLoader] loadImageFromURL:self.imageURL]];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:imageObserver];
}
@end
