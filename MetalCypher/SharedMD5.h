//
//  SharedMD5.h
//  MetalCypher
//
//  Created by Julio Flores on 13/10/17.
//

/// Inclusions
#pragma mark - Inclusions
#ifndef SharedMD5_h
#define SharedMD5_h

#ifdef METAL
#include <metal_stdlib>
using namespace metal;
#endif

/// Definitions
#pragma mark - Definitions
#ifdef METAL

#define uint64 size_t

#else

#define uint    unsigned int
#define uint64  unsigned long long
#define thread

#endif

#define MAX_PASSWORD_LENGTH 4
#define BYTE_SIZE_IN_BITS   8
#define HASH_SIZE           16
#define BIGGEST_ASCII_DIGIT 0xff

/// Data types
#pragma mark - Data types
#define word  uint
#define byte  unsigned char

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

/// Method declarations
#pragma mark - Method declarations
void passwordFrom(uint64 index, thread byte * output, thread uint * outputSize);
void encode(thread word const * const input, thread byte* output, uint inputSize);
void decode(thread byte const * const input, thread word* output, uint inputSize);

#endif /* SharedMD5_h */
