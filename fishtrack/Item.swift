//
//  Item.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
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
