
//
//  SSCropView.swift
//  SSImageCropper
//
//  Created by ShawnDu on 15/11/30.
//  Copyright © 2015年 shawn. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

class SSCropView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, SSCropRectViewDelegate {

    var image: UIImage? {
        set {
            
            self.imageView?.removeFromSuperview()
            self.imageView = nil;
            
            self.zoomingView?.removeFromSuperview()
            self.zoomingView = nil;
            
            self.setNeedsLayout()
        }
        get {
            return self.image
        }
    }
    var croppedImage: UIImage? {
        set {
            
            self.imageView?.removeFromSuperview()
            self.imageView = nil;
            
            self.zoomingView?.removeFromSuperview()
            self.zoomingView = nil;
            
            self.setNeedsLayout()
        }
        get {
            return self.image?.rotatedImageWithtransform(self.rotation, rect: self.zoomedCropRect)
        }
    }
    var zoomedCropRect: CGRec
    var rotation: CGAffineTransform!
    var userHasModifiedCropArea: Bool!
    var keepingCropAspectRatio: Bool! {
        set {
            self.cropRectView.keepAspectRatio = self.keepingCropAspectRatio
        }
        get {
            return self.keepingCropAspectRatio
        }
    }
    var cropAspectRatio: CGFloat! {
        set {
            self.setCropAspectRatio(self.cropAspectRatio, center: true)
        }
        get {
            let cropRect = self.scrollView.frame
            let width = CGRectGetWidth(cropRect)
            let height = CGRectGetHeight(cropRect)
            return width / height
        }
    }
    var cropRect: CGRect! {
        set {
        }
        get {
            return self.scrollView.frame
        }
    }
    var imageCropRect: CGRect! {
        set {
            self.resetCropRect()
            
            let scrollViewFrame = self.scrollView.frame;
            let imageSize = self.image!.size;
            
            let scale = min(CGRectGetWidth(scrollViewFrame) / imageSize.width,
                CGRectGetHeight(scrollViewFrame) / imageSize.height);
            
            let x = CGRectGetMinX(imageCropRect) * scale + CGRectGetMinX(scrollViewFrame);
            let y = CGRectGetMinY(imageCropRect) * scale + CGRectGetMinY(scrollViewFrame);
            let width = CGRectGetWidth(imageCropRect) * scale;
            let height = CGRectGetHeight(imageCropRect) * scale;
            
            let rect = CGRectMake(x, y, width, height);
            let intersection = CGRectIntersection(rect, scrollViewFrame);
            
            if (!CGRectIsNull(intersection)) {
                self.cropRect = intersection;
            }
        }
        get {
            return self.imageCropRect
        }
    }
    var rotationAngle: CGFloat!
    var rotationGestureRecognizer: UIRotationGestureRecognizer!
    
    private let MarginTop: CGFloat = 37.0
    private let MarginLeft: CGFloat = 20.0
    
    private var scrollView: UIScrollView!
    private var zoomingView: UIView?
    private var imageView: UIImageView?
    
    private var cropRectView: SSCropRectView!
    private var topOverlayView: UIView!
    private var leftOverlayView: UIView!
    private var rightOverlayView: UIView!
    private var bottomOverlayView: UIView!
    
    private var insetRect: CGRect!
    private var editingRect: CGRect!
    
    private var resizing: Bool!
    private var interfaceOrientation: UIInterfaceOrientation!
    
    //MARK: - system method
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if (!self.userInteractionEnabled) {
            return nil;
        }
        
