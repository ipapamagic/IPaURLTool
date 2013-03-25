//
//  NSMutableURLRequest+ResumeDownload.m
//  URLRequest-ResumeDownload
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "NSMutableURLRequest+ResumeDownload.h"

@implementation NSMutableURLRequest (ResumeDownload)
-(void)resumeDownloadToFilePath:(NSString*)filePath
{
    NSUInteger downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
        if (!error && fileDictionary)
            downloadedBytes = [fileDictionary fileSize];
    } else {
        [fm createFileAtPath:docset.downloadPath contents:nil attributes:nil];
    }

    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-", downloadedBytes];
        [self setValue:requestRange forHTTPHeaderField:@"Range"];
    }
}
@end
