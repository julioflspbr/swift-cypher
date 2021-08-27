//
//  Hashifier.swift
//  SwiftCypher
//
//  Created by Julio Flores on 05/12/17.
//

import Foundation

struct Hashifier {
  enum Error: Swift.Error {
    case isNotASCII
  }
  
  private let password: String
  init(password: String) {
    self.password = password
  }
  
	func hashify(bundle: Bundle? = nil, result: @escaping (NSData) -> Void) throws {
    guard let passwordData = self.password.data(using: .ascii) else {
      throw Error.isNotASCII
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    let cypher = MetalCypher(password: passwordData, in: bundle)
    
    cypher.hash.result = { output in
      result(output)
      semaphore.signal()
    }
    
    semaphore.wait()
  }
}
