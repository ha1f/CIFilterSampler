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
}
