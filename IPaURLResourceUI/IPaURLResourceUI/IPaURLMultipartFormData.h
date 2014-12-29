//
//  IPaURLMultipartFormData.h
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2014/12/25.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface IPaURLMultipartFormData : NSObject
@property (nonatomic,readonly) NSString *boundary;
- (void)addStringData:(NSString *)string forName:(NSString*)name;
- (void)addIntegerData:(NSInteger)intData forName:(NSString*)name;
- (void)addFloatData:(CGFloat)floatData forName:(NSString*)name;
- (void)addFileData:(NSData*)fileData fileName:(NSString*)fileName MIMEType:(NSString*)MIMEType forName:(NSString*)name;
- (NSData*)createBodyData;
@end
