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

    
    var youtubeService = GTLRYouTubeService()
    var searchResults = [[String : String]]()
    var inputWord = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView add a tap event
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
// MARK: - Normal Function
    // MARK: - Youtube fetch function
    func getSearchPlayList(searchString: String, shouldFetch: Bool, pageToken: String){
        let searchListsQuery = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        searchListsQuery.q = searchString
        
        searchListsQuery.maxResults = 50
        searchListsQuery.pageToken = pageToken
        searchListsQuery.type = "video"
        
        youtubeService.apiKey = apiKey
        youtubeService.shouldFetchNextPages = shouldFetch
        
        youtubeService.executeQuery(searchListsQuery, delegate: self, didFinish: #selector(analysisSearchList(ticket:searchListResponse:error:)))
    }
    
    func analysisSearchList(ticket: GTLRServiceTicket , searchListResponse response :GTLRYouTube_SearchListResponse ,error: Error?){
        if let error = error {
            print("searchList Error :\(error)")
            return
        }
        guard let items = response.items else{
            print("items is nil")
            return
        }
        // Get all searchList Information
        
        for item in items {
            var searchResult = [String : String]()
            if let kind = item.identifier?.kind {
                searchResult["kind"] = kind
                switch kind {
                case SEARCH_KINDS[0]:
                    if let searchID = item.identifier?.videoId {
                        searchResult["id"] = searchID
                    }
                    break
                case SEARCH_KINDS[1]:
                    if let searchID = item.identifier?.channelId {
                        print("==============Find Channel===============")
                        searchResult["id"] = searchID
                    }
                    break
                default:
                    if let searchID = item.identifier?.playlistId {
                        print("==============playlistId===============")
                        searchResult["id"] = searchID
                    }
                    break
                }
            }
            
            
            if let searchTitle = item.snippet?.title {
                searchResult["title"] = searchTitle
            }
            if let searchDescription = item.snippet?.descriptionProperty {
                searchResult["description"] = searchDescription
            }
            if let thumbnail = item.snippet?.thumbnails?.defaultProperty?.url  {
                searchResult["thumbnail"] = thumbnail
            }
            
            let tAndF = searchResults.contains(where: { (item) -> Bool in
                if item["id"] == searchResult["id"] {
                    return true
                }
                else {
                    return false
                }
            })
            
            if !tAndF {
                searchResults.append(searchResult)
            }
            
        }
        // Reload TableView
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
        if let pageToken = response.nextPageToken {
            getSearchPlayList(searchString: inputWord, shouldFetch: true, pageToken: pageToken)
        }
    }
    

// MARK: - SearchBar Delegate Function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchResults = [[String:String]]()
            self.tableView.reloadData()
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchResults = [[String:String]]()
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBar.text else {
            return
        }
        inputWord = input
        print(inputWord)
        
        searchResults = [[String:String]]()
        getSearchPlayList(searchString: inputWord, shouldFetch: false, pageToken: "")
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
        let image = StringToImage().stringToImage(inputString: videoInfo["thumbnail"])
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
