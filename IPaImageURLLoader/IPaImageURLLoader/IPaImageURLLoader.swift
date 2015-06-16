//
//  IPaImageURLLoader.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
let IPA_NOTIFICATION_IMAGE_LOADED = "IPA_NOTIFICATION_IMAGE_LOADED"
let IPA_NOTIFICATION_KEY_IMAGEFILEURL = "IPA_NOTIFICATION_KEY_IMAGEFILEURL"
let IPA_NOTIFICATION_KEY_IMAGEID = "IPA_NOTIFICATION_KEY_IMAGEID"
let IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER = 3


protocol IPaImageURLLoaderDelegate : AnyObject {
    func onIPaImageURLLoader(loader:IPaImageURLLoader,imageID:String,imageFileURL:NSURL)
    func onIPaImageURLLoaderFail(loader:IPaImageURLLoader, imageID:String)
    func getCacheFilePath(loader:IPaImageURLLoader,imageID:String) -> String
    func modifyImage(loader:IPaImageURLLoader,originalImageFileURL:NSURL?,imageID:String) -> UIImage?
}
class IPaImageURLLoader :IPaImageURLLoaderDelegate {
    static let sharedInstance = IPaImageURLLoader()
    let operationQueue = NSOperationQueue()
    weak var delegate:IPaImageURLLoaderDelegate?
    lazy var session:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var cachePath:String
    var maxConcurrent:Int {
        get {
            return operationQueue.maxConcurrentOperationCount
        }
        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }
    init() {
        operationQueue.maxConcurrentOperationCount = IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER
        cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String;
        cachePath = cachePath.stringByAppendingPathComponent("cacheImage")
        let fileMgr = NSFileManager.defaultManager()
        if !fileMgr.fileExistsAtPath(cachePath) {
            var error:NSError?
            fileMgr.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil, error: &error)
            if error != nil {
                println(error)
            }
        }
        delegate = self
    }

    func cacheWithImageID(imageID:String) -> UIImage? {
        if let path = delegate?.getCacheFilePath(self, imageID: imageID)
        {
            return UIImage(contentsOfFile: path)
        }
        return nil;

    }
    func loadImage(url:String,imageID:String) -> UIImage? {
        
        if let image = cacheWithImageID(imageID) {
            return image;
        }

        
        
        let currentQueue = operationQueue.operations
        var index = NSNotFound
        var count:Int = 0
        for operation in currentQueue {
            let imgOperation = operation as! IPaImageURLOperation
            if imgOperation.imageID == imageID {
                index = count
                break
            }
            count++
        }
        if index != NSNotFound {
            let operation = currentQueue[index] as! IPaImageURLOperation
            if !operation.cancelled {
                if operation.request.URL?.absoluteString != url {
                    operation.cancel()
                }

            }
            
        }
        if let URL = NSURL(string:url) {
            let request = NSURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
            let operation = IPaImageURLOperation(request: request, imageID: imageID, session: session)
            operation.completionBlock = {
                //        UIImage *image = weakOperation.loadedImage;
                var imageURL = operation.loadedImageFileURL
                
                if let modifyImage = self.delegate?.modifyImage(self, originalImageFileURL: imageURL, imageID: imageID) {
                    
                    
                    var path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String;
                    path = path.stringByAppendingPathComponent("IPaImageCache.imageCache")
                    let data = UIImagePNGRepresentation(modifyImage);
                    data.writeToFile(path, atomically: true)
                    
                    
                    imageURL = NSURL(fileURLWithPath: path);
                }
            
                
                if let imageURL = imageURL {
                    if let path = self.delegate?.getCacheFilePath(self, imageID: imageID) {
                        
                        let directory = path.stringByDeletingLastPathComponent
                        let fileManager = NSFileManager.defaultManager()
                        var error:NSError?
                        if !fileManager.fileExistsAtPath(directory) {
                            

                            fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: &error)

                            if error != nil {

                                return;
                            }
                        }
                        fileManager.copyItemAtURL(imageURL, toURL:(NSURL.fileURLWithPath(path))!, error: &error)
                        
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(IPA_NOTIFICATION_IMAGE_LOADED, object: nil, userInfo: [IPA_NOTIFICATION_KEY_IMAGEFILEURL:imageURL,IPA_NOTIFICATION_KEY_IMAGEID:imageID])
                        
                        self.delegate?.onIPaImageURLLoader(self, imageID: imageID, imageFileURL: imageURL)
                        
                        
                    });
                }
                
                
                
            }
            operationQueue.addOperation(operation)
        }
        return nil
    }
    func cancelLoaderWithImageID(imageID:String) {
        
        let currentQueue = operationQueue.operations
        var index = NSNotFound
        var count:Int = 0
        for operation in currentQueue {
            let imgOperation = operation as! IPaImageURLOperation
            if imgOperation.imageID == imageID {
                index = count
                break
            }
            count++
        }
        if index != NSNotFound {
            let operation = currentQueue[index] as! IPaImageURLOperation
            
            operation.cancel()
            
        }
    
    }
    func cancelAllOperation (){
        operationQueue.cancelAllOperations()
    }


    
// MARK:IPaImageURLLoaderDelegate

    func onIPaImageURLLoader(loader:IPaImageURLLoader,imageID:String,imageFileURL:NSURL)
    {
        
    }
    func onIPaImageURLLoaderFail(loader:IPaImageURLLoader, imageID:String)
    {
        
    }
    func getCacheFilePath(loader:IPaImageURLLoader,imageID:String) -> String
    {
        let imageIDString = imageID as NSString
        let filePath = cachePath.stringByAppendingPathComponent("\(imageIDString.MD5String())")
        return filePath;
    }
    func modifyImage(loader:IPaImageURLLoader,originalImageFileURL:NSURL?,imageID:String) -> UIImage?
    {
        return nil
    }
}