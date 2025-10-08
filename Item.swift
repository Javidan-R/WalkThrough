//
//  Item.swift
//  Walkthrough
//
//  Created by Abdullah on 11.08.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
