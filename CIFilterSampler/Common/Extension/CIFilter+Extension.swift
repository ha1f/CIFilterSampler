//
//  CIFilter+Extension.swift
//  CIFilterSampler
//
//  Created by はるふ on 2018/03/09.
//  Copyright © 2018年 ha1f. All rights reserved.
//

import Foundation
import CoreImage

extension CIFilter {
    var displayName: String? {
        return self.attributes[kCIAttributeDisplayName] as? String
    }
    
    var filterName: String? {
        return self.attributes[kCIAttributeFilterName] as? String
    }
    
    var referenceDocumentationUrl: URL? {
        return self.attributes[kCIAttributeReferenceDocumentation] as? URL
    }
    
    var availableIos: String? {
        return self.attributes[kCIAttributeFilterAvailable_iOS] as? String
    }
    
    func parameterInformation(forInputKey inputKey: String) -> [String: Any] {
        return (self.attributes[inputKey] as? [String: Any]) ?? [:]
    }
    
    /// [CIConstantColorGenerator](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIConstantColorGenerator)
    ///
    /// - parameter inputColor: The color to generate. defaultValue = (1 0 0 1) <CGColorSpace 0x6040000af9c0> (kCGColorSpaceDeviceRGB).
    ///
    /// - returns: Generated CIFilter (you can get result with ["outputImage"])
    @available(iOS 5, *)
    static func constantColorGenerator(inputColor: CIColor) -> CIFilter? {
        guard let filter = CIFilter(name: "CIConstantColorGenerator") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(inputColor, forKey: kCIInputColorKey)
        return filter
    }
}
