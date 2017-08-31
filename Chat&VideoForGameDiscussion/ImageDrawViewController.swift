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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvas: Canves!
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.drawImage = image
        canvas.sizeToFit()
        canvas.drawLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 0)
        )
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func change(_ sender: Any) {
        imageView.image = canvas.drawImage
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
