//
//  Revealer.swift
//  SwiftCypher
//
//  Created by Julio Flores on 05/12/17.
//

import Foundation

struct Revealer {
  enum Error {
    enum Hash: Swift.Error {
      case isNotEven
      case isNotHexadecimal
    }
    enum Password: Swift.Error {
      case notFound
      case isNotASCII
    }
  }
  private let hash: [UInt8]
  
  init(hash: String) throws {
    guard hash.count % 2 == 0 else {
      throw Error.Hash.isNotEven
    }
    
    var hex = String()
    var tempHash = [UInt8]()
    
    for (i, char) in hash.enumerated() {
      let shouldWrapUpHex = i % 2 == 1
      if !shouldWrapUpHex {
        hex = "0x\(char)"
      } else {
        hex.append(char)
        let scanner = Scanner(string: hex)
        var integer: UInt32 = 0
        guard scanner.scanHexInt32(&integer) else {
          throw Error.Hash.isNotHexadecimal
        }
        tempHash.append(UInt8(integer))
      }
    }
    
    self.hash = tempHash
  }
  
  func reveal(result: @escaping (String) -> Void, error: @escaping (Revealer.Error.Password) -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    let cypher = MetalCypher(hash: Data(bytes: self.hash))
    
    cypher.password.result = { output in
      guard let password = String(data: output as Data, encoding: .ascii) else {
        error(.isNotASCII)
        semaphore.signal()
        return
      }
      
      guard password != "" else {
        error(.notFound)
        semaphore.signal()
        return
      }
      
      result(password)
      semaphore.signal()
    }
    
    semaphore.wait() 
  }
}
