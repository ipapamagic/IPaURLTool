//
//  IPaImageURLView.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/16.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
public class IPaImageURLView : UIImageView {
    private var _imageURL:String?
    private var _highlightedImageURL:String?
    private var imageObserver:NSObjectProtocol?
    public var imageURL:String? {
        get {
            return _imageURL
        }
        set {
            setImageURL(newValue, defaultImage: nil)
        }
    }
    public var highlightedImageURL:String? {
        get {
            return _highlightedImageURL
        }
        set {
            setHighlightedImageURL(newValue, defaultImage: nil)
        }
    }
    deinit {
        if let imageObserver = imageObserver {
            NSNotificationCenter .defaultCenter().removeObserver(imageObserver)
        }
    }
    func createImageObserver () {
        if imageObserver != nil {
            return
        }
        imageObserver = NSNotificationCenter.defaultCenter().addObserverForName(IPA_NOTIFICATION_IMAGE_LOADED, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            noti in
            
            
            if let userInfo = noti.userInfo {
                let imageID = userInfo[IPA_NOTIFICATION_KEY_IMAGEID] as! String
                if let imageURL = self.imageURL {
                    if imageID == imageURL {
                        if let data = NSData(contentsOfURL: userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL] as! NSURL ) {
                            self.image = UIImage(data: data)
                        }
                    }
                }
                else if let imageURL = self.highlightedImage {
                    if imageID == imageURL {
                        if let data = NSData(contentsOfURL: userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL] as! NSURL ) {
                            self.highlightedImage = UIImage(data: data)
                        }
                    }
                }
            }
        })
    }
    public func setImageURL(imageURL:String?,defaultImage:UIImage?) {
        createImageObserver()
        _imageURL = imageURL
        var image:UIImage?
        if let imageURL = imageURL {
            image = IPaImageURLLoader.sharedInstance.loadImage((imageURL as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, imageID: imageURL)
            
        }
        self.image = (image == nil) ? defaultImage :image
    }
    public func setHighlightedImageURL(imageURL:String?,defaultImage:UIImage?) {
        createImageObserver()
        _highlightedImageURL = imageURL
        var image:UIImage?
        if let imageURL = imageURL {
            image = IPaImageURLLoader.sharedInstance.loadImage((imageURL as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, imageID: imageURL)
            
        }
        self.highlightedImage = (image == nil) ? defaultImage :image
    }
    
}