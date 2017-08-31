//
//  Canves.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/31.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class Canves: UIView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var drawImage : UIImage?
    var firstPoint : CGPoint?
    var endPoint : CGPoint?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //取得螢幕上的手指
        let firstToach = touches.first
        
        //取的該手指上次的螢幕位址，勿用到preciseLocation（精確的位置）
        let previousPoint = firstToach?.previousLocation(in: self)
        //取的該手指在螢幕上的當前位置，使用 drawLine 方法
        let currentPoint = firstToach?.location(in: self)
        drawLine(from: previousPoint, to: currentPoint)
        
    }

    //將兩個位置繪製成線的方法
    func drawLine(from : CGPoint?, to: CGPoint?){
        // guard，守衛檢查傳入是否有值，兩者都有就放到自己的變數中，否則就跳出
        guard let from1 = from , let to1 = to
            else {
                return
        }
        //過了這關，就可以確保以下的from1與to1絕對有值，不是nil
        
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
        UIColor.red.setStroke()
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
        if let cg = drawImage?.cgImage{
            drawImage = UIImage(cgImage: cg)
        }
        
        //關閉作圖空間
        UIGraphicsEndImageContext()
    }

}
