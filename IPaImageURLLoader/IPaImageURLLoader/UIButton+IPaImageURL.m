//
//  UIButton+IPaImageURL.m
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/20.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "UIButton+IPaImageURL.h"
#import "IPaImageURLLoader.h"
#import <objc/runtime.h>
@implementation UIButton (IPaImageURL)
-(void)setImageURL:(NSString*)imageURL forState:(UIControlState)state
{
    IPaImageURLLoader *loader = objc_getAssociatedObject(self, "kIPaImageURLLoader");
    if (loader == nil) {
        loader = [[IPaImageURLLoader alloc] init];
        objc_setAssociatedObject(self,"kIPaImageURLLoader",loader,OBJC_ASSOCIATION_RETAIN);
        
    }
    
    [loader loadImageWithURL:imageURL withCallback:^(UIImage *image){
        if (image != nil) {
            [self setImage:image forState:state];
        }
        objc_setAssociatedObject(self,"kIPaImageURLLoader",nil,OBJC_ASSOCIATION_RETAIN);
    }];
}
@end
