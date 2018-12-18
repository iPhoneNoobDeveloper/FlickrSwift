//
//  FlickrImagesProvider.swift

//  Created by Nirav Jain on 17/12/18.
//  Copyright © 2018 Nirav Jain. All rights reserved.
//

import UIKit

struct FlickrImagesProvider: FlickrRequestImages {
    
    fileprivate let downloadQueue = DispatchQueue(label: "Flickr Images cache", qos: DispatchQoS.background)
    internal var cache = NSCache<NSURL, UIImage>()
    
    
    //MARK: - Fetch image from URL and Images cache
    fileprivate func loadImages(from url: URL, completion: @escaping (_ image: UIImage) -> Void) {
        downloadQueue.async(execute: { () -> Void in
            if let image = self.cache.object(forKey: url as NSURL) {
                DispatchQueue.main.async {
                    completion(image)
                }
                return
            }
            
            do{
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        
                        // Save current image data to NSCache
                        self.cache.setObject(image, forKey: url as NSURL)
                        completion(image)
                    }
                } else {
                    print("Fail to decode image")
                }
            }catch {
                print("Could not load image URL: \(url): \(error)")
            }
        })
    }
    
}

protocol FlickrRequestImages {}

extension FlickrRequestImages where Self == FlickrImagesProvider{
    func requestImage(from url: URL, completion: @escaping (_ image: UIImage) -> Void){
        loadImages(from: url, completion: completion)
    }
}
