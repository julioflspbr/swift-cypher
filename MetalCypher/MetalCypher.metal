//
//  MetalCypher.metal
//  MetalCypher
//
//  Created by Julio Flores on 31/10/17.
//

#include <metal_stdlib>
#include "MD5.h"
#include "SharedMD5.h"

using namespace metal;

kernel void bruteForce(constant byte const  * hash      [[buffer(BruteForceParameterHash)]],
                       constant uint const  * input     [[buffer(BruteForceParameterInput)]],
                       device   uint        * match     [[buffer(BruteForceParameterMatch)]],
                       thread   uint          threadID  [[thread_position_in_grid]]) {
  thread byte password[MAX_PASSWORD_LENGTH];
  uint passwordSize;
  
  passwordFrom(*input + threadID, password, &passwordSize);
  MD5 md5(password, passwordSize);
  
  for (uint i = 0; i < HASH_SIZE; i++) {
    if (hash[i] != md5.output[i]) return;
  }
  *match = threadID + 1;
}

kernel void hashify(constant byte const  * input      [[buffer(HashifyParameterInput)]],
                    constant uint const  * inputSize  [[buffer(HashifyParameterInputSize)]],
                    device   byte        * output     [[buffer(HashifyParameterOutput)]]) {
  thread byte password[MAX_PASSWORD_LENGTH];
  uint passwordSize = *inputSize;
  for (uint i = 0; i < *inputSize; i++) {
    password[i] = input[i];
  }
  MD5 md5(password, passwordSize);
  
  for (uint i = 0; i < HASH_SIZE; i++) {
    output[i] = md5.output[i];    
  }
}
