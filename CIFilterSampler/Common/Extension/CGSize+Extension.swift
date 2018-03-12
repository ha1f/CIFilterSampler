//
//  CGSize+Extension.swift
//  CIFilterSampler
//
//  Created by ST20591 on 2018/03/12.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import CoreGraphics

extension CGSize {
    /// Calculate the uniformly scaled size.
    ///
    /// - parameter scale: The scale to apply
    ///
    /// - returns: The calculated size
    func uniformlyScaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}
