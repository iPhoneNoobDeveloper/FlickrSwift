//
//  FlickrSearchSwiftTests.swift
//
//  Created by Nirav Jain on 15/12/18.
//  Copyright © 2018 Nirav Jain. All rights reserved.
//

import XCTest
@testable import FlickrSearchSwift

class FlickrSearchSwiftTests: XCTestCase {
    
    var viewController: SearchPhotosViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        viewController =  SearchPhotosViewController()
        let navigationController = UINavigationController(rootViewController: viewController!)
        navigationController.loadView()
        navigationController.viewDidLoad()
        viewController?.loadView()
        viewController?.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: viewController.view.frame, collectionViewLayout: layout)
        viewController?.photosCollectionView = collectionView
        
        
    }
    
    func testSearch() {
        viewController.searchBar?.text = "asdadadadasdasdas"
        viewController.searchBarSearchButtonClicked(viewController.searchBar ?? UISearchBar())
        XCTAssertTrue(viewController.searchPhotosArray.count == 0)
        
    }
    
    func testNextPageSearch() {
        viewController.searchBar?.text = "delta"
        viewController.searchBarSearchButtonClicked(viewController.searchBar ?? UISearchBar())
        viewController.pageCount = viewController.pageCount+1
        viewController.photosCollectionView?.reloadData()
    }
    
    func testNilTextSearch() {
        viewController.searchBar?.text = ""
        viewController.searchBarSearchButtonClicked(viewController.searchBar ?? UISearchBar())
        viewController.photosCollectionView?.reloadData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    
}
