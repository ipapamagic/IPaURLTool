//
//  IPaImageURLOperation.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
class IPaImageURLOperation : NSOperation {
    var loadedImageFileURL:NSURL?
    let imageID:String
    var request:NSURLRequest
    var task:NSURLSessionDownloadTask?
    weak var session:NSURLSession?
    var _finished:Bool = false
    override var executing:Bool {
        get {
            return !finished && (task != nil && task!.state == .Running)
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
    init(request:NSURLRequest,imageID:String,session:NSURLSession) {
        self.request = request
        self.imageID = imageID
        self.session = session
    }
    override func start() {
        if cancelled
        {
            finished = true
            return;
        }
        self.willChangeValueForKey("isExecuting")
        task = session?.downloadTaskWithRequest(request, completionHandler: {(location,response,error) in
            if error == nil {
                if self.cancelled {
                    return
                }
                self.loadedImageFileURL = location
            }
            self.willChangeValueForKey("isExecuting")
            self.finished = true
            self.didChangeValueForKey("isExecuting")
            
        })
        task?.resume()
        self.didChangeValueForKey("isExecuting")
        
    }
    override func cancel() {
        super.cancel()
        if executing {
            self.willChangeValueForKey("isExecuting")
            self.finished = true
            task?.cancel()
            task = nil
            self.didChangeValueForKey("isExecuting")
            
        }
    }
}
