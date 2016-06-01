import Foundation
import XCTest

func TFAssertEquals(a: String, b: String) {
  if a != b {
    fatalError("string '\(a)' not equal to '\(b)'" )
  }
}

func TFAssertEquals(a: Int, b: Int) {
  if a != b {
    fatalError("int '\(a)' not equal to '\(b)'" )
  }
}