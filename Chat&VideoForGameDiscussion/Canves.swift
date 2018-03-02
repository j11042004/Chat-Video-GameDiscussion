//
//  Canves.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/31.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class Canves: UIView {
    
    var drawImage : UIImage?
    var color = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    var historyImages = [UIImage]()
    var lineWidth = CGFloat(2.0)
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //取得螢幕上的手指
        let firstToach = touches.first
        
        //取的該手指上次的螢幕位址，勿用到preciseLocation（精確的位置）
        let previousPoint = firstToach?.previousLocation(in: self)
        //取的該手指在螢幕上的當前位置，使用 drawLine 方法
        let currentPoint = firstToach?.location(in: self)
        drawLine(from: previousPoint, to: currentPoint, lineWidth: lineWidth)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        historyImages.append(drawImage!)
        
        // push notification to let ImageDrawViewController to get history image
        
        NotificationCenter.default.post(name: NSNotification.Name("getHistoryImages"), object: historyImages)
    }
    //將兩個位置繪製成線的方法
    func drawLine(from : CGPoint?, to: CGPoint?, lineWidth: CGFloat){
        guard let from1 = from , let to1 = to
            else {
            return
        }
        
        //建立作圖空間
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.0)
        //取得做圖空間
        let ctx = UIGraphicsGetCurrentContext()
        //將上次的圖畫，畫在畫布上，若是nil就不做事
        drawImage?.draw(in: self.bounds)
        
        //移動畫筆
        ctx?.move(to: from1)
        //繪製隱形線
        ctx?.addLine(to: to1)
        //設定線條顏色
        color.setStroke()
        //設定線條寬度
        
        ctx?.setLineWidth(2.0)
        //上線稿
        ctx?.strokePath()
        
        //取出作圖空間畫面 並做成照片
        drawImage = UIGraphicsGetImageFromCurrentImageContext()
        /*要用全域變數來收不然放掉就消失*/
        
        //將圖片放到繪圖層
        // self.layer.contents=(__bridge id _Nullable)(image.CGImage);
        
        layer.contents = drawImage?.cgImage
        // 隨時更新圖片
        if let cg = drawImage?.cgImage{
            drawImage = UIImage(cgImage: cg)
        }
        
        //關閉作圖空間
        UIGraphicsEndImageContext()
    }

}
