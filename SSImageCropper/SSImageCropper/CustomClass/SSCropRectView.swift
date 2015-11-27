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

class SSCropRectView: UIView {
    
    var showGridBig = true
    var showGridSmall = false
    var keepAspectRatio = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func initViews() {
    }


}
