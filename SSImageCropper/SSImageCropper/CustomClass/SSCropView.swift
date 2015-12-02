
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

    var image: UIImage! {
        didSet {
            self.imageView?.removeFromSuperview()
            self.zoomingView?.removeFromSuperview()
            self.setNeedsLayout()
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
    var zoomedCropRect: CGRect {
        set {
            
        }
        get {
            let cropRect = self.convertRect(self.scrollView.frame, toView: self.zoomingView)
            let size = self.image!.size
            
            var ratio: CGFloat = 1.0
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image!.size, self.insetRect)) / size.width
            } else {
                ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(self.image!.size, self.insetRect)) / size.height
            }
            
            let zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                cropRect.origin.y / ratio,
                cropRect.size.width / ratio,
                cropRect.size.height / ratio)
            
            return zoomedCropRect
        }
    }
    var rotation: CGAffineTransform! {
        set {
            
        }
        get {
            return self.imageView!.transform
        }
    }
    var userHasModifiedCropArea: Bool {
        set {
            
        }
        get {
            let zoomedCropRect = CGRectIntegral(self.zoomedCropRect);
            return (!CGPointEqualToPoint(zoomedCropRect.origin, CGPointZero) ||
                !CGSizeEqualToSize(zoomedCropRect.size, self.image!.size) ||
                !CGAffineTransformEqualToTransform(self.rotation, CGAffineTransformIdentity))
        }
    }
    var keepingCropAspectRatio = true {
        didSet {
            self.cropRectView.keepAspectRatio = self.keepingCropAspectRatio
        }
    }
    var cropAspectRatio: CGFloat {
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
    var cropRect: CGRect {
        set {
        }
        get {
            return self.scrollView.frame
        }
    }
    var imageCropRect: CGRect? {
        didSet {
            self.resetCropRect()
            
            let scrollViewFrame = self.scrollView.frame
            let imageSize = self.image?.size
            let scale = min(CGRectGetWidth(scrollViewFrame) / imageSize!.width,
                CGRectGetHeight(scrollViewFrame) / imageSize!.height);
            
            let x = CGRectGetMinX(imageCropRect!) * scale + CGRectGetMinX(scrollViewFrame);
            let y = CGRectGetMinY(imageCropRect!) * scale + CGRectGetMinY(scrollViewFrame);
            let width = CGRectGetWidth(imageCropRect!) * scale;
            let height = CGRectGetHeight(imageCropRect!) * scale;
            
            let rect = CGRectMake(x, y, width, height);
            let intersection = CGRectIntersection(rect, scrollViewFrame);
            
            if (!CGRectIsNull(intersection)) {
                self.cropRect = intersection;
            }
        }
    }
    var rotationAngle: CGFloat! {
        get {
            let rotation = self.imageView!.transform
            return CGFloat(atan2f(Float(rotation.b), Float(rotation.a)))
        }
        set {
            self.imageView!.transform = CGAffineTransformMakeRotation(rotationAngle)
        }
    }
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
    
    private var resizing: Bool = false
    private var interfaceOrientation: UIInterfaceOrientation!
    
    //MARK: - system method
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.initViews(image)
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
    
    //MARK: -  delegate
    //MARK:  gesture delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK:  scrollView delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.zoomingView
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.memory = scrollView.contentOffset
    }
    
    //MARK:  cropRectView delegate
    func cropRectViewDidBeginEditing(cropRectView: SSCropRectView) {
        self.resizing = true
    }
    
    func cropRectViewEditingChanged(cropRectView: SSCropRectView) {
        let cropRect = self.cappedCropRectInImageRectWithCropRectView(cropRectView)
        self.layoutCropRectViewWithCropRect(cropRect)
        self.automaticZoomIfEdgeTouched(cropRect)
    }
    
    func cropRectViewDidEndEditing(cropRectView: SSCropRectView) {
        self.resizing = false
        self.zoomToCropRect(self.cropRectView.frame)
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
        
        self.imageView?.transform = CGAffineTransformIdentity
        
        let contentSize = self.scrollView.contentSize
        let initialRect = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height)
        self.scrollView.zoomToRect(initialRect, animated: false)
        
        if let bounds = self.imageView?.bounds {
            self.scrollView.bounds = bounds
            self.layoutCropRectViewWithCropRect(bounds)
        }
        
        if (animated) {
            UIView.commitAnimations()
        }
    }
    
    func setRotationAngle(rotationAngle: CGFloat, snap: Bool) {
        
    }
    
    //MARK: - private method
    private func initViews(image: UIImage) {
        self.image = image
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
    
    private func cappedCropRectInImageRectWithCropRectView(cropRectView: SSCropRectView) -> CGRect {
        
        var cropRect = cropRectView.frame
        
        let rect = self.convertRect(cropRect, toView: self.scrollView)
        if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView!.frame)) {
            cropRect.origin.x = CGRectGetMinX(self.scrollView.convertRect(self.zoomingView!.frame, toView: self))
            let cappedWidth = CGRectGetMaxX(rect)
            cropRect.size = CGSizeMake(cappedWidth,
                !self.keepingCropAspectRatio ? cropRect.size.height : cropRect.size.height * (cappedWidth/cropRect.size.width))
        }
        if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView!.frame)) {
            cropRect.origin.y = CGRectGetMinY(self.scrollView.convertRect(self.zoomingView!.frame, toView: self))
            let cappedHeight =  CGRectGetMaxY(rect);
            cropRect.size = CGSizeMake(!self.keepingCropAspectRatio ? cropRect.size.width : cropRect.size.width * (cappedHeight / cropRect.size.height),
                cappedHeight)
        }
        if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView!.frame)) {
            let cappedWidth = CGRectGetMaxX(self.scrollView.convertRect(self.zoomingView!.frame, toView: self)) - CGRectGetMinX(cropRect)
            cropRect.size = CGSizeMake(cappedWidth,
                !self.keepingCropAspectRatio ? cropRect.size.height : cropRect.size.height * (cappedWidth/cropRect.size.width))
        }
        if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView!.frame)) {
            let cappedHeight =  CGRectGetMaxY(self.scrollView.convertRect(self.zoomingView!.frame, toView: self)) - CGRectGetMinY(cropRect);
            cropRect.size = CGSizeMake(!self.keepingCropAspectRatio ? cropRect.size.width : cropRect.size.width * (cappedHeight / cropRect.size.height),
                cappedHeight)
        }
        
        return cropRect
    }
    
    private func automaticZoomIfEdgeTouched(cropRect: CGRect) {
        if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0 ||
            CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0 ||
            CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0 ||
            CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0) {
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.zoomToCropRect(self.cropRectView.frame)
                    }, completion: { (complate) -> Void in
                })
        }
    }
    
    private func handleRotation(gestureRecognizer: UIRotationGestureRecognizer) {
        let rotation = gestureRecognizer.rotation
        
        let transform = CGAffineTransformRotate(self.imageView!.transform, rotation)
        self.imageView!.transform = transform;
        gestureRecognizer.rotation = 0.0
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            self.cropRectView.showGridSmall = true
        } else if (gestureRecognizer.state == UIGestureRecognizerState.Ended ||
            gestureRecognizer.state == UIGestureRecognizerState.Cancelled ||
            gestureRecognizer.state == UIGestureRecognizerState.Failed) {
                self.cropRectView.showGridSmall = false
        }
    }
}
