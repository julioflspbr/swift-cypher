//
//  Async.h
//  MetalCypher
//
//  Created by Julio Flores on 11/10/17.
//  Copyright © 2017 ArcTouch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Async<T> : NSObject {
  id _result;
  id _value;
}

typedef void (^Result)(T _Nullable);

@property _Nullable Result result;

@end

