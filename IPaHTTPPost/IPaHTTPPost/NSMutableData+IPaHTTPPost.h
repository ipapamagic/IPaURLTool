//
//  NSMutableData+IPaHTTPPost.h
//  18Beer
//
//  Created by IPaPa on 13/6/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (IPaHTTPPost)
/** append post data
 @param dataName name of data
 @param dataString value string of data
 @param boundary boundary
 */
-(void)appendHTTPPostWithName:(NSString*)dataName dataString:(NSString*)dataString boundary:(NSString*)boundary;
/** append post int data
 @param dataName name of data
 @param intData int value of data
 @param boundary boundary
 */
-(void)appendHTTPPostWithName:(NSString*)dataName intData:(NSInteger)intData boundary:(NSString*)boundary;
/** append post float data
 @param dataName name of data
 @param floatData float value of data
 @param boundary boundary
 */
-(void)appendHTTPPostWithName:(NSString*)dataName floatData:(CGFloat)floatData boundary:(NSString*)boundary;
/** append post file
 @param dataName name of data
 @param fileName file's name
 @param fileData file NSData
 @param MIMEType file MIME type
 @param boundary boundary
 */
-(void)appendHTTPPostWithName:(NSString*)dataName fileName:(NSString*)fileName fileData:(NSData*)fileData MIMEType:(NSString*)MIMEType boundary:(NSString*)boundary;

/** append post end boundary
 @param boundary boundary
 */
-(void)appendHTTPPostCloseBoundary:(NSString*)boundary;
@end
