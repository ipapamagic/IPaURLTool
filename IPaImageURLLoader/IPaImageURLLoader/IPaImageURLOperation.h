//
//  IPaImageURLOperation.h
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2014/2/15.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface IPaImageURLOperation : NSOperation
-(NSString*)imageID;
-(instancetype)initWithURLRequest:(NSURLRequest*)request withImageID:(NSString*)imageID;
@property (atomic,readonly) UIImage *loadedImage;
@property (atomic,readonly) NSURLRequest *request;
@end
