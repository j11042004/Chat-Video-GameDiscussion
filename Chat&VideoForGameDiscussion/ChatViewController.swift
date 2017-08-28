//
//  ChatViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/24.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import Foundation
import SocketIO
import MobileCoreServices
import Photos

let EMIT_CHAT_MESSAGE = "chat message"
let CHANGE_USER_NAME = "change nickname"
let SEND_IMAGE = "sendImage"
class ChatViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource , UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITextFieldDelegate {

//    @IBOutlet weak var inputMessage: UITextField!
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputMsgField: UITextField!
    
    var MAX_FRAME_WIDTH = CGFloat()
    
    var messages = [[Any]]()
    var setUserName = ""
    var getAndReceive = ""
    var id = ""
    let resizeImage = ResizeImage()
    
    let socket = SocketIOClient(socketURL: URL(string: "https://jeffsocketchateroom.herokuapp.com")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MAX_FRAME_WIDTH = self.view.frame.size.width - CGFloat(30)
        resizeImage.setMaxWidth(maxWidth: MAX_FRAME_WIDTH)
        
        // Connect To Socket.io's Chat Room
        socket.connect(timeoutAfter: 20) {
            print("Time out of connect")
        }
        // 為了讓socket.id 加入server 中的 socket.id array
        socket.on(clientEvent: SocketClientEvent.connect) { [weak self](data, ack) in
            self!.socket.emit("addNewUser", self!.setUserName)
        }
        // 抓取id
        getUserID()

        // When some thing Add in the chat room
        addMessageHandles()
        
        // tableView add a tap event
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    // Do something when the app will release
    func applicationWillTerminate(_ application: UIApplication){
        // leave the socket.io chatroom
        socket.disconnect()
    }
    
    //  MARK:  Button Action
    // Send Message
    @IBAction func sendMsgBtn(_ sender: Any) {
        if inputMsgField.text == "" {
            return
        }
        // Send message
        guard let message = inputMsgField.text else {
            return
        }
        // Send the message to the Socjet.io ChatRoom
        socket.emit(EMIT_CHAT_MESSAGE, message)
        inputMsgField.text = ""
    }
    // Send Image
    @IBAction func sendImgBtn(_ sender: UIButton) {
        
        let alert = UIAlertController.init(title: "", message: "Choose one", preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let album = UIAlertAction.init(title: "Album", style: .default) { (action) in
            self.launchImagePickerWithSourceType(sourceType: .photoLibrary)
        }
        let camera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            self.launchImagePickerWithSourceType(sourceType: .camera)
        }
        
        alert.addAction(album)
        alert.addAction(camera)
        alert.addAction(cancel)
        // 在ipad上要運行popover才可動作
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect.init(x: sender.center.x-20, y: sender.center.y-30, width: self.view.frame.size.width, height: 50)
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func changeNameBtn(_ sender: Any) {
        changeNameAlert()
    }
    func launchImagePickerWithSourceType(sourceType: UIImagePickerControllerSourceType){
        // Determine SourceType is Invalid?
        let sourceAvailable = UIImagePickerController.isSourceTypeAvailable(sourceType)
        if sourceAvailable == false {
            NSLog("Invalid Source Type")
            return
        }
        
        let picker = UIImagePickerController()
//        picker.mediaTypes = [kUTTypeImage as String]
        picker.sourceType = sourceType
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        // 是否做裁切，在ipad 上使用會只出現左上角圖，因此不使用
//        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let type = info[UIImagePickerControllerMediaType] as? String else {
            print("info's MediaType is not String")
            return
        }
        var inputImage = UIImage()
        
        if type == kUTTypeImage as String {
            guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                print("info's OriginalImage is not IImage")
                return
            }
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                print("editedImage is not nil")
                inputImage = editedImage
                inputImage = self.resizeImage.remakeImageSize(originalImage: editedImage)
            } else{
                print("editedImage is nil")
                inputImage = originalImage
                inputImage = self.resizeImage.remakeImageSize(originalImage: originalImage)
            }
        }
        // change to jpeg
        let imageData = UIImageJPEGRepresentation(inputImage, 0.8)
        // base64 encodeing
        guard let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) else {
            print("imageStr is nil")
            return
        }
        // add base64 jpeg to header,let the server can analyse
        let finalBase64String = "data:image/jpeg;base64,\(imageStr)"
        // send image to server
        socket.emit("sendImage", finalBase64String)
        // Important close the Edite View
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //  MARK:  Soket Action
    // New message add in the socket.io chat room
    func addMessageHandles() {
        socket.on(EMIT_CHAT_MESSAGE) { [weak self](data, ack) in
            guard let userName = data[0] as? String else {
                print("\(data[0]) is not String")
                return
            }
            guard let message = data[1] as? String else {
                print("\(data[1]) is not String")
                return
            }
            // 把抓到的message 顯示到Cell上
            self!.addNewMessage(user: userName, message: message)
        }
        socket.on("sendImage") { [weak self](data, ack) in
            guard let userName = data[0] as? String else{
                print("data is nil")
                return
            }
            guard let imageString = data[1] as? String else{
                print("daimageStringta is nil")
                return
            }
            self!.addNewMessage(user: userName, message: imageString)
            print("userName:\(userName)")
            
        }
    }
    // Change User's nickName
    func changeUserName(nickName : String){
        socket.emit(CHANGE_USER_NAME, nickName)
    }
    // Get Self userID
    func getUserID() {
        socket.on("getUserId") { [weak self](data, ack) in
            guard let getID = data[0] as? String else {
                print("\(data[0]) is not String")
                return
            }
            self!.id = getID
            print("getUserId:\(getID)")
        }
    }
    //  MARK: Normal Function
    // Add message into message Array and reload tableView
    func addNewMessage(user:String, message:String) {
        // push all message to messages (include base64String)
        self.messages.append([user,message])
        
        // Reload the tableView
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        //  move to the last message cell
        DispatchQueue.main.async {
            let indexPath = IndexPath.init(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // show the input username's alert
    func changeNameAlert() {
        let userNameAlert = UIAlertController.init(title: "Please enter a user name.", message: "", preferredStyle: .alert)
        userNameAlert.addTextField(configurationHandler: nil)
        let sure = UIAlertAction.init(title: "確定", style: .default) { (_) in
            guard let addUserName = userNameAlert.textFields?.first?.text else {
                return
            }
            self.setUserName = addUserName
            print("addUserName:\(self.setUserName)")
            // change the socket's username
            self.changeUserName(nickName: addUserName)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .default) { (_) in
            self.setUserName = ""
            // change the socket's username
            self.changeUserName(nickName: self.setUserName)
        }
        userNameAlert.addAction(cancel)
        userNameAlert.addAction(sure)
        
        present(userNameAlert, animated: true, completion: nil)
    }
    
    // Convert Base64String to Dota to Image
    func base64ToImage(inputString: String) -> UIImage? {
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
        let resizeImage = self.resizeImage.remakeImageSize(originalImage: image)
        
        NSLog("image Size")
        print(image.size.height)
        print(image.size.width)
        
        getAndReceive = "get"
        return resizeImage
    }
    
    //  MARK: TableView function============
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msgCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        // if userName || stringName is nil return msgCell
        guard let userName = messages[indexPath.row][0] as? String else {
            print("userName is not String")
            return msgCell
        }
        
        guard let stringMessage = messages[indexPath.row][1] as? String else {
            print("stringMessage is not String")
            return msgCell
        }
        // if image != nil return imgCell
        if let msgImage = base64ToImage(inputString: stringMessage){
            let imgCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
            imgCell.userName.text = "\(userName): "
            imgCell.origoBase64 = stringMessage
            imgCell.msgImage.image = msgImage
            // let size fit to frame
            imgCell.userName.numberOfLines = 0
            imgCell.userName.sizeToFit()
            imgCell.msgImage.sizeToFit()
            
            return imgCell
        }
        
        // if image is nil return msgCell
        msgCell.userName.text = "\(userName): "
        msgCell.message.text = "      \(stringMessage)"
        // let size fit to frame
        msgCell.userName.numberOfLines = 0
        msgCell.userName.sizeToFit()
        msgCell.message.numberOfLines = 0
        msgCell.message.sizeToFit()
        
        return msgCell
    }
    // 自動適應寬高
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 2048
    }

    // MARK: - close the keyBoard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    // touch event function
    func handleTap(sender: UITapGestureRecognizer) {
        // must do the check ,otherwise the celle selected func will not do everyThing
        if sender.state == .ended {
            inputMsgField.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
        
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
