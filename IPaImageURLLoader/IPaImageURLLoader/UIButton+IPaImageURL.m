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
    const char *keyName = [[NSString stringWithFormat:@"kIPaImageURLLoader%d",state]cStringUsingEncoding:NSASCIIStringEncoding];
    IPaImageURLLoader *loader = objc_getAssociatedObject(self,keyName );
    if (loader == nil) {
        loader = [[IPaImageURLLoader alloc] init];
        objc_setAssociatedObject(self,keyName,loader,OBJC_ASSOCIATION_RETAIN);
        
    }
    
    [loader loadImageWithURL:imageURL withCallback:^(UIImage *image){
        if (image != nil) {
            [self setImage:image forState:state];
        }
        objc_setAssociatedObject(self,keyName,nil,OBJC_ASSOCIATION_RETAIN);
    }];
}
-(void)setImageURL:(NSString*)imageURL forNormalAndOtherStates:(NSInteger)states
{
    //cancel loader
    const char *keyName;
    IPaImageURLLoader *loader;
    for (NSNumber* nsState in @[@(UIControlStateHighlighted),@(UIControlStateSelected),@(UIControlStateDisabled)]) {
        UIControlState state = [nsState integerValue];
        if (state & states) {
            keyName = [[NSString stringWithFormat:@"kIPaImageURLLoader%d",state]cStringUsingEncoding:NSASCIIStringEncoding];
            loader = objc_getAssociatedObject(self,keyName );
            if (loader != nil) {
                [loader cancel];
            }
            objc_setAssociatedObject(self,keyName,nil,OBJC_ASSOCIATION_RETAIN);
            
        }

    }
    keyName = [[NSString stringWithFormat:@"kIPaImageURLLoader%d",UIControlStateNormal]cStringUsingEncoding:NSASCIIStringEncoding];
    loader = objc_getAssociatedObject(self,keyName );

    
    
    if (loader == nil) {
        loader = [[IPaImageURLLoader alloc] init];
        objc_setAssociatedObject(self,keyName,loader,OBJC_ASSOCIATION_RETAIN);
        
    }
  
    
    [loader loadImageWithURL:imageURL withCallback:^(UIImage *image){
        if (image != nil) {
            for (NSNumber* nsState in @[@(UIControlStateHighlighted),@(UIControlStateSelected),@(UIControlStateDisabled)]) {
                UIControlState state = [nsState integerValue];
                if (state & states) {
                    [self setImage:image forState:state];
                }
            }
        
        }
        objc_setAssociatedObject(self,keyName,nil,OBJC_ASSOCIATION_RETAIN);
    }];
}
@end
