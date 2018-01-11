
//
//  MetalCypher.m
//  MetalCypher
//
//  Created by Julio Flores on 12/10/17.
//

#import "Async_Internal.h"
#import "MetalCypher.h"
#import "SharedMD5.h"
#import <os/log.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#define MAX_TRIALS  (256 << (8 * (MAX_PASSWORD_LENGTH - 1)))
#define BATCH_SIZE  (1 << 20) /* one mega trials */

#define kernelBruteForce  @"bruteForce"
#define kernelHashify     @"hashify"

/// Private MetalCypher declaration
#pragma mark - Private MetalCypher declaration -
@interface MetalCypher (Private)

@property (readonly) NSBundle * _Nonnull defaultBundle;

-(void)bruteForce;
-(void)hashify;

@end

/// MetalCypher Implementation
#pragma mark - MetalCypher Implementation -
@implementation MetalCypher {
  id<MTLDevice> device;
  id<MTLLibrary> defaultLibrary;
  id<MTLCommandQueue> commandQueue;
  id<MTLComputePipelineState> pipeline;
  id<MTLBuffer> hashBuffer;
  id<MTLBuffer> inputBuffer;
  id<MTLBuffer> inputSizeBuffer;
  id<MTLBuffer> matchBuffer;
  id<MTLBuffer> outputBuffer;
  uint trials;
}

@synthesize password;
@synthesize hash;

- (NSBundle *)defaultBundle {
  return [NSBundle bundleWithPath:[[NSProcessInfo processInfo] environment][@"PWD"]];
}

- (instancetype)initWithHash:(NSData *)theHash {
  if (!self) {
    return nil;
  }
  
  device          = MTLCreateSystemDefaultDevice();
  defaultLibrary  = [device newDefaultLibraryWithBundle:[self defaultBundle] error:nil];
  commandQueue    = [device newCommandQueue];
  hashBuffer      = [device newBufferWithLength:sizeof(simd_uint4)  options:MTLResourceOptionCPUCacheModeWriteCombined];
  inputBuffer     = [device newBufferWithLength:sizeof(uint)        options:MTLResourceOptionCPUCacheModeWriteCombined];
  matchBuffer     = [device newBufferWithLength:sizeof(uint)        options:MTLResourceStorageModeShared];
  
  pipeline = [device newComputePipelineStateWithFunction:[defaultLibrary newFunctionWithName:kernelBruteForce] error:nil];
  
  trials = 0;
  password = [MD5Result new];
  hash = [MD5Result new];
  
  [hash setValue:theHash];
  
  simd_uint4 * hashBufferContents = [hashBuffer contents];
  byte * hashBytes = (byte *)[theHash bytes];
  uint hashBuffer[sizeof(word)];
  
  decode(hashBytes, hashBuffer, HASH_SIZE);
  for (uint i = 0; i < sizeof(word); i++) {
    (*hashBufferContents)[i] = hashBuffer[i];
  }
  
  [self bruteForce];
  
  return self;
}

- (instancetype)initWithPassword:(NSData *)thePassword {
  if (!self) {
    return nil;
  }
  
  device          = MTLCreateSystemDefaultDevice();
  defaultLibrary  = [device newDefaultLibraryWithBundle:[self defaultBundle] error:nil];
  commandQueue    = [device newCommandQueue];
  inputBuffer     = [device newBufferWithLength:[thePassword length]  options:MTLResourceOptionCPUCacheModeWriteCombined];
  inputSizeBuffer = [device newBufferWithLength:sizeof(uint)          options:MTLResourceOptionCPUCacheModeWriteCombined];
  outputBuffer    = [device newBufferWithLength:sizeof(uint)          options:MTLResourceStorageModeShared];
  
  pipeline = [device newComputePipelineStateWithFunction:[defaultLibrary newFunctionWithName:kernelHashify] error:nil];
  
  password = [MD5Result new];
  hash = [MD5Result new];
  
  [password setValue:thePassword];
  
  byte * input = [inputBuffer contents];
  uint * inputSize = [inputSizeBuffer contents];
  byte * password = (byte *)[thePassword bytes];
  for (uint i = 0; i < [thePassword length]; i++) {
    input[i] = password[i];
  }
  *inputSize = (uint)[thePassword length];
  
  [self hashify];
  
  return self;
}

- (void)bruteForce {
  if (trials >= MAX_TRIALS) {
    [self.password setValue:[NSData data]];
    return;
  }
  
  id<MTLCommandBuffer> commandBuffer;
  id<MTLComputeCommandEncoder> computeEncoder;
  MTLSize threadsPerThreadgroup;
  MTLSize grid;
  NSUInteger currentTrials = MIN((MAX_TRIALS - trials), BATCH_SIZE);
  
  uint * input = [inputBuffer contents];
  uint * match = [matchBuffer contents];
  
  *input = trials;
  
  threadsPerThreadgroup = MTLSizeMake([pipeline maxTotalThreadsPerThreadgroup], 1, 1);
  grid = MTLSizeMake(currentTrials, 1, 1);
  
  commandBuffer = [commandQueue commandBuffer];
  computeEncoder = [commandBuffer computeCommandEncoder];
  [computeEncoder setComputePipelineState:pipeline];
  [computeEncoder setBuffer:hashBuffer  offset:0 atIndex:BruteForceParameterHash];
  [computeEncoder setBuffer:inputBuffer offset:0 atIndex:BruteForceParameterInput];
  [computeEncoder setBuffer:matchBuffer offset:0 atIndex:BruteForceParameterMatch];
  [computeEncoder dispatchThreads:grid threadsPerThreadgroup:threadsPerThreadgroup];
  [computeEncoder endEncoding];
  
  __weak MetalCypher * _self = self;
  [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    if (!_self) return;
    
    byte output[MAX_PASSWORD_LENGTH];
    uint outputSize;
    if (*match > 0) {
      passwordFrom(trials + *match - 1, output, &outputSize);
      [_self.password setValue:[NSData dataWithBytes:output length:outputSize]];
      return;
    }
    
    trials += currentTrials;
    [_self bruteForce];
  }];
  
  [commandBuffer commit];
}

- (void)hashify {
  id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
  id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
  MTLSize gridSize = MTLSizeMake(1, 1, 1);
  
  byte * output = [outputBuffer contents];
  
  [computeEncoder setComputePipelineState:pipeline];
  [computeEncoder setBuffer:inputBuffer     offset:0 atIndex:HashifyParameterInput];
  [computeEncoder setBuffer:inputSizeBuffer offset:0 atIndex:HashifyParameterInputSize];
  [computeEncoder setBuffer:outputBuffer    offset:0 atIndex:HashifyParameterOutput];
  [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:gridSize];
  [computeEncoder endEncoding];
  
  __weak MetalCypher * _self = self;
  [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    [_self.hash setValue:[NSData dataWithBytes:output length:HASH_SIZE]];
  }];
  [commandBuffer commit];
}

@end
