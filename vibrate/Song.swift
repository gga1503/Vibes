//
//  Song.swift
//  vibrate
//
//  Created by Christopher Putra Setiawan on 14/08/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import Foundation
import UIKit

class Song: NSObject, NSCoding{
    
    var title:String = ""
    var fileType: String = ""
    var extention: String = ""
    var artwork: UIImage?
    var size: String = ""
    var artist: String = ""
    var id: UInt64?
    var bpm: Int!
    var storagePath: String
    var isCloudItem: Bool = false
    init(title: String, fileType: String, ext: String, artwork: Any, size: String, artist: String, bpm: Int, id: UInt64, storagePath: String, isClouditem: Bool) {
        self.title = title
        self.fileType = fileType
        self.extention = ext
        self.size = size
        self.artist = artist
        self.id = id
        self.bpm = bpm
        self.storagePath = storagePath
        self.isCloudItem = isClouditem
        if let containart = artwork as? UIImage {
            self.artwork = containart
        }
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(fileType, forKey: "fileType")
        aCoder.encode(extention, forKey: "extention")
        aCoder.encode(artwork, forKey: "artwork")
        aCoder.encode(size, forKey: "size")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(bpm, forKey: "bpm")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(storagePath, forKey: "storagePath")
        aCoder.encode(isCloudItem, forKey: "isCloudItem")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObject(forKey: "title") as! String
        let fileType = aDecoder.decodeObject(forKey: "fileType") as! String
        let extention = aDecoder.decodeObject(forKey: "extention") as! String
        let artwork = aDecoder.decodeObject(forKey: "artwork") as? UIImage
        let size = aDecoder.decodeObject(forKey: "size") as! String
        let artist = aDecoder.decodeObject(forKey: "artist") as! String
        let bpm = aDecoder.decodeObject(forKey: "bpm") as! Int
        let id = aDecoder.decodeObject(forKey: "id") as! UInt64
        let storagePath = aDecoder.decodeObject(forKey: "storagePath") as! String
        let isCloudItem = (aDecoder.decodeObject(forKey: "isCloudItem") ?? false) as! Bool
        
        self.init(title: title, fileType: fileType, ext: extention, artwork: artwork as Any, size: size,artist: artist, bpm: bpm, id: id,storagePath: storagePath, isClouditem: isCloudItem)
    }
}
