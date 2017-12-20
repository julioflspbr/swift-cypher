//
//  MD5.metal
//  SwiftCypher
//
//  Created by Julio Flores on 18/09/17.
//

#include "MD5.h"

/* MD5 implementation */
MD5::MD5(thread byte const * const input, size_t const inputSize):
input(input),
inputSize(inputSize) {
  entail();
  process();
  result();
}

void MD5::entail() {
  word count[2];
  for (uint i = 0; i < 2; i++) {
    count[i] = (inputSize << 3) >> (sizeof(word) * BYTE_SIZE_IN_BITS * i);
  }
  
  encode(count, tail, 2);
}

void MD5::process() {
#define PROCESSING_INPUT    remaining >= paddingSize
#define PROCESSING_PADDING  remaining >= tailSize && remaining < paddingSize
#define PROCESSING_TAIL     remaining < tailSize
#define END_OF_BLOCK        BLOCK_SIZE - 1
  
  byte block[BLOCK_SIZE];
  uint const paddingSize = (BLOCK_SIZE - (inputSize % BLOCK_SIZE));
  uint const tailSize = PADDING_TAIL_SIZE;
  uint const coreSize = inputSize + paddingSize;
  uint remaining = coreSize;
  uint index;
  uint blockIndex;
  uint tailIndex;
  
  while (remaining > 0) {
    index = coreSize - remaining--;
    blockIndex = index % BLOCK_SIZE;
    
    if (PROCESSING_INPUT) {
      block[blockIndex] = input[index];
    } else if (PROCESSING_PADDING) {
      block[blockIndex] = (index - inputSize == 0) ? 0x80 : 0x0;
    } else if (PROCESSING_TAIL) {
      tailIndex = tailSize - remaining - 1;
      block[blockIndex] = tail[tailIndex];
    }
    
    if (blockIndex == END_OF_BLOCK) {
      processBlock(block);
    }
  }
}

void MD5::processBlock(thread byte const block[]) {
  word buffer[WORDS_PER_ROUND];
  word a = A, b = B, c = C, d = D;
  
  decode(block, buffer, BLOCK_SIZE);
  
  processRound(RoundOne,    a, b, c, d, buffer);
  processRound(RoundTwo,    a, b, c, d, buffer);
  processRound(RoundThree,  a, b, c, d, buffer);
  processRound(RoundFour,   a, b, c, d, buffer);
  
  A += a; B += b; C += c; D += d;
}

void MD5::processRound(Round const round, thread word &a, thread word &b, thread word &c, thread word &d, thread word const block[]) {
  WordSorting wordSortingIndex;
  uint s;
  
  for (uint m = 0; m < WORDS_PER_ROUND; m++) {
    wordSortingIndex = (WordSorting)(m % SHIFT_SIZE);
    s = WORDS_PER_ROUND * round + m;
    
    switch(wordSortingIndex) {
      case ABCD:
        processWord(round, a, b, c, d, block[MESSAGE_INDEX[round][m]], SALT[s], SHIFT[round][wordSortingIndex]); break;
      case DABC:
        processWord(round, d, a, b, c, block[MESSAGE_INDEX[round][m]], SALT[s], SHIFT[round][wordSortingIndex]); break;
      case CDAB:
        processWord(round, c, d, a, b, block[MESSAGE_INDEX[round][m]], SALT[s], SHIFT[round][wordSortingIndex]); break;
      case BCDA:
        processWord(round, b, c, d, a, block[MESSAGE_INDEX[round][m]], SALT[s], SHIFT[round][wordSortingIndex]); break;
    }
  }
}

void MD5::processWord(Round const round, thread word &a, word b, word c, word d, word const theWord, word salt, ushort shift) {
  a += puzzle(round)(b, c, d) + theWord + salt;
  a = (a << shift) | (a >> (32 - shift));
  a += b;
}

MD5::Puzzle MD5::puzzle(Round const round) {
  switch (round) {
    case RoundOne:    return F;
    case RoundTwo:    return G;
    case RoundThree:  return H;
    case RoundFour:   return I;
  }
}

void MD5::result() {
  word pack[4] = { A, B, C, D };
  encode(pack, output, 4);
}

word MD5::F(word X, word Y, word Z) {
  return (X & Y) | (~X & Z);
}

word MD5::G(word X, word Y, word Z) {
  return (X & Z) | (Y & ~Z);
}

word MD5::H(word X, word Y, word Z) {
  return X ^ Y ^ Z;
}

word MD5::I(word X, word Y, word Z) {
  return Y ^ (X | ~Z);
}

/* MD5 implementation */
