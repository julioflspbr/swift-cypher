//
//  Async.m
//  MetalCypher
//
//  Created by Office on 11/10/17.
//

#import "Async_Internal.h"

@implementation Async

- (Result)result {
  return _result;
}

- (void)setResult:(Result)result {
  _result = [result copy];
  [self fire];
}

@end
