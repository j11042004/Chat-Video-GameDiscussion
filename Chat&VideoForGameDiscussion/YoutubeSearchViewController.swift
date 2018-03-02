//
//  YoutubeSearchViewController.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/25.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

class YoutubeSearchViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let SEARCH_KINDS = ["youtube#video","youtube#channel","youtube#playlist"]

    
    var youtubeService = YoutubeUserInfo.standard.youtubeService
    var searchResults = [[String : String]]()
    var inputWord = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = " Youtube 影片搜尋"
        // tableView add a tap event
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        
        // To get SearchTableViewReload notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notificationObj:)), name: NSNotification.Name(rawValue: "SearchTableViewReload"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.title = "Youtube搜尋"

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
// MARK: - Normal Function
    func reloadTableView(notificationObj:Notification){
        if let notificationResult = notificationObj.object as? [[String: String]]{
            searchResults = notificationResult
            print("searchResults count:\(searchResults.count)")
            self.tableView.reloadData()
        }
    }
    
// MARK: - SearchBar Delegate Function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchResults = [[String:String]]()
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBar.text else {
            return
        }
        inputWord = input
        // request youtube search result
        YoutubeUserInfo.standard.requestYoutubeSearchResult(searchWord: inputWord)
        
        
        // close keyBoard
        searchBar.resignFirstResponder()
    }
    
// MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! YouTubeSearchTableViewCell
        let videoInfo = searchResults[indexPath.row]
        if let title = videoInfo["title"] {
            cell.videoTitle.text = title
            cell.videoTitle.sizeToFit()
            cell.videoTitle.numberOfLines = 0
        }
        let image = ToImage().stringToImage(inputString: videoInfo["thumbnail"])
        cell.videoThumbnail.image = image
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchInfo = searchResults[indexPath.row]
        guard let searchTitle = searchInfo["title"] else{
            return
        }
        guard let searchID = searchInfo["id"] else{
            return
        }
        guard let searchKind = searchInfo["kind"] else {
            return
        }
        guard let nextPage = storyboard?.instantiateViewController(withIdentifier: "YoutubeVideoViewController") as? YoutubeVideoViewController else {
            return
        }
        
        nextPage.videoTitle = searchTitle
        nextPage.videoID = searchID
        nextPage.videoKind = searchKind
        navigationController?.pushViewController(nextPage, animated: true)
        
    }
    
    // MARK: - close the keyBoard
    // touch event function
    func handleTap(sender: UITapGestureRecognizer) {
        // must do the check ,otherwise the celle selected func will not do everyThing
        if sender.state == .ended {
            searchBar.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
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
