//
//  SSResizeControl.swift
//  SSImageCropper
//
//  Created by ShawnDu on 15/11/28.
//  Copyright © 2015年 shawn. All rights reserved.
//

import UIKit

let kResizeControllWidth: CGFloat = 44
let kResizeControllHeight: CGFloat = 44

protocol SSResizeControlDelegate {
    func resizeControlViewDidBeginResizing(resizeControlView: SSResizeControl)
    func resizeControlViewDidResize(resizeControlView: SSResizeControl)
    func resizeControlViewDidEndResizing(resizeControlView: SSResizeControl)
}

class SSResizeControl: UIView {

    var delegate: SSResizeControlDelegate?
    var translation = CGPointZero
    private var startPoint = CGPointZero
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, kResizeControllWidth, kResizeControllHeight))
        self.initViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    //MARK: - event response
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            let translationInView = gestureRecognizer.translationInView(self.superview)
            self.startPoint = CGPointMake(translationInView.x, translationInView.y);
            self.delegate?.resizeControlViewDidBeginResizing(self)
        } else if (gestureRecognizer.state == UIGestureRecognizerState.Changed) {
            let translate = gestureRecognizer.translationInView(self.superview)
            self.translation = CGPointMake(self.startPoint.x + translate.x,
                self.startPoint.y + translate.y)
            self.delegate?.resizeControlViewDidResize(self)
        } else if (gestureRecognizer.state == UIGestureRecognizerState.Ended || gestureRecognizer.state == UIGestureRecognizerState.Cancelled) {
            self.delegate?.resizeControlViewDidEndResizing(self)
        }
    }
    
    //MARK: - private method
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        self.exclusiveTouch = true
        let pan = UIPanGestureRecognizer.init(target: self, action: "handlePan:")
        self.addGestureRecognizer(pan)
    }
    
}
