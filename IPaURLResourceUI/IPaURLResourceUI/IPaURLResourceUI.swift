//
//  IPaURLResourceUI.swift
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2015/6/12.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

import Foundation
public typealias IPaURLResourceUISuccessHandler = ((NSURLResponse,AnyObject?) -> ())!
public typealias IPaURLResourceUIFailHandler = ((NSError) -> ())!
public class IPaURLResourceUI : NSObject,NSURLSessionDelegate {
    var baseURL:String! = ""
    public var removeNSNull:Bool = true
    lazy var sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var urlSession:NSURLSession = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    func urlStringForAPI(api:String) -> String {
        return self.baseURL + api
    }
    func urlStringForGETAPI(api:String!, param:[String:AnyObject]?) -> String! {
        var apiURL = self.baseURL + api
  
        if let params = param {
            apiURL = apiURL + "?"
            var count = 0
            
            for key in params.keys {
                apiURL = apiURL + ((count > 0) ? "&":"") + "\(key)=\(params[key]!)"
                count++
            }
        }

        return (apiURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))!

    
    
    }
    func apiWithRequest(request:NSURLRequest,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask {
        
        let task = urlSession.dataTaskWithRequest(request, completionHandler: { (responseData,response,error) in
            if error != nil {
                failure(error)
                return
            }
            var jsonError:NSError?
            var jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.allZeros, error: &jsonError)

            if jsonError != nil {

                failure(error)
                
                return
            }
            if self.removeNSNull {
                jsonData = self.removeNSNullDataFromObject(jsonData!)
            }
            complete(response,jsonData)
        })
        
        task.resume()
        
        return task
    }
    
    public func apiGet(api:String ,param:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask

    {
        let apiURL = urlStringForGETAPI(api, param: param)
        let request = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.URL = NSURL(string: apiURL)
        
        return apiWithRequest(request,complete:complete,failure:failure)
    }
    func apiPost(api:String , param:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask
    {
        return apiPerform(api,method:"POST",paramInBody:param,complete:complete,failure:failure)
    }

    
    func apiPut(api:String, param:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask {
        
        return apiPerform(api ,method:"PUT", paramInBody:param,complete:complete,failure:failure)
    }
    
    func apiPerform(api:String,method:String,paramInHeader:[String:String]?,paramInBody:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask
    {
        let apiURL = urlStringForAPI(api)
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: apiURL)
        request.HTTPMethod = method
        if let param = paramInHeader {
            for key in param.keys {
                request.setValue(param[key]!,forHTTPHeaderField: key)
            }
        }
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        if let param = paramInBody {
            var count = 0
            var postString = ""
            var customAllowedSet =  NSCharacterSet(charactersInString:"!*'();:@&=+$,/?%#[]").invertedSet
            for key in param.keys {
                var value = "\(param[key]!)"
                value = (value.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet))!

                postString = postString + ((count > 0) ? "&" : "") + "\(key)=\(value)"
                count++
        
            }
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        }
    
    
        return apiWithRequest(request,complete:complete,failure:failure)

    }
    func apiPerform(api:String,method:String,paramInBody:[String:AnyObject]?,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionDataTask {
        return apiPerform(api, method: method, paramInHeader: nil, paramInBody: paramInBody, complete: complete, failure: failure)

    }
    func apiUpload(api:String,method:String,headerParam:[String:String],data:NSData,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionUploadTask {
        let apiURL = urlStringForAPI(api)
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: apiURL)
        request.HTTPMethod = method
        
        for key in headerParam.keys {
            request.setValue(headerParam[key]!, forHTTPHeaderField: key)

        }
    //        [request setValue:contentType forHTTPHeaderField:@"content-type"]
    //    NSString *dataLength = [NSString stringWithFormat:@"%ld", (unsigned long)[data length]]
    //    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"]
    //    [request setHTTPBody:data]
        let task = urlSession.uploadTaskWithRequest(request, fromData: data, completionHandler: {
            (responseData,response,error) -> Void in
            if error != nil {
                failure(error)
                return
            }
            var jsonError:NSError?
      
            
#if DEBUG
            let retString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
            print("IPaURLResourceUI return string :\(retString)")
#endif
            var jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.allZeros, error: &jsonError)

            if (jsonError != nil) {
                failure(error)
                return
            }
            if self.removeNSNull {
                jsonData = self.removeNSNullDataFromObject(jsonData!)
            }
            complete(response,jsonData)

            
        })

        task.resume()
        return task
    }
    func apiUpload(api:String,method:String,multiPartFormData:IPaURLMultipartFormData,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionUploadTask {
        let contentType = "multipart/form-data boundary=\(multiPartFormData.boundary)"
        multiPartFormData.endOfBodyData()
        let data = multiPartFormData.data
        return apiUpload(api, method: method, headerParam: ["content-type":contentType], data: data, complete: complete, failure: failure)
    }
    func apiPut(api:String,contentType:String,postData:NSData,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionUploadTask {
        return apiUpload(api, method: "PUT", headerParam: ["content-type":contentType], data: postData, complete: complete, failure: failure)
    }
    func apiPost(api:String,contentType:String,postData:NSData,complete:IPaURLResourceUISuccessHandler,failure:IPaURLResourceUIFailHandler) -> NSURLSessionUploadTask {
        return apiUpload(api, method: "POST", headerParam: ["content-type":contentType], data: postData, complete: complete, failure: failure)
    }
  
    
    

// MARK:NSURLSessionDelegate
    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        println("\(error)")
    }
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
    }
    
// MARK: helper method
    func removeNSNullDataFromObject(object:AnyObject) -> AnyObject
    {
        if let dictObject = object as? [String:AnyObject] {
            return removeNSNullDataFromDictionary(dictObject)
        }
        else if let arrayValue = object as? [AnyObject] {
            return removeNSNullDataFromArray(arrayValue)
        }
        return object;
    }
    func removeNSNullDataFromDictionary(dictionary:[String:AnyObject!]) -> [String:AnyObject!]
    {
        var mDict = [String:AnyObject]()
        
        for key in dictionary.keys {
            var value = dictionary[key]
            if let value = value as? NSNull {
                continue;
            }
            else if let dictValue = value as? [String:AnyObject] {
                value = removeNSNullDataFromDictionary(dictValue)
            }
            else if let arrayValue = value as? [AnyObject] {
                value = removeNSNullDataFromArray(arrayValue)
            }
            mDict[key] = value;
        }
        return mDict;
    }
    func removeNSNullDataFromArray(array:[AnyObject]) -> [AnyObject]
    {
        var mArray = [AnyObject]()
        for value in array {
            var newValue:AnyObject = value;
            if let value = value as? NSNull {
                continue;
            }
            else if let dictValue = value as? [String:AnyObject] {
                newValue = removeNSNullDataFromDictionary(dictValue)
            }
            else if let arrayValue = value as? [AnyObject] {
                newValue = removeNSNullDataFromArray(arrayValue)
            }
            mArray.append(newValue)

        }
        return mArray;
    }
    
}


