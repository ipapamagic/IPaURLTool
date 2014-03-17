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
{
    NSString *tempFileName;
}

-(id)initWithRequest:(NSURLRequest *)request
{
    NSAssert(NO,@"Don't do this!");
    return nil;
}
-(id)initWithRequest:(NSURLRequest *)request toFilePath:(NSString*)filePath
{
    // Check to see if the download is in progress
    NSMutableURLRequest *theRequest = [request mutableCopy];
    NSUInteger downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [fm removeItemAtPath:filePath error:&error];
    }
    
    
    tempFileName = [filePath stringByAppendingPathExtension:@"tmp"];
    if ([fm fileExistsAtPath:tempFileName]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:tempFileName error:&error];
        if (!error && fileDictionary) {
            downloadedBytes = (NSUInteger)[fileDictionary fileSize];
            if (downloadedBytes > 0) {
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%lu-", (unsigned long)downloadedBytes];
                [theRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            }
        }
    } else {
        [fm createFileAtPath:tempFileName contents:nil attributes:nil];
    }
    
    
    [theRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    self = [super initWithRequest:theRequest];
    self.downloadPath = filePath;
    
    return self;
}
-(id)initWithDownloadURLString:(NSString *)URL toFilePath:(NSString*)filePath cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: URL] cachePolicy: cachePolicy timeoutInterval:timeoutInterval];
    
    
    return [self initWithRequest:theRequest toFilePath:filePath];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [super connection:connection didReceiveResponse:response];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        // I don't know what kind of request this is!
        return;
    }
    
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:tempFileName];
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
    
    
    self.progress = (float)self.fileHandle.offsetInFile / (float)self.response.expectedContentLength;
    if (self.onProgressUpdate != nil) {
        self.onProgressUpdate(self.progress);
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.downloadPath]) {
        [fm removeItemAtPath:self.downloadPath error:&error];
    }
    if (!error) {
        [fm moveItemAtPath:tempFileName toPath:self.downloadPath error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        
    }
    [super connectionDidFinishLoading:connection];
    
}
@end
