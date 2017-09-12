//
//  YoutubeVideoViewController.swift
//  YoutubeTest
//
//  Created by Uran on 2017/7/20.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import AVFoundation
import XCDYouTubeKit
class YoutubeVideoViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    var youtubeService = YoutubeUserInfo.standard.youtubeService
    
    var videoID = ""
    var videoDiscription = ""
    var videoTitle = ""
    var videoKind = ""
    var videoPlayerVc = XCDYouTubeVideoPlayerViewController()
    
    private var addinPlaylistVC = PlaylistSelectViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "影片播放"
        
        // Do any additional setup after loading the view.
        titleLabel.text = videoTitle
        titleLabel.numberOfLines = 0

        getVideoInformation(videoId: videoID)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        

    }
    override func viewDidAppear(_ animated: Bool) {
        
        videoPlayerVc.videoIdentifier = videoID
        videoPlayerVc.present(in: self.webView)
        videoPlayerVc.moviePlayer.prepareToPlay()
        videoPlayerVc.moviePlayer.shouldAutoplay = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        // let addinPlaylist viewController dismiss

        // get pause time
//        print(videoPlayerVc.moviePlayer.currentPlaybackTime)
        videoPlayerVc.moviePlayer.pause()
        
        addinPlaylistVC.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
   
    @IBAction func addInPlaylistAction(_ sender: Any) {
        
         guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "PlaylistSelectViewController") as? PlaylistSelectViewController else {
         print("next is nil")
         return
         }
        addinPlaylistVC = nextPage
         nextPage.insertKind = videoKind
         nextPage.insertVideoId = videoID
        
         present(addinPlaylistVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Youtube fetch function
    func getVideoInformation(videoId: String){
        let videoListQuery = GTLRYouTubeQuery_VideosList.query(withPart: "snippet")
        videoListQuery.identifier = videoId
        
        youtubeService.apiKey = apiKey
        youtubeService.executeQuery(videoListQuery, delegate: self, didFinish: #selector(analysisVideoList(ticket:videoListResponse:error:)))
    }
    
    func analysisVideoList(ticket: GTLRServiceTicket , videoListResponse response :GTLRYouTube_VideoListResponse ,error: Error?){
        if let error = error {
            print("videoList Error :\(error)")
            return
        }
        guard let items = response.items else{
            print("items is nil")
            return
        }
        if items.first == nil {
            showMissingAlert()
        }
        for item in items {
            guard let snippet = item.snippet else{
                return
            }
            if let videoDesc = snippet.descriptionProperty {
                if videoDesc != "" {
                    videoDiscription = videoDesc
                    DispatchQueue.main.async {
                        self.descriptionTextView.text = self.videoDiscription
                    }
                }else{
                    self.descriptionTextView.isHidden = true
                }
            }
        }
    }
    func showMissingAlert(){
        let alert = UIAlertController.init(title: "", message: "This Video is missing. Please check this source", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .destructive) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
