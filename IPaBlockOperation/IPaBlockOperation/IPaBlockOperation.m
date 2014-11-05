//
//  IPaBlockOperation.m
//
//  Created by IPa Chen on 2014/10/23.
//  Copyright (c) 2014. All rights reserved.
//

#import "IPaBlockOperation.h"
@interface IPaBlockOperation()
@property (nonatomic,copy) void (^operationBlock)(void (^)());
@property (atomic,assign) BOOL isFinished;
@property (atomic,assign) BOOL isExecuting;
@end
@implementation IPaBlockOperation
- (instancetype)initWithBlock:(IPaBlockOperationBlock)block
{
  self = [super init];
  self.operationBlock = block;
  self.isFinished = NO;
  
  return self;
  
}
-(void)start
{
  if (self.isCancelled)
  {
    // Must move the operation to the finished state if it is canceled.
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  @synchronized(self){

    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    self.operationBlock(^(){
      [self willChangeValueForKey:@"isExecuting"];
      [self willChangeValueForKey:@"isFinished"];
      self.isFinished = YES;
      self.isExecuting = NO;
      [self didChangeValueForKey:@"isFinished"];
      [self didChangeValueForKey:@"isExecuting"];

    });
  }
}

-(BOOL)isConcurrent
{
  return YES;
}

-(void)cancel
{
  [super cancel];
  
  @synchronized(self) {
    if (self.isExecuting) {
      [self willChangeValueForKey:@"isExecuting"];
      [self willChangeValueForKey:@"isFinished"];
      self.isFinished = YES;
      self.isExecuting = NO;
      [self didChangeValueForKey:@"isFinished"];
      [self didChangeValueForKey:@"isExecuting"];
      
    }
  }
}





@end
