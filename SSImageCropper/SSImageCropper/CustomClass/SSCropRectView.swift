//
//  SSCropRectView.swift
//  SSImageCropper
//
//  Created by dulingkang on 27/11/15.
//  Copyright © 2015 shawn. All rights reserved.
//

import UIKit

protocol SSCropRectViewDelegate {
    func cropRectViewDidBeginEditing(cropRectView: SSCropRectView)
    func cropRectViewEditingChanged(cropRectView: SSCropRectView)
    func cropRectViewDidEndEditing(cropRectView: SSCropRectView)
}

class SSCropRectView: UIView, SSResizeControlDelegate {
    
    var showGridBig: Bool {
        set {
            self.setNeedsDisplay()
        }
        get {
            return self.showGridBig
        }
    }
    
    var showGridSmall: Bool {
        set {
            self.setNeedsDisplay()
        }
        get {
            return self.showGridSmall
        }
    }
    
    var keepAspectRatio: Bool {
        set {
            if self.keepAspectRatio {
                let width = self.bounds.size.width
                let height = self.bounds.size.height
                self.fixedAspectRatio = fmin(width / height, height / width)
            }
        }
        get {
            return self.keepAspectRatio
        }
    }
    
    var delegate: SSCropRectViewDelegate?
    
    private var topLeftCornerView: SSResizeControl!
    private var topRightCornerView: SSResizeControl!
    private var bottomLeftCornerView: SSResizeControl!
    private var bottomRightCornerView: SSResizeControl!
    private var topEdgeView: SSResizeControl!
    private var leftEdgeView: SSResizeControl!
    private var bottomEdgeView: SSResizeControl!
    private var rightEdgeView: SSResizeControl!
    private var initialRect = CGRectZero
    private var fixedAspectRatio: CGFloat = 1
    
