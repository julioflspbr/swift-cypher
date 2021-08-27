//
//  RevealerTests.swift
//  SwiftCypherTests
//
//  Created by Julio Flores on 28/12/17.
//

import XCTest

class RevealerTests: XCTestCase {
  private static let hashToReveal = "c9089f3c9adaf0186f6ffb1ee8d6501c"
  private static let passwordToMatch = "la"
	private static let testBundle: Bundle = {
		let bundle = Bundle(for: MetalCypher.self)
		let metalBundleURL = bundle.bundleURL.deletingLastPathComponent()
		return Bundle(url: metalBundleURL)!
	}()
  
  func testRevealerDirectly() {
    let passwordExpectation = expectation(description: "Revealing password expectation")
    do {
      let revealer = try Revealer(hash: RevealerTests.hashToReveal)
			revealer.reveal(bundle: RevealerTests.testBundle, result: { password in
        XCTAssertEqual(RevealerTests.passwordToMatch, password)
        passwordExpectation.fulfill()
      }, error: { error in
        XCTFail("Error while brute forcing the hash: \(error)")
      })
    } catch let error {
      XCTFail("Error while brute forcing the hash: \(error)")
    }
    waitForExpectations(timeout: 1.0)
  }
  
  func testRevealerDirectlyPerformance() {
    self.measure(testRevealerDirectly)
  }
  
  func testRevealerViaCommandLinePerformance() {
    self.measure {
      CommandLine.arguments[CommandLineArguments.argument.rawValue] = RevealerTests.hashToReveal
			reveal(bundle: RevealerTests.testBundle)
    }
  }
}
