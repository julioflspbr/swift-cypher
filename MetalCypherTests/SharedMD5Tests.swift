//
//  SharedMD5Tests.swift
//  SharedMD5Tests
//
//  Created by Julio Flores on 20/12/17.
//

import XCTest

class SharedMD5Tests: XCTestCase {
  func testPasswordFrom() {
    let passwordToMatch = "la"
    let bytesToMatch = passwordToMatch.utf8.map({ $0 as UInt8 })
    
    let index: UInt64 = 24940 // this index is equivalent to "la" (ASCII indices "\0" = 0, "\1" = 1, ... "a" = 97, "b" = 98, ... "aa" = 24673, ... "la" = 24940)
    var passwordLength: UInt32 = 0
    let outputPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 10)
    
    passwordFrom(index, outputPointer, &passwordLength)
    
    var output = [UInt8]()
    for i in 0 ..< Int(passwordLength) {
      output.append(outputPointer.advanced(by: i).pointee)
    }
    
    XCTAssertEqual(bytesToMatch, output)
  }
  
  func testEncode() {
    let match: [UInt8] = [0b01101001, 0b11110000, 0b00001111, 0b11111111]
    var input: UInt32 = 0b11111111_00001111_11110000_01101001
    let outputPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: match.count)
    var output = [UInt8]()
    
    encode(&input, outputPointer, 1)
    
    for i in 0 ..< match.count {
      output.append(outputPointer.advanced(by: i).pointee)
    }
    
    XCTAssertEqual(match, output)
  }
  
  func testDecode() {
    let match: UInt32 = 0b11111111_00001111_11110000_01101001
    let input: [UInt8] = [0b01101001, 0b11110000, 0b00001111, 0b11111111]
    let inputPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: input.count)
    var output: UInt32 = 0
    
    for i in 0 ..< input.count {
      inputPointer.advanced(by: i).pointee = input[i]
    }
    
    decode(inputPointer, &output, UInt32(input.count))
    
    XCTAssertEqual(match, output)
  }
}
