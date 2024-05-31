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

var categories = [
    Category(image: "test", title: "Test"),
    Category(image: "test", title: "Test"),
    Category(image: "test", title: "Test"),
    Category(image: "test", title: "Test")
]
