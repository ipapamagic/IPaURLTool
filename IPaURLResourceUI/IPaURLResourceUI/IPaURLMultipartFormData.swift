//
//  IPaURLMultipartFormData.swift
//  IPaURLResourceUI
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

import Foundation

class IPaURLMultipartFormData {
    let boundary:String = NSProcessInfo.processInfo().globallyUniqueString
    lazy var data:NSMutableData = NSMutableData()
    func addStringData(string:String,name:String) {
        let dataString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(string)\r\n"
        data.appendData(dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    func addFileData(fileData:NSData,fileName:String,MIMEType:String,name:String) {
        let dataString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\nContent-Type: \(MIMEType)\r\n\r\n"
        data.appendData(dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        data.appendData(fileData)
        data.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    func endOfBodyData() {
        let dataString = "--\(boundary)--\r\n"
        data.appendData(dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        
    }
    
}