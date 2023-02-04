//
//  File.swift
//  
//
//  Created by Oliver Krakora on 04.02.23.
//

import Foundation
import StoreKit

private struct ProductRequest: Hashable {
    let identifiers: Set<String>
    let request: SKProductsRequest

    static func ==(_ lhs: ProductRequest, _ rhs: ProductRequest) -> Bool {
        lhs.identifiers == rhs.identifiers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifiers)
    }
}

public class StoreKit1ProductProvider: NSObject, ProductProvider {

    private var activeRequests: [SKProductsRequest: CheckedContinuation<SKProductsResponse, Error>] = [:]

    public func products(for identifiers: [String]) async throws -> [Product] {
        let response = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SKProductsResponse, Error>) in
            let request = SKProductsRequest(productIdentifiers: Set(identifiers))
            request.delegate = self
            activeRequests[request] = continuation
            request.start()
        }

        return response.products
    }
}

extension StoreKit1ProductProvider: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let continuation = activeRequests[request]
        continuation?.resume(with: .success(response))
        activeRequests[request] = nil
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        let request = request as! SKProductsRequest
        let continuation = activeRequests[request]
        continuation?.resume(with: .failure(error))
        activeRequests[request] = nil
    }
}
