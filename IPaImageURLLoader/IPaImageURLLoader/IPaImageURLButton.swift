//
//  IPaImageURLButton.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/16.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
public class IPaImageURLButton : UIButton {
    private var _imageURL:String?
    private var _backgroundImageURL:String?
    private var imageObserver:NSObjectProtocol?
    public var imageURL:String? {
        get {
            return _imageURL
        }
        set {
            setImageURL(newValue, defaultImage: nil)
        }
    }
    public var backgroundImageURL:String? {
        get {
            return _backgroundImageURL
        }
        set {
            setBackgroundImageURL(newValue, defaultImage: nil)
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
                            let image = UIImage(data: data)
                            self.setImage(image, forState: .Normal)
                            
                        }
                    }
                }
                if let backgroundImageURL = self.backgroundImageURL {
                    if imageID == backgroundImageURL {
                        if let data = NSData(contentsOfURL: userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL] as! NSURL ) {
                            let image = UIImage(data: data)
                            self.setBackgroundImage(image, forState: .Normal)
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
        
        setImage((image == nil) ? defaultImage :image, forState: .Normal)
    }
    public func setBackgroundImageURL(imageURL:String?,defaultImage:UIImage?) {
        createImageObserver()
        _backgroundImageURL = imageURL
        var image:UIImage?
        if let imageURL = imageURL {
            image = IPaImageURLLoader.sharedInstance.loadImage((imageURL as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, imageID: imageURL)
            
        }
        
        setBackgroundImage((image == nil) ? defaultImage :image, forState: .Normal)
    }
}

