//
//  HashifierTests.swift
//  HashifierTests
//
//  Created by Julio Flores on 22/12/17.
//

import XCTest

class HashifierTests: XCTestCase {
  private static let password = "lalalones"
  private static let hashToMatch = "2a02361bcbf503bcab5f2ca312cca383"
  
  func testHashifierDirectly() {
    let hashifier = Hashifier(password: HashifierTests.password)
    let hashifyExpectation = expectation(description: "Hashify")
    
    do {
      try hashifier.hashify { [weak self] data in
        guard let `self` = self else { return }
        let generatedHash = self.convertToString(theHashData: data)
        
        XCTAssertEqual(HashifierTests.hashToMatch, generatedHash)
        hashifyExpectation.fulfill()
      }
      
      waitForExpectations(timeout: 1.0)
    } catch let error {
      XCTFail("Error while hashing password: \(error)")
    }
  }
  
  func testHashifierDirectlyPerformance() {
    self.measure(testHashifierDirectly)
  }
  
  func testHashifierViaCommandLinePerformance() {
    self.measure {
      CommandLine.arguments[CommandLineArguments.argument.rawValue] = HashifierTests.password
      hashify()
    }
  }
  
  private func convertToString(theHashData hashData: NSData) -> String {
    let hashPointer = hashData.bytes.assumingMemoryBound(to: UInt8.self)
    let hashBuffer = UnsafeBufferPointer(start: hashPointer, count: 16)
    let hashBytes = Array(hashBuffer)
    let hash = hashBytes.reduce("", { $0.appendingFormat("%02x", $1) })
    
    return hash
  }
}
