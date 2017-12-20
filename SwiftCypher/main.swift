//
//  main.swift
//  SwiftCypher
//
//  Created by Julio Flores on 13/10/17.
//

import Foundation

enum CommandLineArguments: Int {
  case path, command, argument, count
}

func printUsage() {
  let usage = """
    Usage:
      -h --hashify [password] Outputs the MD5 hash for the desired password
      -r --reveal [hexadecimal MD5 hash] Reveals the password that generated this hash
"""
  print(usage)
}

func hashify() {
  do {
    let password = CommandLine.arguments[CommandLineArguments.argument.rawValue]
    let hashifier = Hashifier(password: password)
    try hashifier.hashify(result: { hashData in
      let hashPointer = hashData.bytes.assumingMemoryBound(to: UInt8.self)
      let hashBuffer = UnsafeBufferPointer(start: hashPointer, count: 16)
      let hashBytes = Array(hashBuffer)
      let hash = hashBytes.reduce("", { $0.appendingFormat("%02x", $1) })
      
      print("That's the hash you're looking for: \(hash)")
    })
  } catch Hashifier.Error.isNotASCII {
    print("All password characters must be ASCII.")
    exit(EXIT_FAILURE)
  } catch {
    print("Unexpected error.")
    exit(EXIT_FAILURE)
  }
}

func reveal() {
  do {
    let hash = CommandLine.arguments[CommandLineArguments.argument.rawValue]
    let revealer = try Revealer(hash: hash)
    print("And the password is 🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁🥁")
    revealer.reveal(
      result: { password in
        print(password)
      },
      error: { error in
        switch error {
        case .isNotASCII:
          print("All password characters must be ASCII.")
        case .notFound:
          print("I wasn't able to find the password for you.")
        }
        exit(EXIT_FAILURE)
      }
    )
  } catch Revealer.Error.Hash.isNotEven {
    print("The hash characters count is not even. Hexadecimal bytes are made of pairs of characters ranging from 0 to F ([0-9A-F]).")
    exit(EXIT_FAILURE)
  } catch Revealer.Error.Hash.isNotHexadecimal {
    print("The hash isn't a valid hexadecimal sequence. Hexadecimal bytes are made of pairs of characters ranging from 0 to F ([0-9A-F]).")
    exit(EXIT_FAILURE)
  } catch {
    print("Unexpected error.")
    exit(EXIT_FAILURE)
  }
}

guard CommandLine.arguments.count == CommandLineArguments.count.rawValue else {
  printUsage()
  exit(EXIT_FAILURE)
}

switch CommandLine.arguments[CommandLineArguments.command.rawValue] {
case "-h", "--hashify":
  hashify()
case "-r", "--reveal":
  reveal()
default:
  printUsage()
  exit(EXIT_FAILURE)
}
