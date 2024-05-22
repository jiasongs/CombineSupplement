//
//  AnyCancellableBag.swift
//  CombineSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import Combine

private struct AnyCancellableBagAssociatedKeys {
    static var bag: UInt8 = 0
    static var lock: UInt8 = 0
}

public typealias AnyCancellables = [AnyCancellable]

public protocol AnyCancellableBag: AnyObject {
    
    var cancellableBag: AnyCancellables { get set }
}

public extension AnyCancellableBag {
    
    var cancellableBag: AnyCancellables {
        get {
            return self.lock.withLock {
                if let cancellableBag = objc_getAssociatedObject(self, &AnyCancellableBagAssociatedKeys.bag) as? AnyCancellables {
                    return cancellableBag
                }
                let cancellableBag: AnyCancellables = []
                objc_setAssociatedObject(self, &AnyCancellableBagAssociatedKeys.bag, cancellableBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cancellableBag
            }
        }
        set {
            self.lock.withLock {
                objc_setAssociatedObject(self, &AnyCancellableBagAssociatedKeys.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var lock: AllocatedUnfairLock {
        let initialize = {
            let value = AllocatedUnfairLock()
            objc_setAssociatedObject(self, &AnyCancellableBagAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self, &AnyCancellableBagAssociatedKeys.lock) as? AllocatedUnfairLock) ?? initialize()
    }
    
}
