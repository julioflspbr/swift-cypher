//
//  Async.h
//  MetalCypher
//
//  Created by Julio Flores on 11/10/17.
//

#import <Foundation/Foundation.h>

@interface Async<T> : NSObject {
  id _result;
  id _value;
}

typedef void (^Result)(T _Nonnull);

@property _Nonnull Result result;

@end

