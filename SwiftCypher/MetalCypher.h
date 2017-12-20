//
//  MetalCypher.h
//  MetalCypher
//
//  Created by Julio Flores on 12/10/17.
//  Copyright © 2017 ArcTouch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Async.h"

@interface MetalCypher : NSObject

typedef NSNumber * Word;
typedef Async<NSArray<Word> *> * _Nonnull Hash;

@property (readonly) Hash hash;

-(nonnull instancetype)initWithPassword:(nonnull NSString *)password;

@end
