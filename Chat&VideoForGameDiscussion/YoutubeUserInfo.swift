//
//  YoutubeUserInfo.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/25.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn

class YoutubeUserInfo: NSObject,GIDSignInDelegate
{
    static let standard = YoutubeUserInfo()
    
    var defaults = UserDefaults.standard
    let youtubeService = GTLRYouTubeService()
    let signIn = GIDSignIn.sharedInstance()
    
    //    Set request Authorize
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeYoutubepartner,kGTLRAuthScopeYouTube]

    
    
    func googleSignIn() {
        signIn?.delegate = self
        signIn?.clientID = clientID
        // 要做不然無法跳到權限畫面
        signIn?.scopes = scopes
        signIn?.signIn()
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing in Fail : \(error)")
            return
        }
        // Youtube 授權要求
        youtubeService.authorizer = user.authentication?.fetcherAuthorizer()
        
    }

    
    // Request to delete a item in playlist
    func requestToDeletePlaylistItem(deleteItemID: String){
        let playlistItemDeleteQuery = GTLRYouTubeQuery_PlaylistItemsDelete.query(withIdentifier: deleteItemID)
        youtubeService.executeQuery(playlistItemDeleteQuery) { (ticket, response, error) in
            if let error = error {
                print("Delete Error :\(error)")
                return
            }
        }
    }

    
}
