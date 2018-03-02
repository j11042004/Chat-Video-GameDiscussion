//
//  ToImage.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/31.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class ToImage: NSObject {
    func stringToImage(inputString:String?) -> UIImage {
        guard let inputString  = inputString else {
            return UIImage(named: "noImage.png")!
        }
        guard let inputURL  = URL(string:inputString) else {
            return UIImage(named: "noImage.png")!
        }
        guard let inputData = try? Data(contentsOf: inputURL)  else {
            return UIImage(named: "noImage.png")!
        }
        guard let inputImg = UIImage(data: inputData)  else {
            return UIImage(named: "noImage.png")!
        }
        return inputImg
    }
    
    func urlToImage(inputUrl:URL) -> UIImage {
        
        
        guard let inputData = try? Data(contentsOf: inputUrl)  else {
            return UIImage(named: "noImage.png")!
        }
        guard let inputImg = UIImage(data: inputData)  else {
            return UIImage(named: "noImage.png")!
        }
        return inputImg
    }
    
    // Convert Base64String to Data to Image
    func base64ToImage(inputString: String) -> UIImage? {
        // 將inputString 做分解，因為有些傳來的會說明他們是base64的jpg/png ... 檔
        let base64StringArray = inputString.components(separatedBy: "base64,")
        if base64StringArray.count != 2 {
            return nil
        }
        
        let base64String = base64StringArray[1]
        // base64String convert to Data
        guard let imageData = Data.init(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else{
            print("imageData is nil")
            return nil
        }
        guard let image = UIImage(data:imageData) else{
            print("image is nil")
            return nil
        }
        let resizeImage = ResizeImage().remakeImageSize(originalImage: image)
        
        NSLog("image Size")
        print(resizeImage.size.height)
        print(resizeImage.size.width)
        
        return resizeImage
    }


}
