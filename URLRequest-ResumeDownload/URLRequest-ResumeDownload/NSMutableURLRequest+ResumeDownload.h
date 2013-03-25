//
//  NSMutableURLRequest+ResumeDownload.h
//  URLRequest-ResumeDownload
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (ResumeDownload)
-(void)resumeDownloadToFilePath:(NSString*)filePath;
@end
