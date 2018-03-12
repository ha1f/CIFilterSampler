//
//  UIImage+Extension.swift
//  CIFilterSampler
//
//  Created by ST20591 on 2018/03/12.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import UIKit

extension UIImage {
    /// Create UIImage of circle.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color of the circle
    /// - parameter backgroundColor: Background color of the image
    ///
    /// - returns: The created image. Nil on error.
    static func circle(size: CGSize, color: UIColor, backgroundColor: UIColor = .clear, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let frame = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cgContext = context.cgContext
            backgroundColor.setFill()
            context.fill(frame)
            color.setFill()
            cgContext.setLineWidth(0)
            cgContext.addEllipse(in: frame)
            cgContext.fillPath()
        }
    }
    
    /// Create UIImage filled with a color. Faster, but if you will use cgImage, you should use coregraphics version.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color to fill
    ///
    /// - returns: The created image. Nil on error.
    static func empty(size: CGSize, color: UIColor = .clear, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let actualScale = scale > 0 ? scale : UIScreen.main.scale
        let scaledSize = size.uniformlyScaled(by: actualScale)
        let ciImage = CIFilter.constantColorGenerator(inputColor: CIColor(color: color))?
            .outputImage?
            .cropped(to: CGRect(origin: .zero, size: scaledSize))
        return ciImage.map { UIImage(ciImage: $0, scale: actualScale, orientation: .up) }
    }
}
