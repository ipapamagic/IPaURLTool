//
//  IPaBlockOperation.swift
//  IPaBlockOperation
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
typealias  IPaBlockOperationBlock = (_ complete: @escaping () -> ()) -> ()
class IPaBlockOperation : Operation {
    var operationBlock :IPaBlockOperationBlock
    var _executing:Bool = false
    var _finished:Bool = false
    override var isExecuting:Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished:Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    override var isConcurrent:Bool {
        get {
            return true
        }
    }
    init(block:@escaping IPaBlockOperationBlock) {
        operationBlock = block
    }
    override func start() {
        if isCancelled {
            isFinished = true
            return;
        }
        
        
        isExecuting = true
        
        operationBlock({
            self.isFinished = true
            self.isExecuting = false
            
        })
    }
    override func cancel() {
        if isExecuting {
            isFinished = true
            isExecuting = false
        }
    }
}



