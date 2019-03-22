//
//  UKVimeoVideo.swift
//  WILP
//
//  Created by Umakanta Sahoo on 22/03/19.
//  Copyright © 2019 MaGE. All rights reserved.
//

import Foundation

public enum UKVimeoVideoQuality: String {
    case QualitySD = "sd"
    case QualityHD = "hd"
    case QualityHLS = "hls"
    case QualityUnknown = "unknown"
}

public class UKVimeoVideo: NSObject {
    public var title = ""
    public var link = URL(string: "")

    public var videoQualityArr = [[String: Any]]()
    
}
