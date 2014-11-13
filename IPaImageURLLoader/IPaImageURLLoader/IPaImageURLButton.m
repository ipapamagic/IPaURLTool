//
//  IPaImageURLButton.m
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2014/10/12.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaImageURLButton.h"
#import "IPaImageURLLoader.h"
@implementation IPaImageURLButton
{
    id imageObserver;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    __weak IPaImageURLButton *weakSelf = self;
    imageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:IPA_NOTIFICATION_IMAGE_LOADED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* noti){
        NSString *imageID = noti.userInfo[IPA_NOTIFICATION_KEY_IMAGEID];
        if ([imageID isEqualToString:weakSelf.imageURL]) {
            
            [weakSelf setImage:noti.userInfo[IPA_NOTIFICATION_KEY_IMAGE] forState:UIControlStateNormal];
        }
        else if ([imageID isEqualToString:weakSelf.backgroundImageURL]) {
            [weakSelf setBackgroundImage:noti.userInfo[IPA_NOTIFICATION_KEY_IMAGE] forState:UIControlStateNormal];
        }
    }];
}
-(void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    [self setImage:[[IPaImageURLLoader defaultLoader] loadImageFromURL:self.imageURL] forState:UIControlStateNormal];
    
}
-(void)setBackgroundImageURL:(NSString *)backgroundImageURL
{
    _backgroundImageURL = backgroundImageURL;
    [self setBackgroundImage:[[IPaImageURLLoader defaultLoader] loadImageFromURL:self.imageURL] forState:UIControlStateNormal];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:imageObserver];
}
@end
