//
//  CGImage+Extension.swift
//  CIFilterSampler
//
//  Created by ST20591 on 2018/03/12.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import UIKit

extension CGImage {
    /// Convert to UIImage
    func asUIImage(scale: CGFloat = UIScreen.main.scale, orientation: UIImageOrientation = .up) -> UIImage {
        return UIImage(cgImage: self, scale: scale, orientation: orientation)
    }
}
