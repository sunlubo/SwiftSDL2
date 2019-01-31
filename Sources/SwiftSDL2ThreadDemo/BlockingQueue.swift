//
//  BlockingQueue.swift
//  ThreadDemo
//
//  Created by sunlubo on 2018/8/17.
//

import SwiftSDL2

public final class BlockingQueue<T> {
  private let capacity: Int
  private var list: [T]
  private var mutex = Mutex()
  private var cond = Condition()
  
  public init(capacity: Int) {
    self.capacity = capacity
    self.list = []
  }
  
  /// A Boolean value indicating whether the queue is empty.
  public var isEmpty: Bool {
    return list.isEmpty
  }
  
  public func put(_ value: T) {
    mutex.lock()
    while list.count == capacity {
      cond.wait(mutex: mutex)
    }
    
    list.append(value)
    
    cond.signal()
    mutex.unlock()
  }
  
  public func take() -> T {
    mutex.lock()
    while list.count == 0 {
      cond.wait(mutex: mutex)
    }
    
    let value = list.removeFirst()
    
    cond.signal()
    mutex.unlock()
    
    return value
  }
  
  public func take(timeout: Int) -> T? {
    mutex.lock()
    while list.count == 0 {
      if !(cond.wait(mutex: mutex, timeout: timeout)) {
        mutex.unlock()
        return nil
      }
    }
    
    let value = list.removeFirst()
    
    cond.signal()
    mutex.unlock()
    
    return value
  }
}