    //MARK: - system method
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.topLeftCornerView.frame = CGRectMake(-kResizeControllWidth/2, -kResizeControllHeight/2, kResizeControllWidth, kResizeControllHeight)
        self.topRightCornerView.frame = CGRectMake(kResizeControllWidth/2, -kResizeControllHeight/2, kResizeControllWidth, kResizeControllHeight)
        self.bottomLeftCornerView.frame = CGRectMake(-kResizeControllWidth/2,kResizeControllHeight/2, kResizeControllWidth, kResizeControllHeight)
        self.bottomRightCornerView.frame = CGRectMake(kResizeControllWidth/2,kResizeControllHeight/2, kResizeControllWidth, kResizeControllHeight)
        self.topEdgeView.frame = CGRectMake(CGRectGetMaxX(self.topLeftCornerView.frame), -kResizeControllHeight/2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), kResizeControllHeight)
        self.leftEdgeView.frame = CGRectMake(-CGRectGetMaxX(self.leftEdgeView.frame)/2,CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame))
        self.bottomEdgeView.frame = CGRectMake(CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame),  CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), kResizeControllHeight)
        self.rightEdgeView.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds)/2, CGRectGetMaxY(self.topRightCornerView.frame), kResizeControllWidth, CGRectGetMaxY(self.topRightCornerView.frame))
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        
        for i in 0...2 {
            let borderPadding: CGFloat = 2.0
            let iFloat = CGFloat(i)
            
            if self.showGridSmall {
                for j in 1...2 {
                    let jFloat = CGFloat(j)
                    UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.3).set()
                    UIRectFill(CGRectMake(width / 3 / 3 * jFloat + width / 3 * iFloat, borderPadding, 1.0, height - borderPadding * 2))
                    UIRectFill(CGRectMake(borderPadding, height / 3 / 3 * jFloat + height / 3 * iFloat, width - borderPadding * 2, 1.0))
                }
            }
            
            if self.showGridBig {
                if i > 0 {
                    
                    let iFloat = CGFloat(i)
                    UIColor.whiteColor().set()
                    
                    UIRectFill(CGRectMake(width / 3 * iFloat, borderPadding, 1.0, height - borderPadding * 2))
                    UIRectFill(CGRectMake(borderPadding, height / 3 * iFloat, width - borderPadding * 2, 1.0))
                }
            }
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for subview in self.subviews {
            if subview.isKindOfClass(SSResizeControl) {
                if CGRectContainsPoint(subview.frame, point) {
                    return subview
                }
            }
        }
        return nil
    }
    
    //MARK: - SSResizeControl delegate
    func resizeControlViewDidBeginResizing(resizeControlView: SSResizeControl) {
        self.initialRect = self.frame
        self.delegate?.cropRectViewDidBeginEditing(self)
    }
    
    func resizeControlViewDidResize(resizeControlView: SSResizeControl) {
        self.frame = self.cropRectMakeWithResizeControlView(resizeControlView)
        self.delegate?.cropRectViewEditingChanged(self)
    }
    
    func resizeControlViewDidEndResizing(resizeControlView: SSResizeControl) {
        self.delegate?.cropRectViewDidEndEditing(self)
    }
    
    //MARK: - private method
    private func initViews() {
        self.addImageView()
        self.addCornerView()
    }
    
    private func addImageView() {
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = UIViewContentMode.Redraw
        self.showGridBig = true
        self.showGridSmall = false
        
        let imageView = UIImageView.init(frame: CGRectInset(self.bounds, -2.0, -2.0))
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        imageView.image = UIImage(named: "SSCropEditorBorder")
        self.addSubview(imageView)
    }
    
    private func addCornerView() {
        self.topLeftCornerView = SSResizeControl.init()
        self.topLeftCornerView.delegate = self
        self.addSubview(self.topLeftCornerView)
        
        self.topRightCornerView = SSResizeControl.init()
        self.topRightCornerView.delegate = self
        self.addSubview(self.topRightCornerView)
        
        self.bottomLeftCornerView = SSResizeControl.init()
        self.bottomLeftCornerView.delegate = self
        self.addSubview(self.bottomLeftCornerView)
        
        self.bottomRightCornerView = SSResizeControl.init()
        self.bottomRightCornerView.delegate = self
        self.addSubview(self.bottomRightCornerView)
        
        self.topEdgeView = SSResizeControl.init()
        self.topEdgeView.delegate = self
        self.addSubview(self.topEdgeView)
        
        self.leftEdgeView = SSResizeControl.init()
        self.leftEdgeView.delegate = self
        self.addSubview(self.leftEdgeView)
        
        self.bottomEdgeView = SSResizeControl.init()
        self.bottomEdgeView.delegate = self
        self.addSubview(self.bottomEdgeView)
        
        self.rightEdgeView = SSResizeControl.init()
        self.rightEdgeView.delegate = self
        self.addSubview(self.rightEdgeView)
    }
    
    private func cropRectMakeWithResizeControlView(resizeControlView: SSResizeControl) -> CGRect {
        var rect = self.frame
        if resizeControlView == self.topEdgeView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                CGRectGetWidth(self.initialRect),
                CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
            }
        }
        
        if resizeControlView == self.leftEdgeView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                CGRectGetMinY(self.initialRect),
                CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect));
            
            if (self.keepAspectRatio) {
                rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
            }
        } else if resizeControlView == self.bottomEdgeView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                CGRectGetMinY(self.initialRect),
                CGRectGetWidth(self.initialRect),
                CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
            }
        } else if resizeControlView == self.rightEdgeView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                CGRectGetMinY(self.initialRect),
                CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect));
            
            if (self.keepAspectRatio) {
                rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
            }
        } else if resizeControlView == self.topLeftCornerView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                var constrainedRect: CGRect
                if (abs(resizeControlView.translation.x) < abs(resizeControlView.translation.y)) {
                    constrainedRect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
                } else {
                    constrainedRect = self.constrainedRectWithRectBasisOfWidth(rect, aspectRatio: self.fixedAspectRatio)
                }
                constrainedRect.origin.x -= CGRectGetWidth(constrainedRect) - CGRectGetWidth(rect);
                constrainedRect.origin.y -= CGRectGetHeight(constrainedRect) - CGRectGetHeight(rect);
                rect = constrainedRect;
            }
        } else if resizeControlView == self.topRightCornerView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                if (abs(resizeControlView.translation.x) < abs(resizeControlView.translation.y)) {
                    rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
                } else {
                    rect = self.constrainedRectWithRectBasisOfWidth(rect, aspectRatio: self.fixedAspectRatio)
                }
            }
        } else if resizeControlView == self.bottomLeftCornerView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                CGRectGetMinY(self.initialRect),
                CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                var constrainedRect: CGRect
                if (abs(resizeControlView.translation.x) < abs(resizeControlView.translation.y)) {
                    constrainedRect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
                } else {
                    constrainedRect = self.constrainedRectWithRectBasisOfWidth(rect, aspectRatio: self.fixedAspectRatio)
                }
                constrainedRect.origin.x -= CGRectGetWidth(constrainedRect) - CGRectGetWidth(rect);
                rect = constrainedRect;
            }
        } else if resizeControlView == self.bottomRightCornerView {
            rect = CGRectMake(CGRectGetMinX(self.initialRect),
                CGRectGetMinY(self.initialRect),
                CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
            
            if (self.keepAspectRatio) {
                if (abs(resizeControlView.translation.x) < abs(resizeControlView.translation.y)) {
                    rect = self.constrainedRectWithRectBasisOfHeight(rect, aspectRatio: self.fixedAspectRatio)
                } else {
                    rect = self.constrainedRectWithRectBasisOfWidth(rect, aspectRatio: self.fixedAspectRatio)
                }
            }
        }
        
        let minWidth = CGRectGetWidth(self.leftEdgeView.bounds) + CGRectGetWidth(self.rightEdgeView.bounds);
        if (CGRectGetWidth(rect) < minWidth) {
            rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
            rect.size.width = minWidth;
        }
        let minHeight = CGRectGetHeight(self.topEdgeView.bounds) + CGRectGetHeight(self.bottomEdgeView.bounds);
        if (CGRectGetHeight(rect) < minHeight) {
            rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
            rect.size.height = minHeight;
        }
        
        if (self.keepAspectRatio) {
            var constrainedRect = rect
            
            if (CGRectGetWidth(rect) < minWidth) {
                constrainedRect.size.width = rect.size.height * (minWidth / rect.size.width);
            }
            
            if (CGRectGetHeight(rect) < minHeight) {
                constrainedRect.size.height = rect.size.width * (minHeight / rect.size.height);
            }
            
            rect = constrainedRect;
        }
        
        return rect;
    }
    
    private func constrainedRectWithRectBasisOfHeight(var rect: CGRect, aspectRatio: CGFloat) -> CGRect{
        var width = CGRectGetWidth(rect);
        let height = CGRectGetHeight(rect);
        if (width < height) {
            width = height * self.fixedAspectRatio;
        } else {
            width = height / self.fixedAspectRatio;
        }
        rect.size = CGSizeMake(width, height);
        
        return rect;
    }
    
    private func constrainedRectWithRectBasisOfWidth(var rect: CGRect, aspectRatio: CGFloat) -> CGRect {
        let width = CGRectGetWidth(rect);
        var height = CGRectGetHeight(rect);
        if (width < height) {
            height = width * self.fixedAspectRatio
        } else {
            height = width / self.fixedAspectRatio
        }
        rect.size = CGSizeMake(width, height)
        
        return rect;
    }
}
