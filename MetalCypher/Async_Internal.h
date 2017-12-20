//
//  Async_Internal.h
//  MetalCypher
//
//  Created by Julio Flores on 13/10/17.
//

#import "Async.h"

@interface Async<T> (Internal)

@property _Nonnull T value;

-(void)fire;

@end
