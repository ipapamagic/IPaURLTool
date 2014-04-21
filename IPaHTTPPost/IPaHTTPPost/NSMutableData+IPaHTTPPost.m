//
//  NSMutableData+IPaHTTPPost.m
//  18Beer
//
//  Created by IPaPa on 13/6/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "NSMutableData+IPaHTTPPost.h"

@implementation NSMutableData (IPaHTTPPost)
-(void)appendHTTPPostWithName:(NSString*)dataName dataString:(NSString*)dataString boundary:(NSString*)boundary
{
    [self appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", boundary,dataName,dataString] dataUsingEncoding:NSUTF8StringEncoding]];
}
-(void)appendHTTPPostWithName:(NSString*)dataName intData:(NSInteger)intData boundary:(NSString*)boundary
{
    [self appendHTTPPostWithName:dataName dataString:[NSString stringWithFormat:@"%ld",(long)intData] boundary:boundary];
}
-(void)appendHTTPPostWithName:(NSString*)dataName floatData:(CGFloat)floatData boundary:(NSString*)boundary
{
    [self appendHTTPPostWithName:dataName dataString:[NSString stringWithFormat:@"%f",floatData] boundary:boundary];
}
-(void)appendHTTPPostWithName:(NSString*)dataName fileName:(NSString*)fileName fileData:(NSData*)fileData MIMEType:(NSString*)MIMEType boundary:(NSString*)boundary
{
    [self appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary,dataName,fileName,MIMEType ] dataUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:fileData];
    [self appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}
-(void)appendHTTPPostCloseBoundary:(NSString *)boundary
{
    [self appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}
@end
