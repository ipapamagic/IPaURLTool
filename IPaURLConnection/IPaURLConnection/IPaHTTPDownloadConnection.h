//
//  IPaHTTPDownloadConnection.h
//  IPaURLConnection
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaConnectionBase.h"
@interface IPaHTTPDownloadConnection : IPaConnectionBase
@property (nonatomic,readonly) float progress;
@property (nonatomic,copy) void (^onProgressUpdate)(float);
-(id)initWithDownloadURLString:(NSString *)URL toFilePath:(NSString*)filePath cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;
-(id)initWithRequest:(NSURLRequest *)request toFilePath:(NSString*)filePath;
@end
