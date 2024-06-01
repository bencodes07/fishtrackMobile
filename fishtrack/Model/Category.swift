//
//  Category.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Category: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
}

var categories: Array<Category> = [
    Category(image: "lines.measurement.horizontal", title: "Length"),
    Category(image: "scalemass", title: "Weight"),
    Category(image: "gear", title: "Test"),
    Category(image: "gear", title: "Test")
]
