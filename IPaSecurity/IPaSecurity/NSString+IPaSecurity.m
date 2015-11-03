//
//  NSString+IPaSecurity.m
//  IPaSecurity
//
//  Created by IPaPa on 13/2/7.
//  Copyright (c) 2013 IPaPa. All rights reserved.
//

#import "NSString+IPaSecurity.h"
#import "NSData+IPaSecurity.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (IPaSecurity)
-(NSString*) SHA256String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data SHA256String];
}
-(NSString*) SHA1String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data SHA1String];
}
- (NSString *) MD5String
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

//-(NSString*)stringWithURLEncode
//{
//    return  (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                                  (CFStringRef) self,
//                                                                                  NULL,
//                                                                                  (CFStringRef) @"!*'();:@&=+$,/?%#[]",
//                                                                                  kCFStringEncodingUTF8);
//}

@end
