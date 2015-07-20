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
    public var highlightedImageURL:String? {
        get {
            return _highlightedImageURL
        }
        set {
            setHighlightImageURL(newValue,defaultImage:nil)
        }
    }
    public var imageURL:String? {
        get {
            return _imageURL
        }
        set {
            setImageURL(newValue, defaultImage: nil)
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
            if let imageURL = self.imageURL {
                if let userInfo = noti.userInfo {
                    let imageID = userInfo[IPA_NOTIFICATION_KEY_IMAGEID] as! String
                    if imageID == imageURL {
                        if let data = NSData(contentsOfURL: userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL] as! NSURL ) {
                            
                            self.image = UIImage(data: data,scale: UIScreen.mainScreen().scale)
                        }
                    }
                }
            }
            if let highlightedImageURL = self.highlightedImageURL {
                if let userInfo = noti.userInfo {
                    let imageID = userInfo[IPA_NOTIFICATION_KEY_IMAGEID] as! String
                    if imageID == highlightedImageURL {
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
            if let data = IPaImageURLLoader.sharedInstance.loadImageData(imageURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, imageID: imageURL) {
            
                image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
            }
            
        }
        self.image = (image == nil) ? defaultImage :image
    }
   public func setHighlightImageURL(highlightedImageURL:String?,defaultImage:UIImage?) {
        createImageObserver()
        _highlightedImageURL = highlightedImageURL
        var image:UIImage?
        if let highlightedImageURL = highlightedImageURL {
           
            if let data = IPaImageURLLoader.sharedInstance.loadImageData(highlightedImageURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, imageID: highlightedImageURL) {
                
                image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
            }
        }
        self.highlightedImage = (image == nil) ? defaultImage :image
    }
   
}