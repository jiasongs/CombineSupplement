//
//  AnyObject+Cancellable.swift
//  CombineSupplement
//
//  Created by jiasong on 2023/6/1.
//

import Foundation
import Combine
import ThreadSafe

private struct AssociatedKeys {
    static var readWrite: UInt8 = 0
}

public extension CombineWrapper where Base: AnyObject {
    
    var cancellableBag: CancellableBag {
        get {
            return self.readWrite.value
        }
        set {
            self.readWrite.value = newValue
        }
    }
    
    private var readWrite: ReadWriteValue<CancellableBag> {
        let initialize = {
            let value = ReadWriteValue(CancellableBag(), task: ReadWriteTask(label: "com.jiasong.combine-supplement.cancellable-bag"))
            objc_setAssociatedObject(self.base, &AssociatedKeys.readWrite, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return (objc_getAssociatedObject(self.base, &AssociatedKeys.readWrite) as? ReadWriteValue<CancellableBag>) ?? initialize()
    }
    
}
