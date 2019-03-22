//
//  ViewController.swift
//  UKVimeoVideoExtractor_Swift
//
//  Created by Umakanta Sahoo on 22/03/19.
//  Copyright © 2019 UKS. All rights reserved.
//

import UIKit
//For Playing Video
import AVKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Any Private / Public Vimeo Video url
        let vimeoUrl = "https://vimeo.com/2349145657";
        
        //From URL...
        //self.retriveMP4UrlFor(vUrl: URL(string: vimeoUrl)!)
        
        let arr = vimeoUrl.components(separatedBy: "/")
        let vimeoId = arr[arr.count-1]
        
        //From vimeoId...
        self.retriveMP4UrlFor(vid: vimeoId);
    }

    func retriveMP4UrlFor(vid: String) -> Void {
        //Find these values form your Vimeo Account (Pro / Business)
        UserDefaults.standard.set("YOUR_CLIENT_KEY_HERE", forKey: "VIMEO_CLIENT_KEY")
        UserDefaults.standard.set("YOUR_CLIENT_SECRET_HERE", forKey: "VIMEO_CLIENT_SECRET_KEY")
        UserDefaults.standard.set("YOUR_CLIENT_ACCESSTOKEN_HERE", forKey: "VIMEO_CLIENT_ACCESSTOKEN_KEY")
        
        UKVimeoUrlExtractor.fetchMP4UrlFrom(vimeoId: vid, completion: { (video: UKVimeoVideo?, error: Error?) -> Void in
            
            if let err = error {
                
                print("Error = \(err.localizedDescription)")
                
                DispatchQueue.main.async() {
                    
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let vid = video else {
                print("Invalid video object")
                return
            }
            
            print("Title = \(vid.title), url = \(vid.link!.absoluteString)")
            print("Quality = \(vid.videoQualityArr)")
            
            DispatchQueue.main.async() {
                
                self.title = vid.title
                self.videoURL = (vid.videoQualityArr[0] as Dictionary)["url"] as? URL
            
                self.playButton.setTitle("Play Video", for: .normal)
                self.playButton.isEnabled = true;
            }
            
        })
    }
    
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        if let url = self.videoURL {
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                player.play()
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Invalid video URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func retriveMP4UrlFor(vUrl: URL) -> Void {
        //Find these values form your Vimeo Account (Pro / Business)
        UserDefaults.standard.set("YOUR_CLIENT_KEY_HERE", forKey: "VIMEO_CLIENT_KEY")
        UserDefaults.standard.set("YOUR_CLIENT_SECRET_HERE", forKey: "VIMEO_CLIENT_SECRET_KEY")
        UserDefaults.standard.set("YOUR_CLIENT_ACCESSTOKEN_HERE", forKey: "VIMEO_CLIENT_ACCESSTOKEN_KEY")
        
        UKVimeoUrlExtractor.fetchMP4UrlFrom(url: vUrl, completion: { (video: UKVimeoVideo?, error: Error?) -> Void in
            
            if let err = error {
                
                print("Error = \(err.localizedDescription)")
                
                DispatchQueue.main.async() {
                    
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let vid = video else {
                print("Invalid video object")
                return
            }
            
            print("Title = \(vid.title), url = \(vid.link!.absoluteString)")
            print("Quality = \(vid.videoQualityArr)")
            
            
            
        })
    }

}

