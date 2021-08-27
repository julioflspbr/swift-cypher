//
//  MetalCypher.h
//  MetalCypher
//
//  Created by Julio Flores on 12/10/17.
//

#import <Foundation/Foundation.h>
#import "Async.h"

@interface MetalCypher : NSObject

typedef Async<NSData *> MD5Result;

@property (readonly) MD5Result * _Nonnull password;
@property (readonly) MD5Result * _Nonnull hash;

-(nonnull instancetype)initWithHash:(nonnull NSData *)hash inBundle:(nullable NSBundle *)bundle;
-(nonnull instancetype)initWithPassword:(nonnull NSData *)password  inBundle:(nullable NSBundle *)bundle;

@end
