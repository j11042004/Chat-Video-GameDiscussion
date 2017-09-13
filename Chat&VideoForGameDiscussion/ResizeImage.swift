//
//  ResizeImage.swift
//  SockitIOTest
//
//  Created by Uran on 2017/8/14.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class ResizeImage: NSObject {
    private var maxWidth = CGFloat()
    
    func setMaxWidth(maxWidth:CGFloat){
        self.maxWidth = maxWidth
        
        print("maxWidth:\(self.maxWidth)")
    }
    
    
    
    func remakeImageSize(originalImage: UIImage) -> UIImage{
        // if originalImage's
        if originalImage.size.width <= maxWidth && originalImage.size.height <= maxWidth{
            return originalImage
        }
        var scale = CGFloat()
        var newHieght = CGFloat()
        var newWidth = CGFloat()
        // Get newSize's height,newSize's width
        if originalImage.size.width > originalImage.size.height {
            scale = maxWidth/originalImage.size.width
            newHieght = originalImage.size.height * scale
            newWidth = originalImage.size.width * scale
        }else {
            scale = maxWidth/originalImage.size.height
            newHieght = originalImage.size.height * scale
            newWidth = originalImage.size.width * scale
        }
        
        newHieght = originalImage.size.height * scale
        // open a canvas space
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHieght))
        // draw the image to resize canvas
        originalImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHieght))
        guard let resizeImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("the resizeImage on the canvas is nil")
            return originalImage
        }
        // close the canvas space
        UIGraphicsEndImageContext()
        return resizeImage
    }

}
