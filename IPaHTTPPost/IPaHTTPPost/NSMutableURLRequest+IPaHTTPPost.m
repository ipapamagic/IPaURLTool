//
//  NSMutableURLRequest+IPaHTTPPost.m
//  18Beer
//
//  Created by IPaPa on 13/6/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "NSMutableURLRequest+IPaHTTPPost.h"

@implementation NSMutableURLRequest (IPaHTTPPost)
-(NSString*)setHTTPMultipartFormDataContentType
{
    [self setHTTPMethod:@"POST"];
    
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [self setValue:contentType forHTTPHeaderField: @"Content-Type"];
    return boundary;
}
-(void)setHTTPPostBody:(NSData*)body
{
    [self setHTTPBody:body];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[body length]];
    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
}
@end
