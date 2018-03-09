//
//  ViewController.swift
//  CIFilterSampler
//
//  Created by はるふ on 2018/03/09.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = false
            collectionView.backgroundColor = .black
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionView: UITextView!
    
    var filterNames: [String] = []
    lazy var ciImage = CIImage.extractOrGenerate(from: #imageLiteral(resourceName: "Lenna.png"))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        filterNames = CIFilter.filterNames(inCategory: kCICategoryStillImage)
        imageView.image = #imageLiteral(resourceName: "Lenna.png")
    }
    
    private func update(withFilterName filterName: String) {
        guard let filter = CIFilter(name: filterName) else {
            return
        }
        
        self.title = filter.displayName ?? filterName
        
        filter.inputKeys.forEach { inputKey in
            if inputKey == kCIInputImageKey {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                return
            }
            let information = filter.parameterInformation(forInputKey: inputKey)
            let defaultValue = information[kCIAttributeDefault]
            filter.setValue(defaultValue, forKey: inputKey)
        }
        descriptionView.text = filter.referenceDocumentationUrl?.absoluteString
        
        imageView.image = filter.outputImage?.asUIImage()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select", indexPath.row)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        let filterName = filterNames[indexPath.row]
        update(withFilterName: filterName)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.backgroundColor = .white
        cell.label.text = filterNames[indexPath.row]
        cell.label.textColor = .brown
        return cell
    }

}

