//
//  Item.swift
//  StoryPalace
//
//  Created by Yini Yin on 11/01/2025.
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
