//
//  ImageCropExtention.swift
//  SSImageCropper
//
//  Created by dulingkang on 30/11/15.
//  Copyright © 2015 shawn. All rights reserved.
//

import UIKit

extension UIImage {
    func rotatedImageWithtransform(rotation: CGAffineTransform, rect: CGRect) -> UIImage {
        let rotatedImage = self.ssRotatedImageWithtransform(rotation)
        
        let scale = rotatedImage.scale
        let cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale))
        
        let croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, cropRect)
        let image = UIImage(CGImage: croppedImage!, scale: self.scale, orientation: rotatedImage.imageOrientation)
        
        return image
    }
    
    func ssRotatedImageWithtransform(transform: CGAffineTransform) -> UIImage {
        let size = self.size
        
        UIGraphicsBeginImageContextWithOptions(size,
            true,                     // Opaque
            self.scale);             // Use image scale
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, size.width / 2, size.height / 2)
        CGContextConcatCTM(context, transform)
        CGContextTranslateCTM(context, size.width / -2, size.height / -2)
        self.drawInRect(CGRectMake(0.0, 0.0, size.width, size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        return rotatedImage
    }
}
