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
    
    @IBOutlet weak var userThumbnailImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    private let youtubeService = YoutubeUserInfo.standard.youtubeService
    private let signIn = YoutubeUserInfo.standard.signIn
    //    Set request Authorize
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeYoutubepartner,kGTLRAuthScopeYouTube]
    private var signInButton = GIDSignInButton()
    
    private var userPlayLists = [[String : String]]()
    
    let defaults = YoutubeUserInfo.standard.defaults
    
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
        signInButton.center = CGPoint.init(x: self.view.center.x, y: userThumbnailImageView.center.y)
        view.addSubview(signInButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        // Check User had Login or not to get AuthInKeychain
        if let check = signIn?.hasAuthInKeychain() {
            if check {
                hiddAction(trueOrFalse: true)
                guard let hasAuth = youtubeService.authorizer?.canAuthorize else {
                    signIn?.signIn()
                    return
                }
                // if the service has the authorize to download user's playlist info
                if hasAuth {
                    getUserPlayLists()
                }
            }else{
                hiddAction(trueOrFalse: false)
            }
        }

    }
// MARK: - Button action
    @IBAction func logoutBtnAction(_ sender: Any) {
        signIn?.signOut()
        signIn?.disconnect()
        hiddAction(trueOrFalse: false)
    }
    
    
    //MARK: Youtube request function
    func getUserPlayLists(){
        // play list request query
        let playListsQuery = GTLRYouTubeQuery_PlaylistsList.query(withPart: "contentDetails, snippet")
        // Set to get user's playLists
        playListsQuery.mine = true
        playListsQuery.maxResults = 50
        // youtubeService request
        youtubeService.executeQuery(playListsQuery, delegate: self, didFinish: #selector(getPlaylistsInfo(ticket:playlistsListResponse:error:)))
    }
    
    func getPlaylistsInfo(ticket: GTLRServiceTicket , playlistsListResponse response :GTLRYouTube_PlaylistListResponse ,error: Error?){
        if let error = error {
            print("PlaylistsList Error :\(error)")
            return
        }
        guard let items = response.items else{
            print("items is nil")
            return
        }
        // Get all Playist's Information
        self.userPlayLists.removeAll()
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
            // Reset the playlist to userDefault
            self.defaults.removeObject(forKey:"userPlaylist")
            self.defaults.synchronize()
            
            self.defaults.set(self.userPlayLists, forKey: "userPlaylist")
            self.defaults.synchronize()
            
            self.playlistTableview.reloadData()
            
        }
        
        DispatchQueue.main.async {
            self.coverdView.isHidden = true
            self.waitingCircle.isHidden = true
        }
    }

// MARK: - Normal Function
    func setUserInfo(name: String, imageURL : URL){
        userNameLabel.text = name
        let image = ToImage().urlToImage(inputUrl: imageURL)
        userThumbnailImageView.image = image
    }
    func hiddAction(trueOrFalse : Bool) {
        signInButton.isHidden = trueOrFalse
        logoutBtn.isHidden = !trueOrFalse
        waitingCircle.isHidden = !trueOrFalse
        coverdView.isHidden = !trueOrFalse
        userThumbnailImageView.isHidden = !trueOrFalse
        userNameLabel.isHidden = !trueOrFalse
    }
    
    
    
    
// MARK: - GoogleSignin's GIDSignInDatasource Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing in Fail : \(error)")
            hiddAction(trueOrFalse: false)
            return
        }
        NSLog("Login Success")
        // Youtube 授權要求
        youtubeService.authorizer = user.authentication?.fetcherAuthorizer()
        
        YoutubeUserInfo.standard.defaults.set(true, forKey: "UserHasKeychain")
        YoutubeUserInfo.standard.defaults.synchronize()
        
        
        // Must to get the user's authorizer before to request the user's playlist
        getUserPlayLists()
        setUserInfo(name: user.profile.name, imageURL: user.profile.imageURL(withDimension: 0))
        hiddAction(trueOrFalse: true)
    }
    // Disconnect Function
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing out Fail : \(error)")
            hiddAction(trueOrFalse: true)
            return
        }
        
        // remove default's userPlaylist,let it become nil
        defaults.removeObject(forKey:"userPlaylist")
        defaults.synchronize()
        
        
        NSLog("User Disconnect")
        userPlayLists = [[String:String]]()
        
        YoutubeUserInfo.standard.defaults.set(false, forKey: "UserHasKeychain")
        YoutubeUserInfo.standard.defaults.synchronize()
        
        self.playlistTableview.reloadData()
        hiddAction(trueOrFalse: false)
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
        let thumbnailImg = ToImage().stringToImage(inputString: plistInfo["thumbnailURL"])
        cell.thumbnailImgView.image = thumbnailImg
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "PlaylistVideoTableViewController") as? PlaylistVideoTableViewController  else {
            print("nextPage is nil")
            return
        }
        
        nextPage.userPlayList = userPlayLists[indexPath.row]
        
        navigationController?.pushViewController(nextPage, animated:true)
        
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
