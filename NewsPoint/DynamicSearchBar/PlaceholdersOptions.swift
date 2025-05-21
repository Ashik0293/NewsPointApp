//
//  PlaceholdersOptions.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//

import Foundation

public struct PlaceholdersOptions: OptionSet {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static var infinite = PlaceholdersOptions(rawValue: 1 << 0)
    public static var shuffle = PlaceholdersOptions(rawValue: 1 << 1)
}
