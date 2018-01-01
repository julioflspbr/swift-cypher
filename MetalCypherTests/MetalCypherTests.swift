//
//  MetalCypherTests.swift
//  MetalCypherTests
//
//  Created by Julio Flores on 21/12/17.
//

import XCTest

class MetalCypherTests: XCTestCase {
  private enum Error: Swift.Error {
    case isNotEven, isNotHexadecimal
  }
  
  func testHashifyPassword() {
    let passwordToMatch = "lalalones"
    let hashToMatch = "2a02361bcbf503bcab5f2ca312cca383"
    
    guard let passwordData = passwordToMatch.data(using: .ascii) else {
      XCTFail("The password is generating no bytes")
      return
    }
    let hashifier = MetalCypher(password: passwordData)
    let expectPasswordToMatch = expectation(description: "Matching password")
    let expectHashToMatch = expectation(description: "Matching hash")
    
    hashifier.password.result = { passwordData in
      let password = String(data: passwordData as Data, encoding: .ascii)
      
      XCTAssertEqual(passwordToMatch, password)
      expectPasswordToMatch.fulfill()
    }
    hashifier.hash.result = { hashData in
      let hash = self.convertToString(theHashData: hashData)
      
      XCTAssertEqual(hashToMatch, hash)
      expectHashToMatch.fulfill()
    }
    
    waitForExpectations(timeout: 1.0)
  }
  
  func testBruteForceHash() {
    let passwordToMatch = "la"
    let hashToMatch = "c9089f3c9adaf0186f6ffb1ee8d6501c"
    
    guard let hashData = try? convertToData(theStringifiedHash: hashToMatch) else {
      XCTFail("The hash characters count isn't even or is not hexadecimal.")
      return
    }
    let hashifier = MetalCypher(hash: hashData)
    let expectPasswordToMatch = expectation(description: "Matching password")
    let expectHashToMatch = expectation(description: "Matching hash")
    
    hashifier.password.result = { passwordData in
      let password = String(data: passwordData as Data, encoding: .ascii)
      
      XCTAssertEqual(passwordToMatch, password)
      expectPasswordToMatch.fulfill()
    }
    hashifier.hash.result = { hashData in
      let hash = self.convertToString(theHashData: hashData)
      
      XCTAssertEqual(hashToMatch, hash)
      expectHashToMatch.fulfill()
    }
    
    waitForExpectations(timeout: 1.0)
  }
  
  private func convertToString(theHashData hashData: NSData) -> String {
    let hashPointer = hashData.bytes.assumingMemoryBound(to: UInt8.self)
    let hashBuffer = UnsafeBufferPointer(start: hashPointer, count: 16)
    let hashBytes = Array(hashBuffer)
    let hash = hashBytes.reduce("", { $0.appendingFormat("%02x", $1) })
    
    return hash
  }
  
  private func convertToData(theStringifiedHash hashString: String) throws -> Data {
    guard hashString.count % 2 == 0 else {
      throw Error.isNotEven
    }
    
    var hex = String()
    var hashBytes = [UInt8]()
    
    for (i, char) in hashString.enumerated() {
      let shouldWrapUpHex = i % 2 == 1
      if !shouldWrapUpHex {
        hex = "0x\(char)"
      } else {
        hex.append(char)
        let scanner = Scanner(string: hex)
        var integer: UInt32 = 0
        guard scanner.scanHexInt32(&integer) else {
          throw Error.isNotHexadecimal
        }
        hashBytes.append(UInt8(integer))
      }
    }
    
    return Data(bytes: hashBytes)
  }
}
