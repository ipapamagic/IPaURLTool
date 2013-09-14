//
//  IPaHTTPDownloadConnection.m
//  IPaURLConnection
//
//  Created by IPaPa on 13/3/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaHTTPDownloadConnection.h"
@interface IPaHTTPDownloadConnection()  <NSURLConnectionDataDelegate>
@property (nonatomic,copy) NSString *downloadPath;
@property (nonatomic,strong) NSFileHandle *fileHandle;
@property (nonatomic,readwrite) float progress;
@end
@implementation IPaHTTPDownloadConnection


-(id)initWithRequest:(NSURLRequest *)request
{
    NSAssert(NO,@"Don't do this!");
    return nil;
}

-(id)initWithDownloadURLString:(NSString *)URL toFilePath:(NSString*)filePath cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: URL] cachePolicy: cachePolicy timeoutInterval:timeoutInterval];
    
    // Check to see if the download is in progress
    unsigned long long downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
        if (!error && fileDictionary)
            downloadedBytes = [fileDictionary fileSize];
    } else {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
        [theRequest setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    self = [super initWithRequest:theRequest];
    self.downloadPath = filePath;
    
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [super connection:connection didReceiveResponse:response];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        // I don't know what kind of request this is!
        return;
    }
    
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:self.downloadPath];
    self.fileHandle = fh;
    switch (httpResponse.statusCode) {
        case 206: {
            NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
            NSError *error = nil;
            NSRegularExpression *regex = nil;
            
            // Check to see if the server returned a valid byte-range
            regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];
            if (error) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // If the regex didn't match the number of bytes, start the download from the beginning
            NSTextCheckingResult *match = [regex firstMatchInString:range
                                                            options:NSMatchingAnchored
                                                              range:NSMakeRange(0, range.length)];
            if (match.numberOfRanges < 2) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // Extract the byte offset the server reported to us, and truncate our
            // file if it is starting us at "0".  Otherwise, seek our file to the
            // appropriate offset.
            NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
            NSInteger bytes = [byteStr integerValue];
            if (bytes <= 0) {
                [fh truncateFileAtOffset:0];
                break;
            } else {
                [fh seekToFileOffset:bytes];
            }
            break;
        }
            
        default:
            [fh truncateFileAtOffset:0];
            break;
    }
    
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.fileHandle writeData:data];
    [self.fileHandle synchronizeFile];
    self.progress = (float)self.fileHandle.availableData.length / (float)self.response.expectedContentLength;
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    [super connectionDidFinishLoading:connection];
  
}
@end
