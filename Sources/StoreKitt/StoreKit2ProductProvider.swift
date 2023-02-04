//
//  File.swift
//  
//
//  Created by Oliver Krakora on 04.02.23.
//

import Foundation
import StoreKit

@available(iOS 15, *)
public class StoreKit2ProductProvider: ProductProvider {
    public func products(for identifiers: [String]) async throws -> [Product] {
        try await StoreKit.Product.products(for: identifiers)
    }
}
