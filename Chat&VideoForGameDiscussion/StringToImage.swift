//
//  StringToImage.swift
//  YoutubeTest
//
//  Created by Uran on 2017/8/22.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class StringToImage: NSObject {
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
}
