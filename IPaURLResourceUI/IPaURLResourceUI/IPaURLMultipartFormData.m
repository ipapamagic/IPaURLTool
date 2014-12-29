//
//  IPaURLMultipartFormData.m
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2014/12/25.
//  Copyright (c) 2014年 IPaPa. All rights reserved.
//

#import "IPaURLMultipartFormData.h"

@interface IPaURLMultipartFormData()

@property (nonatomic,strong) NSMutableData *data;
@end
@implementation IPaURLMultipartFormData
{
    
}
@synthesize boundary = _boundary;
- (NSString *)boundary
{
    if (_boundary == nil) {
        _boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return _boundary;
}
- (NSMutableData *)data
{
    if (_data == nil) {
        _data = [NSMutableData data];
    }
    return _data;
}

- (void)addStringData:(NSString *)string forName:(NSString*)name
{
    [self.data appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", self.boundary,name,string] dataUsingEncoding:NSUTF8StringEncoding]];
}
- (void)addIntegerData:(NSInteger)intData forName:(NSString*)name
{
    [self addStringData:[NSString stringWithFormat:@"%ld",intData] forName:name];
}
- (void)addFloatData:(CGFloat)floatData forName:(NSString*)name
{
    [self addStringData:[NSString stringWithFormat:@"%f",floatData] forName:name];
}
- (void)addFileData:(NSData*)fileData fileName:(NSString*)fileName MIMEType:(NSString*)MIMEType forName:(NSString*)name
{
    [self.data appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", self.boundary,name,fileName,MIMEType ] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.data appendData:fileData];
    [self.data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}
- (NSData*)createBodyData
{
    [self.data appendData:[[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return self.data;
}
@end
