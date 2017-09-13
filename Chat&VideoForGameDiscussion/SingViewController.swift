//
//  SingViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/9/11.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
class SingViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {
    @IBOutlet weak var signBtn: UIButton!
    
    
    
    private let youtubeService = YoutubeUserInfo.standard.youtubeService
    private let signIn = YoutubeUserInfo.standard.signIn
    //    Set request Authorize
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeYoutubepartner,kGTLRAuthScopeYouTube]
    
    private var userPlayLists = [[String : String]]()
    
    let defaults = YoutubeUserInfo.standard.defaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn?.uiDelegate = self
        signIn?.delegate = self
        signIn?.scopes = scopes
        signIn?.clientID = clientID
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let check = signIn?.hasAuthInKeychain() {
            print("Sing hasAuthInKeychain :\(check)")
            if check {
                guard let hasAuthorize = signIn?.currentUser?.authentication?.fetcherAuthorizer().canAuthorize else {
                    signIn?.signIn()
                    return
                }
                print("hasAuthorize:\(hasAuthorize)")
                if hasAuthorize {
                    showNextPage()
                }else{
                    signIn?.signIn()
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signAction(_ sender: UIButton) {
        signIn?.signIn()
    }
    func showNextPage(){
        
        let nexpage = storyboard?.instantiateViewController(withIdentifier: "UserplaylistsViewController") as! UserplaylistsViewController
        self.navigationController?.pushViewController(nexpage, animated: true)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        // Youtube 授權要求
        youtubeService.authorizer = signIn.currentUser?.authentication?.fetcherAuthorizer()
        youtubeService.apiKey = apiKey
        
        
        //Set the userDefault's UerHasKeyChain = true
        defaults.set(true, forKey: "UserHasKeychain")
        defaults.synchronize()
        if signIn.currentUser != nil {
            showNextPage()
        }
        
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        // Remove default's userPlaylist,let it become nil
        defaults.removeObject(forKey:"userPlaylist")
        defaults.synchronize()
        //Set the userDefault's UerHasKeyChain = false
        defaults.set(false, forKey: "UserHasKeychain")
        defaults.synchronize()
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
