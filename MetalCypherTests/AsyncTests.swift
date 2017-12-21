//
//  AsyncTests.swift
//  MetalCypherTests
//
//  Created by Julio Flores on 20/12/17.
//

import XCTest

class AsyncTests: XCTestCase {
  func testAsyncResultFiringAfterSettingValue() {
    let asyncResult = Async<NSString>()
    let anyString = "A string to be tested"
    var stringToMatch = ""
    
    asyncResult.result = { theResult in
      stringToMatch = theResult as String
    }
    
    XCTAssertEqual(stringToMatch, "")
    asyncResult.value = anyString as NSString
    XCTAssertEqual(stringToMatch, anyString)
  }
  
  func testAsyncResultFiringImmediatelyBecauseValueIsAlreadySet() {
    let asyncResult = Async<NSString>()
    let anyString = "A string to be tested"
    var stringToMatch = ""
    
    asyncResult.value = anyString as NSString
    
    asyncResult.result = { theResult in
      stringToMatch = theResult as String
    }
    
    XCTAssertEqual(stringToMatch, anyString)
  }
}
