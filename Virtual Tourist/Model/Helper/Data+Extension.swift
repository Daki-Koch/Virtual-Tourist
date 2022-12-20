//
//  Data+Extension.swift
//  Virtual Tourist
//
//  Created by David Koch on 20.12.22.
//

import Foundation
import UIKit

extension Data {
    var uiImage: UIImage? { UIImage(data: self) }
    
}

