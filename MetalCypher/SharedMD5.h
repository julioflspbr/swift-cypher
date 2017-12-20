//
//  SharedMD5.h
//  MetalCypher
//
//  Created by Julio Flores on 13/10/17.
//

#ifndef SharedMD5_h
#define SharedMD5_h

/// Inclusions
#ifdef METAL
#include <metal_stdlib>
using namespace metal;
#endif

/// Definitions
#ifndef METAL
#define thread
#define uint unsigned int
#endif

#define MAX_PASSWORD_LENGTH 3
#define BYTE_SIZE_IN_BITS   8
#define HASH_SIZE           16
#define BIGGEST_ASCII_DIGIT 0xff

#define word                uint
#define byte                unsigned char

typedef enum {
  BruteForceParameterHash,
  BruteForceParameterInput,
  BruteForceParameterMatch
} BruteForceParameter;

typedef enum {
  HashifyParameterInput,
  HashifyParameterInputSize,
  HashifyParameterOutput
} HashifyParameter;

/// Declarations
void passwordFrom(uint index, thread byte * output, thread uint * outputSize);
void encode(thread word const * const input, thread byte* output, uint inputSize);
void decode(thread byte const * const input, thread word* output, uint inputSize);

#endif /* SharedMD5_h */
