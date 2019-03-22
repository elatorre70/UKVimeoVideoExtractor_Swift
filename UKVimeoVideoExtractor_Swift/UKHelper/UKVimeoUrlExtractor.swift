//
//  VimeoUrlExtractor.swift
//  MainApp
//
//  Created by Umakanta Sahoo on 20/03/19.
//  Copyright © 2019 MaGE. All rights reserved.
//

import Foundation
import VimeoNetworking

/// Extend app configuration to provide a default configuration
extension AppConfiguration
{
    /// The default configuration to use for this application, populate your client key, secret, and scopes.
    /// Also, don't forget to set up your application to receive the code grant authentication redirect, see the README for details.
    static let defaultConfiguration = AppConfiguration(clientIdentifier: UserDefaults.standard.value(forKey: "VIMEO_CLIENT_KEY") as! String , clientSecret: UserDefaults.standard.value(forKey: "VIMEO_CLIENT_SECRET_KEY") as! String, scopes: [.Public, .Private, .Interact], keychainService: "")
}

/// Extend vimeo client to provide a default client
extension VimeoClient
{
    /// The default client this application should use for networking, must be authenticated by an `AuthenticationController` before sending requests
    static let defaultClient = VimeoClient(appConfiguration: AppConfiguration.defaultConfiguration, sessionManager: nil)
}

public class UKVimeoUrlExtractor: NSObject {
    
    private var videoId: String = ""
    private var completion: ((_ video: UKVimeoVideo?, _ error: Error?) -> Void)?
    
    
    public static func fetchMP4UrlFrom(vimeoId:String, completion: @escaping (_ video: UKVimeoVideo?, _ error: Error?) -> Void) -> Void {
        if vimeoId != "" {
            let videoExtractor = UKVimeoUrlExtractor(id: vimeoId)
            videoExtractor.completion = completion
            
            DispatchQueue.main.async {
                videoExtractor.setupAuthenticate()
            }
        }
        else {
            completion(nil, NSError(domain: "com.uksoft.UKVimeoUrlExtractor", code:0, userInfo:[NSLocalizedDescriptionKey :  "Invalid video id" , NSLocalizedFailureReasonErrorKey : "Invalid video id"]))
        }
    }
    
    
    public static func fetchMP4UrlFrom(url: URL, completion: @escaping (_ video: UKVimeoVideo?, _ error: Error?) -> Void) -> Void {
        let vimeoId = url.lastPathComponent
        if vimeoId != "" {
            let videoExtractor = UKVimeoUrlExtractor(id: vimeoId)
            videoExtractor.completion = completion
        }
        else {
            completion(nil, NSError(domain: "com.uksoft.UKVimeoUrlExtractor", code:0, userInfo:[NSLocalizedDescriptionKey :  "Invalid video id" , NSLocalizedFailureReasonErrorKey : "Failed to parse the video id"]))
        }
    }
    
    private init(id: String) {
        self.videoId = id
        self.completion = nil
        super.init()
        
    }
    
    private func setupAuthenticate()
    {
        guard let completion = self.completion else {
            print("ERROR: Invalid completion handler")
            return
        }
        
        let authenticationController = AuthenticationController(client: VimeoClient.defaultClient, appConfiguration: AppConfiguration.defaultConfiguration)
        
        let accessToken = UserDefaults.standard.value(forKey: "VIMEO_CLIENT_ACCESSTOKEN_KEY") as! String
        authenticationController.accessToken(token: accessToken) { result in
            switch result
            {
            case .success (let account):
                print("authenticated successfully: \(account)")
                DispatchQueue.main.async {
                    self.loadSinglePrivateVideo()
                }
            case .failure(let error):
                print("failure authenticating: \(error)")
                completion(nil, NSError(domain: "com.uksoft.UKVimeoUrlExtractor", code:0, userInfo:[NSLocalizedDescriptionKey :  "failure authenticating: \(error)" , NSLocalizedFailureReasonErrorKey : "failure authenticating"]))
            }
        }
    }
    
    
    private func loadSinglePrivateVideo()
    {
        guard let completion = self.completion else {
            print("ERROR: Invalid completion handler")
            return
        }
        
        let request = Request<VIMVideo>(path: "/me/videos/\(videoId)")  //private
        
        let _ = VimeoClient.defaultClient.request(request) { result in
            
            switch result
            {
            case .success(let response):
                
                let video = UKVimeoVideo()
                let vimVideo: VIMVideo = response.model
                
                // 1.
                if let title = vimVideo.name {
                    video.title = title
                }
                
                // 2.
                if let link = vimVideo.link {
                    video.link = URL(string: link)
                }
                
                // 3.
                if let files = vimVideo.files as? [VIMVideoFile] {
                    //VIMVideoFile
                    for file in files {
                        if let quality = file.quality {
                            if let url = file.link {
                                
                                video.videoQualityArr.append(["quality" :UKVimeoVideoQuality(rawValue: quality) ?? .QualityUnknown,
                                                              "url" : URL(string: url)!,
                                                              "height" : file.height ?? 0,
                                                              "width" : file.width ?? 0])
                            }
                        }
                    }
                }
                
                completion(video, nil)
                
            case .failure(let error):
                
                completion(nil, NSError(domain: "com.uksoft.UKVimeoUrlExtractor", code:0, userInfo:[NSLocalizedDescriptionKey : "Video request failed : \(error)" , NSLocalizedFailureReasonErrorKey : " Video request failed"]))
            }
            
        }
        
    }
    
    //TODO: Load all PrivareVideos ...
    
    
    
    private func videoQualityWith(string: String) -> UKVimeoVideoQuality {
        if string == "sd" {
            return .QualitySD
        }
        else if string == "hd" {
            return .QualityHD
        }
        else if string == "hls" {
            return .QualityHLS
        }
        
        return .QualityUnknown
    }
    
    
}

