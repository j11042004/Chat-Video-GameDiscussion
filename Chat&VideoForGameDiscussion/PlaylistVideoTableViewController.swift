//
//  PlaylistVideoTableViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/25.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
class PlaylistVideoTableViewController: UITableViewController {

    
    var userPlayList = [String :String]()
    var youtuvbeService = GTLRYouTubeService()
    var listVideos = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        guard let playListID = userPlayList["playlistID"] else {
            print("playlistID is nil")
            return
        }
        fetchPlaylistsItemInfo(playListID: playListID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Youtube request function
    // Get playlist's videos info
    func fetchPlaylistsItemInfo(playListID : String){
        // Set All items From playList Query
        let playlistItemsQuery = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: "snippet,contentDetails,status")
        playlistItemsQuery.playlistId = playListID
        playlistItemsQuery.maxResults = 50
        
        youtuvbeService.executeQuery(playlistItemsQuery, delegate: self, didFinish: #selector(displayPlaylistsItemResult(ticket:playlistResponse:error:)))
    }
    // get playList's all videos  more Information
    func displayPlaylistsItemResult(ticket: GTLRServiceTicket , playlistResponse response :GTLRYouTube_PlaylistItemListResponse ,error: Error?) {
        if let error = error {
            print("error:\(error)")
            return
        }
        if let items = response.items {
            for item in items {
                var videoInfo = [String : String]()
                let snippet = item.snippet
                if let videoTitle = snippet?.title {
                    videoInfo["videoTitle"] = videoTitle
                }
                if let thumbnailURL = snippet?.thumbnails?.defaultProperty?.url {
                    videoInfo["thumbnailURL"] = thumbnailURL
                }
                if let videoID = item.contentDetails?.videoId {
                    videoInfo["videoID"] = videoID
                }
                if let videoKind = snippet?.resourceId?.kind {
                    videoInfo["videoKind"] = videoKind
                }
                
                listVideos.append(videoInfo )
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listVideos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! PlaylistVideoTableViewCell
        let videoInfo = listVideos[indexPath.row]
        guard let title = videoInfo["videoTitle"] else {
            return cell
        }
        cell.videoTitle.text = title
        cell.videoTitle.numberOfLines = 0
        cell.videoTitle.sizeToFit()
        
        let thumbnailImg = StringToImage().stringToImage(inputString: videoInfo["thumbnailURL"])
        cell.videoThumbnail.image = thumbnailImg
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let videoID = listVideos[indexPath.row]["videoID"] else {
            print("videoID is nil")
            return
        }
        guard let title = listVideos[indexPath.row]["videoTitle"] else {
            print("videoTitle is nil")
            return
        }
        guard let videoKind = listVideos[indexPath.row]["videoKind"] else {
            print("videoKind is nil")
            return
        }
        
        // prepare next page (YoutubeVideoViewController)
        guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "YoutubeVideoViewController") as? YoutubeVideoViewController  else {
            return
        }
        nextPage.videoID = videoID
        nextPage.videoTitle = title
        nextPage.videoKind = videoKind
        // Show nextPage
        //        present(nextPage, animated: true, completion: nil)
        navigationController?.pushViewController(nextPage, animated:true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
