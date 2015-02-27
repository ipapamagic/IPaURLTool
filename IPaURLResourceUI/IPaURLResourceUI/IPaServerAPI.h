//
//  IPaServerAPI.h
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2015/2/14.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaURLResourceUI.h"
@interface IPaServerAPI : NSObject
- (instancetype)initWithResourceUI:(IPaURLResourceUI*)resourceUI;
@property (nonatomic,strong) IPaURLResourceUI *resourceUI;
- (void) api:(NSString *)api Method:(NSString *)method Param:(NSDictionary *)aParam success:(IPaURLResourceUISuccessHandler)success
     failure:(void (^)(NSError *error))failure;
-(void) api:(NSString*)api putJSON:(id)jsonObject success:(IPaURLResourceUISuccessHandler)success
    failure:(void (^)(NSError *error))failure;
-(void) api:(NSString*)api postJSON:(id)jsonObject success:(IPaURLResourceUISuccessHandler)success
    failure:(void (^)(NSError *error))failure;
@end
