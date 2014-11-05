//
//  IPaBlockOperation.h
//
//  Created by IPa Chen on 2014/10/23.
//  Copyright (c) 2014年. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef  void (^IPaBlockOperationBlock)(void (^)());

//IPaBlockOperationBlock has a completion block as argument,invoke the completion block when finished operation
@interface IPaBlockOperation : NSOperation
- (instancetype)initWithBlock:(IPaBlockOperationBlock)block;
@end
