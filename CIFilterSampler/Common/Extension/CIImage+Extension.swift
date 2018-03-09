//
//  CIImage+Extension.swift
//  CIFilterSampler
//
//  Created by はるふ on 2018/03/09.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import Foundation
import UIKit

extension CIImage {
    /// Extract or generate CIImage
    /// If the UIImage is build from CGImage, ciImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624129-ciimage
    /// If so, we must build by CIImage(image:_).
    ///
    /// - parameter image: UIImage from which you want to get CIImage
    ///
    /// - returns: Generated CIImage
    static func extractOrGenerate(from image: UIImage) -> CIImage? {
        return image.ciImage ?? CIImage(image: image)
    }
    
    /// Resize image to given size
    ///
    /// - parameter size: size to fit
    ///
    /// - returns: Generated CIImage. Nil on error.
    func resized(to size: CGSize) -> CIImage? {
        guard extent.width != 0 && extent.height != 0 else {
            debugPrint("extent.width or extent.height is 0 so you cannot resize this CIImage to the size: \(size)")
            return nil
        }
        let xScale = size.width / extent.width
        let yScale = size.height / extent.height
        return transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))
    }
    
    /// Convert to UIImage
    func asUIImage(scale: CGFloat = UIScreen.main.scale, orientation: UIImageOrientation = .up) -> UIImage {
        return UIImage(ciImage: self, scale: scale, orientation: orientation)
    }
}
