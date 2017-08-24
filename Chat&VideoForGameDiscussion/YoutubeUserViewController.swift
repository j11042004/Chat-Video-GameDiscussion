//
//  YoutubeUserViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/24.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleSignIn
import GTMOAuth2
import GoogleAPIClientForREST


class YoutubeUserViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var playlistTableview: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var waitingCircle: UIActivityIndicatorView!
    @IBOutlet weak var coverdView: UIView!
    
    private let signIn = GIDSignIn.sharedInstance()
    //    Set request Authorize
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeYoutubepartner,kGTLRAuthScopeYouTube]
    private var signInButton = GIDSignInButton()
    
    private let youtubeService = GTLRYouTubeService()
    private var userPlayLists = [[String : String]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare Google Signin
        signIn?.delegate = self
        signIn?.uiDelegate = self
        signIn?.clientID = clientID
        // 要做不然無法跳到權限畫面
        signIn?.scopes = scopes
        
        // Add a GIDSignInButton
        signInButton = GIDSignInButton()
        signInButton.center = logoutBtn.center
        view.addSubview(signInButton)
        
        
        // Check User had Login or not to get AuthInKeychain
        if let check = signIn?.hasAuthInKeychain() {
            if check {
                signIn?.signIn()
                signInButton.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Button action
    @IBAction func logoutBtnAction(_ sender: Any) {
        signIn?.signOut()
        signIn?.disconnect()
        signInButton.isHidden = false
    }
    
    
    //MARK: Youtube request function
    func getUserPlayLists(){
        print("run")
        // play list request query
        let playListsQuery = GTLRYouTubeQuery_PlaylistsList.query(withPart: "contentDetails, snippet")
        // Set to get user's playLists
        playListsQuery.mine = true
        playListsQuery.maxResults = 50
        // youtubeService request
        youtubeService.executeQuery(playListsQuery, delegate: self, didFinish: #selector(analysiPlaylistsList(ticket:playlistsListResponse:error:)))
    }
    
    func analysiPlaylistsList(ticket: GTLRServiceTicket , playlistsListResponse response :GTLRYouTube_PlaylistListResponse ,error: Error?){
        if let error = error {
            print("PlaylistsList Error :\(error)")
            return
        }
        guard let items = response.items else{
            print("items is nil")
            return
        }
        // Get all Playist's Information
        for item in items {
            var playlist = [String : String]()
            if let playlistID = item.identifier {
                playlist["playlistID"] = playlistID
            }
            if let thumbnailURL = item.snippet?.thumbnails?.defaultProperty?.url {
                playlist["thumbnailURL"] = thumbnailURL
            }
            if let playlistTitle = item.snippet?.title {
                playlist["playlistTitle"] = playlistTitle
            }
            if let playlistDescription = item.snippet?.descriptionProperty  {
                playlist["playlistDescription"] = playlistDescription
            }
            self.userPlayLists.append(playlist)
        }
        // Reload TableView
        DispatchQueue.main.async {
//MARK: = Fixed add a object to get the playlist
            self.playlistTableview.reloadData()
        }
        
        DispatchQueue.main.async {
            self.coverdView.isHidden = true
            self.waitingCircle.isHidden = true
        }
    }

    
    
    
    
    
    
// MARK: - GoogleSignin's GIDSignInDatasource Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing in Fail : \(error)")
            signInButton.isHidden = false
            return
        }
        NSLog("Login Success")
        // Youtube 授權要求
        youtubeService.authorizer = user.authentication?.fetcherAuthorizer()
        // Must to get the user's authorizer before to request the user's playlist
        getUserPlayLists()
        signInButton.isHidden = true

        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing out Fail : \(error)")
            signInButton.isHidden = true
            return
        }
        
        NSLog("User Disconnect")

        signInButton.isHidden = false
    }
    
// MARK: - Tableview datasource function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPlayLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelfPlistTableViewCell
        
        let plistInfo = userPlayLists[indexPath.row]
        
        guard let title = plistInfo["playlistTitle"] else {
            return cell
        }
        cell.titleLabel.text = title
        
        if plistInfo["playlistDescription"] == "" || plistInfo["playlistDescription"] == nil{
            cell.descriptionTextView.isHidden = true
        }else{
            cell.descriptionTextView.text = plistInfo["playlistDescription"]
        }
        let thumbnailImg = StringToImage().stringToImage(inputString: plistInfo["thumbnailURL"])
        cell.thumbnailImgView.image = thumbnailImg
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        /*
        guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "PlistVideosViewController") as? PlistVideosViewController  else {
            print("nextPage is nil")
            return
        }
        */
//        nextPage.userPlayList = userPlayLists[indexPath.row]
        
//        navigationController?.pushViewController(nextPage, animated:true)
        
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