//
//  NSMutableURLRequest+IPaHTTPPost.h
//  18Beer
//
//  Created by IPaPa on 13/6/19.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (IPaHTTPPost)
/** make request as Post and set contenttype to "multipart/form-data"
*/
-(NSString*)setHTTPMultipartFormDataContentType;
/** set http post body,will set Content-Length to header field together
 @param body post body
 */
-(void)setHTTPPostBody:(NSData*)body;
@end
