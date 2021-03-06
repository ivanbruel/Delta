//
//  DeltaCalculator.swift
//
//  Created by Ivan Bruel on 29/02/16.
//

import Foundation

public enum DeltaOptions {
  case IgnoreRemove
  case IgnoreInsertAndMove
}

public class DeltaCalculator<T> {

  public var options: [DeltaOptions]
  public let equalityTest: (T, T) -> Bool

  public init(options: [DeltaOptions]? = nil, equalityTest: ((T, T) -> Bool)) {
    self.options = options ?? []
    self.equalityTest = equalityTest
  }

  public func deltaFromOldArray(oldArray: [T], toNewArray newArray: [T]) -> Delta {
    let unchangedIndices = NSMutableIndexSet()
    var movedIndices = [(Int, Int)]()
    let addedNewIndices = NSMutableIndexSet()
    let removedOldIndices = NSMutableIndexSet()

    // Unchanged
    let minIndex = min(oldArray.count, newArray.count)
    for index in 0..<minIndex {
      if equalityTest(oldArray[index], newArray[index]) {
        unchangedIndices.addIndex(index)
      }
    }

    // Moved and added
    if !options.contains(.IgnoreInsertAndMove) {
      for index in 0..<newArray.count {
        guard !unchangedIndices.contains(index) else {
          continue
        }

        let newItem = newArray[index]
        guard let oldIndex = oldArray.indexOf({ self.equalityTest($0, newItem) }) else {
          addedNewIndices.addIndex(index)
          continue
        }

        movedIndices.append((oldIndex, index))
      }
    }

    // Removed
    if !options.contains(.IgnoreRemove) {
      for index in 0..<oldArray.count {
        let oldItem = oldArray[index]
        guard let _ = newArray.indexOf({ self.equalityTest($0, oldItem) }) else {
          removedOldIndices.addIndex(index)
          continue
        }
      }
    }

    return Delta(addedIndices: addedNewIndices, removedIndices: removedOldIndices,
      movedIndexPairs: movedIndices, unchangedIndices: unchangedIndices)
  }

}

extension DeltaCalculator where T: Equatable {

  public convenience init() {
    self.init() { (lhs, rhs) -> Bool in
      return lhs == rhs
    }
  }

}
