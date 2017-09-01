//
//  YoutubeUserInfo.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/25.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn

class YoutubeUserInfo: NSObject,GIDSignInDelegate
{
    static let standard = YoutubeUserInfo()
    
    var defaults = UserDefaults.standard
    
    let youtubeService = GTLRYouTubeService()
    let signIn = GIDSignIn.sharedInstance()
    //    Set request Authorize
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeYoutubepartner,kGTLRAuthScopeYouTube]
    
    private var playlistId = ""
    private var listVideos = [[String : String]]()
    
    
    private var searchWord = ""
    private var searchResults = [[String : String]]()
    
    func googleSignIn() {
        // uidelefgete 涉及到ui 所以要再被呼叫的地方牽上
        signIn?.delegate = self
        signIn?.clientID = clientID
        // 要做不然無法跳到權限畫面
        signIn?.scopes = scopes
        signIn?.signIn()
    }
    
    func requestPlaylistItem(from playlistId:String){
        self.listVideos = [[String : String]]()
        self.playlistId = playlistId
        requestPlaylistItemsInfo(playListID: playlistId, pagetoken: "")
    }
    func requestYoutubeSearchResult(searchWord : String){
        self.searchResults = [[String : String]]()
        self.searchWord = searchWord
        requesrSearch(searchString: searchWord, fetchNext: false)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            NSLog("Sing in Fail : \(error)")
            return
        }
        // Youtube 授權要求
        youtubeService.authorizer = user.authentication?.fetcherAuthorizer()
        
    }

// MARK: - Youtube request
    // Playlist's videos info request
    func requestPlaylistItemsInfo(playListID : String, pagetoken : String){
        // Set All items From playList Query
        let playlistItemsQuery = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: "snippet,contentDetails,status")
        playlistItemsQuery.playlistId = playListID
        playlistItemsQuery.maxResults = 50
        playlistItemsQuery.pageToken = pagetoken
        youtubeService.executeQuery(playlistItemsQuery, delegate: self, didFinish: #selector(analysisPlaylistsItemResult(ticket:playlistResponse:error:)))
    }
    // get playList's all videos more Information
    func analysisPlaylistsItemResult(ticket: GTLRServiceTicket , playlistResponse response :GTLRYouTube_PlaylistItemListResponse ,error: Error?) {
        if let error = error {
            print("error:\(error)")
            return
        }
        if let items = response.items {
            for item in items {
                var videoInfo = [String : String]()
                if let idForVideoInPlaylist = item.identifier {
                    videoInfo["idForVideoInPlaylist"] = idForVideoInPlaylist
                }
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
            // use notification to Reload TableView
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlaylistItemsTableViewReload"), object: listVideos )
            // check if the playlist has more than 50 items
            if let pageToken = response.nextPageToken  {
                requestPlaylistItemsInfo(playListID: playlistId, pagetoken: pageToken)
            }
        }
    }
    
    // Request to delete a item in playlist
    func requestToDeletePlaylistItem(deleteItemID: String){
        let playlistItemDeleteQuery = GTLRYouTubeQuery_PlaylistItemsDelete.query(withIdentifier: deleteItemID)
        youtubeService.executeQuery(playlistItemDeleteQuery) { (ticket, response, error) in
            if let error = error {
                print("Delete Error :\(error)")
                return
            }
        }
    }
    
    // PlaylistItems.insert Function
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
    // Youtube search request function
    func requesrSearch(searchString: String, fetchNext: Bool){
        let searchListsQuery = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        searchListsQuery.q = searchString
        
        searchListsQuery.maxResults = 50
        searchListsQuery.type = "video"
        
        youtubeService.apiKey = apiKey
        youtubeService.shouldFetchNextPages = fetchNext
        
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
                /*
                 // check the find result is channel or playlist or video but now search only limit to video. So it is useful
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
                 */
            }
            if let searchID = item.identifier?.videoId {
                searchResult["id"] = searchID
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
            // check search results where contains the first search
            let compriseBool = searchResults.contains(where: { (result) -> Bool in
                if result["id"] == searchResult["id"]{
                    return true
                }else{
                    return false
                }
            })
            if !compriseBool {
                searchResults.append(searchResult)
            }
            
        }
        // use notification to Reload TableView
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchTableViewReload"), object: searchResults )
        if response.nextPageToken != nil && response.nextPageToken != ""{
            requesrSearch(searchString: searchWord, fetchNext: true)
        }
    }

    //MARK: - Notificition
    func chooseColor() {
        // use notification to Reload TableView
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: searchResults )
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadTableView"), object: nil)
    }

}
