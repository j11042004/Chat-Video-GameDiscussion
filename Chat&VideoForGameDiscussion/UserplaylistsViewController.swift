//
//  UserplaylistsViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/9/11.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
class UserplaylistsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let signIn = YoutubeUserInfo.standard.signIn
    private let youtubeService = YoutubeUserInfo.standard.youtubeService
    private var userPlayLists = [[String : String]]()
    private let defaults = YoutubeUserInfo.standard.defaults
    
    private var signOutBtn = UIBarButtonItem()
    @IBOutlet weak var playlistsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
//        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = "播放清單"
        
        signOutBtn = UIBarButtonItem(title: "Google 登出", style: UIBarButtonItemStyle.plain, target: self, action: #selector(googleSignOut))
        self.navigationItem.rightBarButtonItem = signOutBtn
        self.navigationItem.rightBarButtonItem?.accessibilityElementsHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        getUserPlayLists()
    }
    @objc func googleSignOut(){
        
        YoutubeUserInfo.standard.googelSignOut()
        self.navigationController?.popViewController(animated: true)
    }
//MARK: Youtube request function
    // get user's playlists info
    func getUserPlayLists(){
        // play list request query
        let playListsQuery = GTLRYouTubeQuery_PlaylistsList.query(withPart: "contentDetails, snippet")
        // Set to get user's playLists
        playListsQuery.mine = true
        playListsQuery.maxResults = 50
        // youtubeService request
        youtubeService.executeQuery(playListsQuery, delegate: self, didFinish: #selector(getPlaylistsInfo(ticket:playlistsListResponse:error:)))
    }
    
    @objc func getPlaylistsInfo(ticket: GTLRServiceTicket , playlistsListResponse response :GTLRYouTube_PlaylistListResponse ,error: Error?){
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
            
            
            self.playlistsTableView.reloadData()
        }
        
    }

    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPlayLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlaylistsTableViewCell
        
        let plistInfo = userPlayLists[indexPath.row]
        
        guard let title = plistInfo["playlistTitle"] else {
            return cell
        }
        cell.titleLabel.text = title
        cell.titleLabel.sizeToFit()
        cell.titleLabel.numberOfLines = 0
        let thumbnailImg = ToImage().stringToImage(inputString: plistInfo["thumbnailURL"])
        
        cell.thumbnailImgView.image = thumbnailImg
        cell.thumbnailImgView.sizeToFit()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
