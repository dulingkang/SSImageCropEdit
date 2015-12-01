//
//  ViewController.swift
//  SSImageCropper
//
//  Created by dulingkang on 27/11/15.
//  Copyright © 2015 shawn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SSCropViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer.init(target: self, action: "tapPressed:")
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func tapPressed(tap: UITapGestureRecognizer) {
        let image = UIImage(named: "girl.jpg")
        let cropVC = SSCropViewController.init(image: image!)
        cropVC.delegate = self
        
        let width = image!.size.width
        let height = image!.size.height
        let length = min(width, height)
        cropVC.imageCropRect = CGRectMake((width - length) / 2,
            (height - length) / 2,
            length,
            length)
        
        self.navigationController?.pushViewController(cropVC, animated: true)
    }
    
    //MARK: - delegate
    func cropViewControllerDidFinish(controller: SSCropViewController, croppedImage: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        
    }
    
    func cropViewControllerDidCancel(controller: SSCropViewController) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

