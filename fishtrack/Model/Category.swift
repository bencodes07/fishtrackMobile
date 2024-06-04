//
//  Category.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Category: Identifiable {
    var id: String = UUID().uuidString
    let title: String
    let image: String
}

let categories = [
    Category(title: "All", image: "square.grid.2x2"),
    Category(title: "Weight", image: "scalemass"),
    Category(title: "Length", image: "ruler")
]
