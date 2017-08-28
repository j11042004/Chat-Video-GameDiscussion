
//
//  PlaylistSelectViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/25.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn

class PlaylistSelectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,GIDSignInUIDelegate {
    private let PLAYLIST_TITLE = "playlistTitle"
    private let PLAYLIST_ID = "playlistID"
    private let DEFAULT_PLAYLIST = "userPlaylist"
    
    @IBOutlet weak var chooseView: UIView!
    var playLists = [[String:String]]()
    let youtubeService = YoutubeUserInfo.standard.youtubeService
    private var choosedlistId = ""
    var insertVideoId = ""
    var insertKind = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check the user had Keychain && never signout, disconnect
        if let check = YoutubeUserInfo.standard.defaults.object(forKey: "UserHasKeychain") as? Bool {
            if let keyChain = YoutubeUserInfo.standard.signIn?.hasAuthInKeychain(){
                if check && !keyChain {
                    YoutubeUserInfo.standard.signIn?.uiDelegate = self
                    YoutubeUserInfo.standard.googleSignIn()
                }
            }
            
        }
        
        
        guard let userPlaylist = YoutubeUserInfo.standard.defaults.object(forKey: DEFAULT_PLAYLIST) as? [[String:String]] else{
            chooseView.isHidden = true
            showAlert()
            return
        }
        playLists = userPlaylist
        if playLists[0][PLAYLIST_TITLE] == nil {
            chooseView.isHidden = true
            showAlert()
            return
        }
        
        // check user have or not the play List
        guard let firstPlaylistId = playLists[0][PLAYLIST_ID ] else{
            showAlert()
            return
        }
        
        choosedlistId = firstPlaylistId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
//  MARK: - Button Function
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveInPlaylistBynAction(_ sender: Any) {
        fetchPlaylistInsertItem(playlistId: choosedlistId, insertVideoId: insertVideoId, insertKind: insertKind)
        
        self.dismiss(animated: true, completion: nil)
    }
    
//  MARK: - pickerView DataSource Function
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return playLists.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return playLists[row][PLAYLIST_TITLE]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let playlist = playLists[row]
        guard let playlistID = playlist[PLAYLIST_ID ] else {
            return
        }
        choosedlistId = playlistID
        if let title = playlist[PLAYLIST_TITLE] {
            print("choose : \(title)")
            print("choose list id :\(choosedlistId)")
        }
        
    }
    // MARK: - normal Function
    func showAlert() {
        let alert = UIAlertController.init(title: "Warning!!!", message: "Not have any Play List, please Login or create a playList", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - PlaylistItems.insert Function
    func fetchPlaylistInsertItem(playlistId: String, insertVideoId: String ,insertKind: String){
        // Set playlist info
        let playlistItem = GTLRYouTube_PlaylistItem()
        playlistItem.snippet = GTLRYouTube_PlaylistItemSnippet()
        
        // Set insert video's info
        let resourceId = GTLRYouTube_ResourceId()
        resourceId.kind = insertKind
        resourceId.videoId = insertVideoId
        
        
        playlistItem.snippet?.playlistId = playlistId
        playlistItem.snippet?.resourceId = resourceId
        
        
        youtubeService.apiKey = apiKey
        
        let insertItemQuery = GTLRYouTubeQuery_PlaylistItemsInsert.query(withObject: playlistItem, part: "snippet")
        
        youtubeService.executeQuery(insertItemQuery, delegate: self, didFinish: #selector(analysisPlaylistItemInsert(ticket:playListResponse:error:)))
    }
    func analysisPlaylistItemInsert(ticket: GTLRServiceTicket , playListResponse response :GTLRYouTube_PlaylistItemListResponse ,error: Error?){
        if let error = error {
            print("searchList Error :\(error)")
            return
        }
        print("insert OK")
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
