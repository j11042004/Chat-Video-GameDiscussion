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

    let lock = NSLock()
    var userPlayList = [String :String]()
    var youtubeService = YoutubeUserInfo.standard.youtubeService
    var listVideos = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = userPlayList["playlistTitle"]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        guard let playListID = userPlayList["playlistID"] else {
            print("playlistID is nil")
            return
        }
        
        YoutubeUserInfo.standard.requestPlaylistItem(from: playListID)
        
        // To get PlaylistItemsTableViewReload notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notificationObj:)), name: NSNotification.Name(rawValue: "PlaylistItemsTableViewReload"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - normal Function
    func reloadTableView(notificationObj:Notification){
        if let notificationResult = notificationObj.object as? [[String: String]]{
            listVideos = notificationResult
            print("listVideos count : \(listVideos.count)")
            self.tableView.reloadData()
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
        
        let thumbnailImg = ToImage().stringToImage(inputString: videoInfo["thumbnailURL"])
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
        navigationController?.pushViewController(nextPage, animated:true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            guard let deleteVideoIdInPlaylist = listVideos[indexPath.row]["idForVideoInPlaylist"] else {
                return
            }
            // to delet the playlist's item
            YoutubeUserInfo.standard.requestToDeletePlaylistItem(deleteItemID: deleteVideoIdInPlaylist)
            // must to remove the element to which your request first
            listVideos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 

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
