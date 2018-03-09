//
//  ViewController.swift
//  CIFilterSampler
//
//  Created by はるふ on 2018/03/09.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import UIKit
import SafariServices

// TODO: 処理中にぐるぐるを出す
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource {
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.allowsMultipleSelection = false
            tableView.allowsSelection = false
            tableView.tableFooterView = UIView()
            tableView.dataSource = self
        }
    }
    
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
    @IBOutlet var referenceButton: UIBarButtonItem! {
        didSet {
            referenceButton.target = self
            referenceButton.action = #selector(onReferenceButtonTapped)
        }
    }
    
    var filterNames: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    lazy var ciImage = CIImage.extractOrGenerate(from: #imageLiteral(resourceName: "Lenna.png"))!
    
    var currentFilter: CIFilter?
    var currentParameters: [String: Any?] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @objc
    func onReferenceButtonTapped() {
        guard let url = currentFilter?.referenceDocumentationUrl else {
            return
        }
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        filterNames = CIFilter.filterNames(inCategory: kCICategoryStillImage)
        imageView.image = #imageLiteral(resourceName: "Lenna.png")
    }
    
    private func updateTitle() {
        self.title = currentFilter?.displayName ?? currentFilter?.filterName
    }
    
    private func update(withFilterName filterName: String) {
        guard filterName != currentFilter?.filterName else {
            return
        }
        currentParameters = [:]
        guard let filter = CIFilter(name: filterName) else {
            currentFilter = nil
            return
        }
        currentFilter = filter
        updateTitle()
        
        filter.setDefaults()
        filter.inputKeys.forEach { inputKey in
            if inputKey == kCIInputImageKey {
                currentParameters[inputKey] = ciImage
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                return
            }
            if inputKey == kCIInputExtentKey {
                currentParameters[inputKey] = CIVector(cgRect: ciImage.extent.standardized)
                filter.setValue(CIVector(cgRect: ciImage.extent.standardized), forKey: kCIInputExtentKey)
                return
            }
            let information = filter.parameterInformation(forInputKey: inputKey)
            if let defaultValue = information[kCIAttributeDefault] {
                filter.setValue(defaultValue, forKey: inputKey)
                currentParameters[inputKey] = defaultValue
            } else {
                currentParameters[inputKey] = Any?.none
            }
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let image = filter.outputImage?.asUIImage()
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }
        
        referenceButton.isEnabled = filter.referenceDocumentationUrl != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentParameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell") as! ParameterCell
        let item = currentParameters.dropFirst(indexPath.row).first
        cell.keyLabel.text = item?.key
        if let value = item?.value {
            cell.valueLabel.text = String(describing: value)
        } else {
            cell.valueLabel.text = "nil"
        }
        
        return cell
    }

}

