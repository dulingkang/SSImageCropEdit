//
//  SSCropViewController.swift
//  SSImageCropper
//
//  Created by ShawnDu on 15/12/1.
//  Copyright © 2015年 shawn. All rights reserved.
//

import UIKit

protocol SSCropViewControllerDelegate {
    func cropViewControllerDidFinish(controller: SSCropViewController, croppedImage: UIImage, transform: CGAffineTransform, cropRect: CGRect)
    func cropViewControllerDidCancel(controller: SSCropViewController)
}

class SSCropViewController: UIViewController, UIActionSheetDelegate {

    var delegate: SSCropViewControllerDelegate?
    var image: UIImage?
    var keepingCropAspectRatio: Bool {
        get {
            return self.keepingCropAspectRatio
        }
        set {
            self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio
        }
    }
    var cropAspectRatio: CGFloat {
        get {
            return self.cropAspectRatio
        }
        set {
            self.cropView.cropAspectRatio = self.cropAspectRatio
        }
    }
    var cropRect: CGRect! {
        get {
            return self.cropRect
        }
        set {
            var cropViewCropRect = self.cropView.cropRect
            cropViewCropRect.origin.x += cropRect.origin.x
            cropViewCropRect.origin.y += cropRect.origin.y
            
            let size = CGSizeMake(min(CGRectGetMaxX(cropViewCropRect) - CGRectGetMinX(cropViewCropRect), CGRectGetWidth(cropRect)),
                min(CGRectGetMaxY(cropViewCropRect) - CGRectGetMinY(cropViewCropRect), CGRectGetHeight(cropRect)))
            cropViewCropRect.size = size
            self.cropView.cropRect = cropViewCropRect
        }
    }
    var imageCropRect: CGRect!
    var toolBarHidden = false
    var rotationEnabled: Bool {
        get {
            return self.rotationEnabled
        }
        set {
            self.cropView.rotationGestureRecognizer.enabled = self.rotationEnabled
        }
    }
    var rotationTransform: CGAffineTransform! {
        get {
            return self.cropView.rotation
        }
        set {
            
        }
    }
    var zoomedCropRect: CGRect! {
        get {
            return self.zoomedCropRect
        }
        set {
            
        }
    }
    
     var cropView: SSCropView!
    private var actionSheet: UIActionSheet!
    
    //MARK: - life cycle
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "done:")
    
        self.view.backgroundColor = UIColor.blackColor()
        self.cropView = SSCropView.init(frame: self.view.bounds)
        self.cropView.image = self.image
        self.view.addSubview(self.cropView)
        self.cropView.imageCropRect = self.imageCropRect
        self.rotationEnabled = true
        
        self.cropView.rotationGestureRecognizer.enabled = self.rotationEnabled
        
        if self.cropAspectRatio != 0 {
            self.cropView.cropAspectRatio = self.cropAspectRatio
        }
        if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
            self.cropView.cropRect = self.cropRect
        }
        if (!CGRectEqualToRect(self.imageCropRect, CGRectZero)) {
            self.cropView.imageCropRect = self.imageCropRect
        }
        
        self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio
    }
    
    //MARK: - delegate
    //MARK: actionSheet delegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var cropRect = self.cropView.cropRect
        var ratio: CGFloat = 1.0
        if (buttonIndex == 0) {
            let size = self.cropView.image!.size
            let width = size.width
            let height = size.height
            if (width < height) {
                ratio = width / height
                cropRect.size = CGSizeMake(CGRectGetHeight(cropRect) * ratio, CGRectGetHeight(cropRect))
            } else {
                ratio = height / width
                cropRect.size = CGSizeMake(CGRectGetWidth(cropRect), CGRectGetWidth(cropRect) * ratio)
            }
            self.cropView.cropRect = cropRect
        } else if (buttonIndex == 1) {
            self.cropView.cropAspectRatio = 1.0
        } else if (buttonIndex == 2) {
            self.cropView.cropAspectRatio = 2.0 / 3.0
        } else if (buttonIndex == 3) {
            self.cropView.cropAspectRatio = 3.0 / 5.0
        } else if (buttonIndex == 4) {
            ratio = 3.0 / 4.0
            let width = CGRectGetWidth(cropRect)
            cropRect.size = CGSizeMake(width, width * ratio)
            self.cropView.cropRect = cropRect
        } else if (buttonIndex == 5) {
            self.cropView.cropAspectRatio = 4.0 / 6.0
        } else if (buttonIndex == 6) {
            self.cropView.cropAspectRatio = 5.0 / 7.0
        } else if (buttonIndex == 7) {
            self.cropView.cropAspectRatio = 8.0 / 10.0
        } else if (buttonIndex == 8) {
            ratio = 9.0 / 16.0
            let width = CGRectGetWidth(cropRect)
            cropRect.size = CGSizeMake(width, width * ratio)
            self.cropView.cropRect = cropRect
        }

    }
    
    //MARK: - event response
    func cancel(sender: UIButton) {
        self.delegate?.cropViewControllerDidCancel(self)
    }
    
    func done(sender: UIButton) {
        self.delegate?.cropViewControllerDidFinish(self, croppedImage: self.cropView.croppedImage!, transform: self.cropView.rotation, cropRect: self.cropView.zoomedCropRect)
    }
    
    //MARK: - public method
    func resetCropRect() {
        self.cropView.resetCropRect()
    }
    
    func resetCropRectAnimated(animated: Bool) {
        self.cropView.resetCropRectAnimated(animated)
    }
    //MARK: - private method
}
