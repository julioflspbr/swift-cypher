//
//  MetalCypher.metal
//  MetalCypher
//
//  Created by Julio Flores on 31/10/17.
//

#include <metal_stdlib>
#include "MD5.h"
#include "SharedMD5.h"

#define LONGEST_PROBABILITY_TEST_COUNT_PRECISION 8 // an 8-byte number would give us 18.446.744.073.709.551.615 test possibilities

using namespace metal;

kernel void bruteForce(constant uint4 const * hash      [[buffer(BruteForceParameterHash)]],
                       constant uint2 const * input     [[buffer(BruteForceParameterInput)]],
                       device   atomic_uint * match     [[buffer(BruteForceParameterMatch)]],
                       thread   uint          threadID  [[thread_position_in_grid]]) {
  if (atomic_load_explicit(match, memory_order_relaxed) > 0) return;
  
  thread byte password[LONGEST_PROBABILITY_TEST_COUNT_PRECISION];
  thread uint passwordSize;
  
  uint64 localInput = ((uint64)input->y << sizeof(word) * BYTE_SIZE_IN_BITS) | (input->x);
  passwordFrom(localInput + threadID, password, &passwordSize);
  
  thread MD5 md5(password, passwordSize);
  thread bool nonMatching = (hash->x ^ md5.output.x) | (hash->y ^ md5.output.y) | (hash->z ^ md5.output.z) | (hash->w ^ md5.output.w);
  
  thread uint mask = 0;
  thread uint64 uintSizeInBits = sizeof(uint) * BYTE_SIZE_IN_BITS;
  for (thread uint i = 0; i < uintSizeInBits; i++) {
    mask |= nonMatching << i;
  }
  mask = ~mask;
  
  thread uint store = mask & (threadID + 1);
  thread uint zero = 0;
  atomic_compare_exchange_weak_explicit(match, &zero, store, memory_order_relaxed, memory_order_relaxed);
}

kernel void hashify(constant byte const  * input      [[buffer(HashifyParameterInput)]],
                    constant uint const  * inputSize  [[buffer(HashifyParameterInputSize)]],
                    device   byte        * output     [[buffer(HashifyParameterOutput)]]) {
  thread byte password[MAX_PASSWORD_LENGTH];
  thread uint passwordSize = *inputSize;
  for (uint i = 0; i < *inputSize; i++) {
    password[i] = input[i];
  }
  MD5 md5(password, passwordSize);

  thread uint intermediateOutput[4] = { md5.output.x, md5.output.y, md5.output.z, md5.output.w };
  thread byte localOutput[HASH_SIZE];
  encode(intermediateOutput, localOutput, 4);
  
  for (uint i = 0; i < HASH_SIZE; i++) {
    output[i] = localOutput[i];
  }
}
