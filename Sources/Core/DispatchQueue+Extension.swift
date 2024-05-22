//
//  DispatchQueue+Extension.swift
//  CombineSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation

private struct QueueAssociatedKeys {
    static var lock: UInt8 = 0
}

fileprivate extension DispatchQueue {
    
    static var mainKey: DispatchSpecificKey<UUID> = {
        let key = DispatchSpecificKey<UUID>()
        DispatchQueue.main.setSpecific(key: key, value: UUID())
        return key
    }()
    
    static let detectionKey = DispatchSpecificKey<UUID>()
    
}

extension CombineWrapper where Base: DispatchQueue {
    
    internal static var isMain: Bool {
        return DispatchQueue.main.combine.lock.withLock {
            return Base.getSpecific(key: Base.mainKey) != nil
        }
    }
    
    @discardableResult
    internal func safeSync<T>(execute work: () -> T) -> T {
        let initialize = {
            let uuid = UUID()
            self.base.setSpecific(key: Base.detectionKey, value: uuid)
            return uuid
        }
        let isEqual = self.lock.withLock {
            let value = self.base.getSpecific(key: Base.detectionKey) ?? initialize()
            let currentValue = Base.getSpecific(key: Base.detectionKey)
            return currentValue == value
        }
        if isEqual {
            return work()
        } else {
            return self.base.sync(execute: work)
        }
    }
    
    private var lock: AllocatedUnfairLock {
        let initialize = {
            let value = AllocatedUnfairLock()
            objc_setAssociatedObject(self.base, &QueueAssociatedKeys.lock, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self.base, &QueueAssociatedKeys.lock) as? AllocatedUnfairLock) ?? initialize()
    }
    
}
