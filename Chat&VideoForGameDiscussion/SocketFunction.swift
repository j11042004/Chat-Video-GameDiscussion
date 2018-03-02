//
//  SocketFunction.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/28.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import SocketIO

class SocketFunction: NSObject {
    static let standrad = SocketFunction()
    public var manager : SocketManager!
    public var socketClient : SocketIOClient!
    override init() {
        super.init()
        if let url = URL(string: "https://chatandvideosocketchat.herokuapp.com/"){
            NSLog("socket Url is not nil")
            self.manager = SocketManager(socketURL:url)
            self.socketClient = self.manager.defaultSocket
        }
        
    }
}

