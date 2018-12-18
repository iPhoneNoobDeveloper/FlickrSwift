//
//  SearchPhotosViewController.swift
//
//  Created by Nirav Jain on 15/12/18.
//  Copyright © 2018 Nirav Jain. All rights reserved.
//

import UIKit

class SearchPhotosViewController: UIViewController, AlertMessage {

    
    fileprivate let downloadQueue = DispatchQueue(label: "Flickr Images cache", qos: DispatchQoS.background)

    @IBOutlet weak var photosCollectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar?
   
    var searchPhotosArray = [Photo]()
    fileprivate let router = ServiceRouter()
    var pageCount = 0
    fileprivate let imageProvider = FlickrImagesProvider()
    var isLoadingImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar?.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    //MARK: - Load search text results
    func fetchSearchImages(){
        
        isLoadingImages = true
        //Load next page records
        pageCount+=1
        
        router.requestFor(text: searchBar?.text ?? "", with: pageCount.description, decode: { json -> Photos? in
            self.isLoadingImages = false
            guard let flickrResult = json as? Photos else { return  nil }
            return flickrResult
        }) { [unowned self] result in
            DispatchQueue.main.async {
                //self.labelLoading.text = ""
                switch result{
                case Result.success(let value):
                    self.updateSearchResult(with: value.photos.photo)
                    self.isLoadingImages = false
                case Result.failure(let error):
                    print(error.localizedDescription)
                    self.isLoadingImages = false
                    guard self.router.requestCancelStatus == false else { return }
                    self.showAlertWithError((error.localizedDescription) , completionHandler: {[unowned self] status in
                        guard status else { return }
                        self.fetchSearchImages()
                    })
                }
            }
        }
    }
    
    //MARK: - Handle response result
    func updateSearchResult(with photo: [Photo]){
        DispatchQueue.main.async { [unowned self] in
            let newItems = photo
            
            // update data source
            self.searchPhotosArray.append(contentsOf: newItems)
            
            if self.searchPhotosArray.count == 0{
                self.showAlertWithNoRecords("No records found!" , completionHandler: {[unowned self] status in
                    print("No records found!")
                    return
                })
            }
            
            //Reloading Collection view Data
            self.photosCollectionView?.reloadData()
        }
    }
}

//MARK: - SearchBar Delegate
extension SearchPhotosViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        
        //Reset old data first befor new search Results
        resetValuesForNewSearch()
        
        guard let text = searchBar.text?.removeSpace,
            text.count != 0  else {
                //labelLoading.text = "Please type keyword to search result."
                return
        }
        
        //Requesting here new keyword
        fetchSearchImages()
        
        //labelLoading.text = "Searching Images..."
    }
    
    //Clearing here old data search results with current running tasks
    func resetValuesForNewSearch(){
        pageCount = 0
        router.cancelTask()
        searchPhotosArray.removeAll()
        photosCollectionView?.reloadData()
    }
}

//MARK: - Collection View DataSource
extension SearchPhotosViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return searchPhotosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrPhotoCollectionViewCell", for: indexPath) as! FlickrPhotoCollectionViewCell
        guard searchPhotosArray.count != 0 else {
            return cell
        }
        let model = searchPhotosArray[indexPath.row]
        guard let mediaUrl = model.getFlickrImagePath() else {
            return cell
        }
        let image = imageProvider.cache.object(forKey: mediaUrl as NSURL)
        //cell.flickrPhotoImageView.backgroundColor = UIColor.random()
        cell.flickrPhotoImageView.image = image
        if image == nil {
            imageProvider.requestImage(from :mediaUrl, completion: { (image) -> Void in
                let indexPath_ = collectionView.indexPath(for: cell)
                if indexPath == indexPath_ {
                    cell.flickrPhotoImageView.image = image
                }
            })
        }
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension SearchPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        let itemWidth = collectionWidth / 3 - 1
        return CGSize(width: itemWidth-5, height: itemWidth-5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
    }
}

//MARK: - Scrollview Delegate
extension SearchPhotosViewController: UIScrollViewDelegate {
    
    //MARK :- Getting user scroll down event here
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photosCollectionView{
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height)/2){
                
                //Start locading new data from here
                if !isLoadingImages{
                    fetchSearchImages()
                }
            }
        }
    }
}

// MARK: - Random color generator
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static func random() -> UIColor {
        return UIColor(rgb: Int(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * 0xFFFFFF))
    }
    
}

// MARK: - Alerts
protocol AlertMessage: class {
    typealias Events = (_ retry: Bool)-> Void
    
    func showAlertWithError(_ message: String, completionHandler: @escaping Events)
    func showAlertWithNoRecords(_ message: String, completionHandler: @escaping Events)
}

extension AlertMessage where Self: UIViewController{
    
    //Show Error Alert
    func showAlertWithError(_ message: String, completionHandler: @escaping Events) {
        let alert = UIAlertController(title: NSLocalizedString("Opps!", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""),
                                      style: .default,
                                      handler: { _ in completionHandler(true) }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Show No_records Alert
    func showAlertWithNoRecords(_ message: String, completionHandler: @escaping Events) {
        let alert = UIAlertController(title: NSLocalizedString("Opps!", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
