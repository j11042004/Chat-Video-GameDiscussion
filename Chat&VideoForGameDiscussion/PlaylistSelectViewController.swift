
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
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissView)))
        
        // Check User never disconnect the account
        let check = YoutubeUserInfo.standard.defaults.bool(forKey: "UserHasKeychain")
        
        if let hasKeyChain = YoutubeUserInfo.standard.signIn?.hasAuthInKeychain(){
            print("hasKeyChain :\(hasKeyChain)")
            if check == false {
                showAlert()
                return
            }
            if check && !hasKeyChain {
                print("call YoutubeUserInfo google sign in")
                YoutubeUserInfo.standard.signIn?.uiDelegate = self
                YoutubeUserInfo.standard.googleSignIn()
            }
        }

        guard let userPlaylist = YoutubeUserInfo.standard.defaults.object(forKey: DEFAULT_PLAYLIST) as? [[String:String]] else{
            chooseView.isHidden = true
            showAlert()
            return
        }
        
        if userPlaylist.first == nil {
            chooseView.isHidden = true
            showAlert()
            return
        }
        //Set playLists from userPlaylist
        playLists = userPlaylist
        if playLists[0][PLAYLIST_TITLE] == nil {
            chooseView.isHidden = true
            showAlert()
            return
        }
        
        // check user have or not the play List and set the default playlistId is first playlist' id
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
        dismissView()
    }
//  MARK: - Button Function
    @IBAction func dismissAction(_ sender: Any) {
        dismissView()
    }
    @IBAction func saveInPlaylistBynAction(_ sender: Any) {
        // request to insert item in playlist
        YoutubeUserInfo.standard.fetchPlaylistInsertItem(playlistId: choosedlistId, insertVideoId: insertVideoId, insertKind: insertKind)
        
        dismissView()
    }
    @objc func dismissView() {
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
        if playLists.count == 0{
            return ""
        }
        return playLists[row][PLAYLIST_TITLE]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let playlist = playLists[row]
        guard let playlistID = playlist[PLAYLIST_ID ] else {
            return
        }
        choosedlistId = playlistID
        
    }
    // MARK: - normal Function
    func showAlert() {
        let alert = UIAlertController.init(title: "Warning!!!", message: "可能你未登入，或是沒有播放清單，請確認是否已登入或有創建播放清單", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
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
