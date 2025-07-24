//
//  Collection.swift
//  aftermath
//
//  Created by Bart Reardon on 27/3/2024.
//

import Foundation

public extension Collection {
    
    /// Returns: the pretty printed JSON string or an error string if any error occur.
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "json serialization error: \(error)"
        }
    }
}
