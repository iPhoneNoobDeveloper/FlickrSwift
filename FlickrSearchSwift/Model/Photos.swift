//
//  Photos.swift
//
//  Created by Nirav Jain on 16/12/18.
//  Copyright © 2018 Nirav Jain. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: PhotosWrapper
    
    struct PhotosWrapper: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        let photo: [Photo]
    }
    
}

struct Photo: Codable, PhotoURL {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let  isfamily: Int
}

protocol PhotoURL {}

extension PhotoURL where Self == Photo{
    func getFlickrImagePath() -> URL?{
        
        // Complete Flickr Image URL
        let sourcepath = "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: sourcepath)
    }
}

