
//
//  SSCropView.swift
//  SSImageCropper
//
//  Created by ShawnDu on 15/11/30.
//  Copyright © 2015年 shawn. All rights reserved.
//

import UIKit

class SSCropView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, SSCropRectViewDelegate {

    var image: UIImage?
    var croppedImage: UIImage?
    var zoomedCropRect: CGRect!
    var rotation: CGAffineTransform!
    var userHasModifiedCropArea: Bool!
    var keepingCropAspectRatio: Bool!
    var cropAspectRatio: CGFloat!
    var cropRect: CGRect!
    var imageCropRect: CGRect!
    var rotationAngle: CGFloat!
    var rotationGestureRecognizer: UIRotationGestureRecognizer!
    
    private let MarginTop = 37.0
    private let MarginLeft = 20.0
    
    private var scrollView: UIScrollView!
    private var zoomingView: UIView!
    private var imageView: UIImageView!
    
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
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    //MARK: - public method
    func resetCropRect() {
        
    }
    
    func resetCropRectAnimated(animated: Bool) {
        
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
}
