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
    let socketClient = SocketIOClient(socketURL: URL(string: "https://jeffsocketchateroom.herokuapp.com")!)
    
    
}
