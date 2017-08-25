//
//  YoutubeVideoViewController.swift
//  YoutubeTest
//
//  Created by Uran on 2017/7/20.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

class YoutubeVideoViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubeEmber: UIWebView!
    
    var youtubeService = GTLRYouTubeService()
    
    var videoID = ""
    var videoDiscription = ""
    var videoTitle = ""
    var videoKind = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Kind: \(videoKind)")
        print("ID: \(videoID)")
        titleLabel.text = videoTitle
        titleLabel.numberOfLines = 0
        getVideoInformation(videoId: videoID)
        loadYoutube(videoID: videoID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func addInPlaylistAction(_ sender: Any) {
        
         guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "PlaylistSelectViewController") as? PlaylistSelectViewController else {
         print("next is nil")
         return
         }
//         nextPage.insertKind = videoKind
//         nextPage.insertVideoId = videoID
         
         present(nextPage, animated: true, completion: nil)
        
    }
    
        
    

    func loadYoutube(videoID:String) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
                return
        }
        
        youtubeEmber.allowsInlineMediaPlayback = true
        youtubeEmber.loadRequest( URLRequest(url: youtubeURL) )
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
    
    
}
