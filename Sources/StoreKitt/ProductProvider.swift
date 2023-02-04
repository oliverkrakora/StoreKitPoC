//
//  File.swift
//  
//
//  Created by Oliver Krakora on 04.02.23.
//

import Foundation
import StoreKit

public protocol Product {
    var id: String { get }
    var displayName: String { get }
}

@available(iOS 15, *)
extension StoreKit.Product: Product {}

extension StoreKit.SKProduct: Product {
    public var id: String {
        productIdentifier
    }

    public var displayName: String {
        localizedTitle
    }
}

public protocol ProductProvider {
    func products(for identifiers: [String]) async throws -> [Product]
}
