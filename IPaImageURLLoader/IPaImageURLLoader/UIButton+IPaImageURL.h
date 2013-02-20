//
//  UIButton+IPaImageURL.h
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/20.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (IPaImageURL)
-(void)setImageURL:(NSString*)imageURL forState:(UIControlState)state;
-(void)setImageURL:(NSString*)imageURL forNormalAndOtherStates:(NSInteger)states;

@end