        let hitView = self.cropRectView.hitTest(self.convertPoint(point, toView: self.cropRectView), withEvent: event)
        if (hitView != nil) {
            return hitView;
        }
        let locationInImageView = self.convertPoint(point, toView: self.zoomingView)
        let zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale)
        if (CGRectContainsPoint(self.zoomingView!.frame, zoomedPoint)) {
            return self.scrollView
        }
        
        return super.hitTest(point, withEvent: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.image != nil) {
            return
        }
        
        self.interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            self.editingRect = CGRectInset(self.bounds, self.MarginLeft, self.MarginTop)
        } else {
            self.editingRect = CGRectInset(self.bounds, self.MarginLeft, self.MarginLeft)
        }
        
        if (self.imageView == nil) {
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                self.insetRect = CGRectInset(self.bounds, self.MarginLeft, self.MarginTop);
            } else {
                self.insetRect = CGRectInset(self.bounds, self.MarginLeft, self.MarginLeft);
            }
            self.setupImageView()
        }
        
        if (!self.resizing) {
            self.layoutCropRectViewWithCropRect(self.scrollView.frame)
            if (self.interfaceOrientation != interfaceOrientation) {
                self.zoomToCropRect(self.scrollView.frame)
            }
        }
    }
    
    //MARK: - public method
    func resetCropRect() {
        self.resetCropRectAnimated(false)
    }
    
    func resetCropRectAnimated(animated: Bool) {
        if (animated) {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.25)
            UIView.setAnimationBeginsFromCurrentState(true)
        }
        
        self.imageView!.transform = CGAffineTransformIdentity
        
        let contentSize = self.scrollView.contentSize
        let initialRect = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height)
        self.scrollView.zoomToRect(initialRect, animated: false)
        
        self.scrollView.bounds = self.imageView!.bounds
        self.layoutCropRectViewWithCropRect(self.scrollView.bounds)
        
        if (animated) {
            UIView.commitAnimations()
        }
    }
    
    func setRotationAngle(rotationAngle: CGFloat, snap: Bool) {
        
    }
    
    //MARK: - private method
    private func initViews() {
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor.clearColor()
        self.scrollView = UIScrollView.init(frame: self.bounds)
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.maximumZoomScale = 4
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.bouncesZoom = false
        self.scrollView.clipsToBounds = false
        self.addSubview(self.scrollView)
        
        self.rotationGestureRecognizer = UIRotationGestureRecognizer.init(target: self, action: "handleRotation:")
        self.rotationGestureRecognizer.delegate = self
        self.scrollView.addGestureRecognizer(self.rotationGestureRecognizer)
        
        self.cropRectView = SSCropRectView.init()
        self.cropRectView.delegate = self
        self.addSubview(self.cropRectView)

        self.topOverlayView = UIView.init()
        self.topOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(self.topOverlayView)
        
        self.leftOverlayView = UIView.init()
        self.leftOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(self.leftOverlayView)
        
        self.rightOverlayView = UIView.init()
        self.rightOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(self.rightOverlayView)
        
        self.bottomOverlayView = UIView.init()
        self.bottomOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(self.bottomOverlayView)
    }
    
    private func setupImageView() {
        let cropRect = AVMakeRectWithAspectRatioInsideRect(self.image!.size, self.insetRect)
        
        self.scrollView.frame = cropRect;
        self.scrollView.contentSize = cropRect.size;
        
        self.zoomingView = UIView.init(frame: self.scrollView.bounds)
        self.zoomingView!.backgroundColor = UIColor.clearColor()
        self.scrollView.addSubview(self.zoomingView!)

        self.imageView = UIImageView.init(frame: self.zoomingView!.bounds)
        self.imageView!.backgroundColor = UIColor.clearColor()
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView!.image = self.image;
        self.zoomingView!.addSubview(self.imageView!)
    }
    
    private func layoutCropRectViewWithCropRect(cropRect: CGRect) {
        self.cropRectView.frame = cropRect;
        self.layoutOverlayViewsWithCropRect(cropRect)
    }
    
    private func layoutOverlayViewsWithCropRect(cropRect: CGRect) {
        self.topOverlayView.frame = CGRectMake(0.0,
            0.0,
            CGRectGetWidth(self.bounds),
            CGRectGetMinY(cropRect))
        self.leftOverlayView.frame = CGRectMake(0.0,
            CGRectGetMinY(cropRect),
            CGRectGetMinX(cropRect),
            CGRectGetHeight(cropRect))
        self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(cropRect),
            CGRectGetMinY(cropRect),
            CGRectGetWidth(self.bounds) - CGRectGetMaxX(cropRect),
            CGRectGetHeight(cropRect))
        self.bottomOverlayView.frame = CGRectMake(0.0,
            CGRectGetMaxY(cropRect),
            CGRectGetWidth(self.bounds),
            CGRectGetHeight(self.bounds) - CGRectGetMaxY(cropRect))
    }
    
    private func zoomToCropRect(toRect: CGRect, center: Bool) {
        if (CGRectEqualToRect(self.scrollView.frame, toRect)) {
            return;
        }
        
        let width = CGRectGetWidth(toRect)
        let height = CGRectGetHeight(toRect)
        let scale = min(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height)
    
        let scaledWidth = width * scale
        let scaledHeight = height * scale
        let cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
            (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
            scaledWidth,
            scaledHeight)
        
        var zoomRect = self.convertRect(toRect, toView: self.zoomingView)
        zoomRect.size.width = CGRectGetWidth(cropRect) / (self.scrollView.zoomScale * scale);
        zoomRect.size.height = CGRectGetHeight(cropRect) / (self.scrollView.zoomScale * scale);
        
        if(center) {
            let imageViewBounds = self.imageView!.bounds;
            zoomRect.origin.y = (CGRectGetHeight(imageViewBounds) / 2) - (CGRectGetHeight(zoomRect) / 2);
            zoomRect.origin.x = (CGRectGetWidth(imageViewBounds) / 2) - (CGRectGetWidth(zoomRect) / 2);
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.scrollView.bounds = cropRect
            self.scrollView.zoomToRect(zoomRect, animated: false)
            self.layoutCropRectViewWithCropRect(cropRect)
            }) { (complete) -> Void in }
    }
    
    private func zoomToCropRect(toRect: CGRect) {
        self.zoomToCropRect(toRect, center: false)
    }
    private func setCropAspectRatio(aspectRatio: CGFloat, center: Bool) {
        var cropRect = self.scrollView.frame;
        var width = CGRectGetWidth(cropRect);
        var height = CGRectGetHeight(cropRect);
        if (aspectRatio <= 1.0) {
            width = height * aspectRatio;
            if (width > CGRectGetWidth(self.imageView!.bounds)) {
                width = CGRectGetWidth(cropRect);
                height = width / aspectRatio;
            }
        } else {
            height = width / aspectRatio;
            if (height > CGRectGetHeight(self.imageView!.bounds)) {
                height = CGRectGetHeight(cropRect);
                width = height * aspectRatio;
            }
        }
        cropRect.size = CGSizeMake(width, height);
        self.zoomToCropRect(cropRect, center: center)
    }
}
