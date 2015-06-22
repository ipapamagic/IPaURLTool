//
//  IPaBlockOperation.swift
//  IPaBlockOperation
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
typealias  IPaBlockOperationBlock = (complete:() -> ()) -> ()
class IPaBlockOperation : NSOperation {
    var operationBlock :IPaBlockOperationBlock
    var _executing:Bool = false
    var _finished:Bool = false
    override var executing:Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished:Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    override var concurrent:Bool {
        get {
            return true
        }
    }
    init(block:IPaBlockOperationBlock) {
        operationBlock = block
    }
    override func start() {
        if cancelled {
            finished = true
            return;
        }
 

        executing = true

        operationBlock(complete: {
            self.finished = true
            self.executing = false
        
        })
    }
    override func cancel() {
        if executing {
            finished = true
            executing = false
        }
    }
}



