//
//  Async_Internal.c
//  MetalCypher
//
//  Created by Office on 13/10/17.
//

#import "Async_Internal.h"

@implementation Async (Internal)

- (id)value {
  return _value;
}

- (void)setValue:(id)value {
  _value = value;
  [self fire];
}

- (void)fire {
  if (!_value) {
    return;
  }
  
  if ([self result]) {
    [self result]([self value]);
  }
}

@end
