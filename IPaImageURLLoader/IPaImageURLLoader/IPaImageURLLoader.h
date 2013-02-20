//
//  IPaImageURLLoader.h
//  IPaImageURLLoader
//
//  Created by IPaPa on 13/2/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@interface IPaImageURLLoader : NSObject
-(void)loadImageWithURL:(NSString*)imgURL withCallback:(void (^)(UIImage*))callback;
@end
