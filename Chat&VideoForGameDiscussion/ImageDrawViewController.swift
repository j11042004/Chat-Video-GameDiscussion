//
//  ImageDrawViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/31.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

private let socketClient = SocketFunction.standrad.socketClient
class ImageDrawViewController: UIViewController {
    
    @IBOutlet weak var canvas: Canves!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var image = UIImage()
    var allImages = [UIImage]()
    var nowImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "圖片編輯"
        canvas.historyImages.append(image)
        canvas.drawImage = image
        // push the image which will be drawed on the Graphic context
        canvas.drawLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 0), lineWidth: CGFloat(0))
        
        // Do any additional setup after loading the view.
        
        // receive notification to get allHistoryImage
        NotificationCenter.default.addObserver(self, selector: #selector(setHistoryImages(notification:)), name: NSNotification.Name("getHistoryImages"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
// MARK: -Normal Function
    func setHistoryImages(notification : Notification){
        if let objectImages = notification.object as? [UIImage] {
            allImages = objectImages
            nowImageIndex = objectImages.count - 1
        }
    }
// MARK: - UI Action
    @IBAction func prevAction(_ sender: Any) {
        // Check if nowImageIndex is > 0 or not
        if nowImageIndex > 0 {
            nowImageIndex -= 1
            canvas.drawImage = allImages[nowImageIndex]
            
            // let the Graphic context's back ground image is historyImages.last
            canvas.drawLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 0), lineWidth: CGFloat(0))
            
            
            let last = canvas.historyImages.count - 1
            canvas.historyImages.remove(at: last)

        }
        
    }
    @IBAction func nextAction(_ sender: Any) {
        
        if nowImageIndex < allImages.count - 1 {
            nowImageIndex += 1
            canvas.drawImage = allImages[nowImageIndex]
            
            // let the Graphic context's back ground image is historyImages.last
            canvas.drawLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 0), lineWidth: CGFloat(0))
            
            canvas.historyImages.append(allImages[nowImageIndex])
        }
        

    }
    
    @IBAction func sliderColorChange(_ sender: Any) {
        let red = CGFloat( redSlider.value)
        let blue =  CGFloat( blueSlider.value)
        let green =  CGFloat( greenSlider.value)
        
        canvas.color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    
    @IBAction func change(_ sender: Any) {
        guard let updateImg = canvas.drawImage else {
            return
        }
        // change to jpeg
        let imageData = UIImageJPEGRepresentation(updateImg, 0.8)
        // base64 encodeing
        guard let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) else {
            print("imageStr is nil")
            return
        }
        // add base64 jpeg to header,let the server can analyse
        let finalBase64String = "data:image/jpeg;base64,\(imageStr)"
        
        socketClient.emit("sendImage", finalBase64String)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
