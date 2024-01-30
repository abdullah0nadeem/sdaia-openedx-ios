//
//  NafathUserRegisteration.swift
//  edX
//
//  Created by AbdullahNadeem on 29/12/2023.
//  Copyright © 2023 edX. All rights reserved.
//

import Foundation

public class NafathUserRegisteration: NSObject {
    @objc public var successMessage: String?
    @objc public var error: String?
    
    @objc public init?(dict: NSDictionary?) {
        self.successMessage = dict?["successMessage"] as? String
        self.error = dict?["error"] as? String
    }
}
