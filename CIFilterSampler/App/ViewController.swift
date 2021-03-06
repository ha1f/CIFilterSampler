//
//  ViewController.swift
//  CIFilterSampler
//
//  Created by はるふ on 2018/03/09.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
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
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var filterNames: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    lazy var ciImage = CIImage.extractOrGenerate(from: #imageLiteral(resourceName: "Lenna.png"))!
    lazy var sampleMaskImage = CIImage.extractOrGenerate(from: UIImage.circle(size: CGSize(width: 256, height: 256), color: .red, scale: 1.0)!)
    lazy var sampleTargetImage = CIImage.extractOrGenerate(from: UIImage.circle(size: CGSize(width: 256, height: 256), color: .blue, scale: 1.0)!)
    lazy var sampleBackgroundImage = CIImage.extractOrGenerate(from: UIImage.empty(size: CGSize(width: 256, height: 256), color: .cyan, scale: 1.0)!)
    
    var currentFilter: CIFilter? {
        didSet {
            updateTitle()
        }
    }
    var currentParameters: [String: Any?] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    private lazy var ciContext = CIContext()
    
    @objc
    func onReferenceButtonTapped() {
        guard let url = currentFilter?.referenceDocumentationUrl else {
            return
        }
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        
        filterNames = CIFilter.filterNames(inCategory: kCICategoryStillImage)
            .filter { CIFilter(name: $0)?.outputKeys.contains(kCIOutputImageKey) ?? false }
        resetFilter()
        indicator.stopAnimating()
    }
    
    private func updateTitle() {
        self.title = currentFilter?.displayName ?? currentFilter?.filterName
    }
    
    private func resetFilter() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        imageView.image = #imageLiteral(resourceName: "Lenna.png")
        currentParameters = [:]
        currentFilter = nil
    }
    
    private func update(withFilterName filterName: String) {
        indicator.startAnimating()
        // 同じフィルタならreset
        guard filterName != currentFilter?.filterName else {
            resetFilter()
            indicator.stopAnimating()
            return
        }
        currentParameters = [:]
        // ありえないはずだが、filterの初期化に失敗したらリセット
        guard let filter = CIFilter(name: filterName) else {
            resetFilter()
            indicator.stopAnimating()
            return
        }
        currentFilter = filter
        
        filter.setDefaults()
        filter.inputKeys.forEach { inputKey in
            // inputImageならlennaを返す
            if inputKey == kCIInputImageKey {
                currentParameters[inputKey] = ciImage
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                return
            }
            // extentなら全体を選択
            if inputKey == kCIInputExtentKey {
                currentParameters[inputKey] = CIVector(cgRect: ciImage.extent.standardized)
                filter.setValue(CIVector(cgRect: ciImage.extent.standardized), forKey: kCIInputExtentKey)
                return
            }
            // messageならhome page url
            if inputKey == "inputMessage" {
                let data = "https://ha1f.net".data(using: .isoLatin1)
                currentParameters[inputKey] = data
                filter.setValue(data, forKey: inputKey)
                return
            }
            // maskならサークル
            if inputKey == kCIInputMaskImageKey {
                currentParameters[inputKey] = sampleMaskImage
                filter.setValue(sampleMaskImage, forKey: inputKey)
                return
            }
            // timeなら0.5
            if inputKey == kCIInputTimeKey {
                currentParameters[inputKey] = 0.5
                filter.setValue(NSNumber(value: 0.5), forKey: inputKey)
                return
            }
            // targetImageならcircle
            if inputKey == kCIInputTargetImageKey {
                currentParameters[inputKey] = sampleTargetImage
                filter.setValue(sampleTargetImage, forKey: inputKey)
                return
            }
            // backgroundImageならcircle
            if inputKey == kCIInputBackgroundImageKey {
                currentParameters[inputKey] = sampleBackgroundImage
                filter.setValue(sampleBackgroundImage, forKey: inputKey)
                return
            }
            // inputTextならTEXT
            if inputKey == "inputText" {
                let data = NSAttributedString(string: "TEXT")
                currentParameters[inputKey] = data
                filter.setValue(data, forKey: inputKey)
                return
            }
            // transformなら30°
            if inputKey == kCIInputTransformKey {
                let data = CGAffineTransform(rotationAngle: CGFloat.pi / 6)
                currentParameters[inputKey] = data
                filter.setValue(data, forKey: inputKey)
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
        
        // もしかしたらCALayer.contentsのほうがはやいかも？
        let completion: (UIImage?) -> () = { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.indicator.stopAnimating()
            }
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let ciImage = filter.outputImage else {
                completion(nil)
                return
            }
            
            var image: UIImage?
            // 無限extent対策で、ある程度大きかったらContextで絞る
            if ciImage.extent.width > CGFloat(1000) {
                image = ciImage.asCGImage(using: self?.ciContext ?? CIContext(), from: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)))?.asUIImage()
            } else {
                image = ciImage.asUIImage()
            }
            completion(image)
        }
        
        referenceButton.isEnabled = filter.referenceDocumentationUrl != nil
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentParameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell") as! ParameterCell
        guard let item = currentParameters.dropFirst(indexPath.row).first else {
            return cell
        }
        cell.keyLabel.text = item.key
        cell.valueLabel.text = item.value.map { String(describing: $0) } ?? "nil"
        return cell
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
}
