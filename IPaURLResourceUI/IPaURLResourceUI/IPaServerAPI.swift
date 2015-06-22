//
//  IPaServerAPI.swift
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

import Foundation

class IPaServerAPI :NSObject {
    let resourceUI:IPaURLResourceUI
    var currentAPITask:NSURLSessionDataTask?
    init(resourceUI:IPaURLResourceUI) {
        self.resourceUI = resourceUI
    }
    func apiPerform(api:String,method:String,param:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) {
        
        if let task = currentAPITask {
            if task.state == .Running {
                task.cancel()
            }
        }

        let aMethod = method.uppercaseString
        if aMethod == "GET" {
            currentAPITask = resourceUI.apiGet(api, param:param, complete:complete,failure:failure)
        }
        else if aMethod == "POST" {
            currentAPITask = resourceUI.apiPost(api, param:param, complete:complete,failure:failure)
        }

    }
    func apiPut(api:String, json:AnyObject,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) {
        var jsonError:NSError?
        var jsonData:NSData? = NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.allZeros, error: &jsonError)
        
        if let error = jsonError {
            
            failure(error)
            
            return
        }
        if let task = currentAPITask {
            if task.state == .Running {
                task.cancel()
            }
        }
        
        currentAPITask = resourceUI.apiPut(api, contentType: "application/json", postData: jsonData!, complete: complete, failure: failure)


    }
    func apiPost(api:String,json:AnyObject,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) {
        var jsonError:NSError?
        var jsonData:NSData? = NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.allZeros, error: &jsonError)
        
        if let error = jsonError {
            
            failure(error)
            
            return
        }
        if let task = currentAPITask {
            if task.state == .Running {
                task.cancel()
            }
        }
        
        currentAPITask = resourceUI.apiPost(api, contentType: "application/json", postData: jsonData!, complete: complete, failure: failure)
    }
}