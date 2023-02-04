//
//  File.swift
//  
//
//  Created by Oliver Krakora on 04.02.23.
//

import UIKit

public class ProductViewController: UIViewController {

    private var versionSegmentedControl: UISegmentedControl!

    private var productsTableView: UITableView!

    private var productProvider: ProductProvider = StoreKit1ProductProvider()

    private var productRequest: Task<Void, Error>?

    public var productIdsToLoad: [String] = []

    private var loadedProductsResult: Result<[Product], Error> = .success([])

    override public func loadView() {
        view = UIView(frame: .zero)
        view.backgroundColor = .white
        versionSegmentedControl = UISegmentedControl(frame: .zero)
        versionSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        versionSegmentedControl.insertSegment(withTitle: "StoreKit1", at: 0, animated: false)
        versionSegmentedControl.insertSegment(withTitle: "StoreKit2", at: 1, animated: false)
        versionSegmentedControl.selectedSegmentIndex = 0
        versionSegmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
        view.addSubview(versionSegmentedControl)

        productsTableView = UITableView(frame: .zero, style: .plain)
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        productsTableView.dataSource = self
        view.addSubview(productsTableView)

        NSLayoutConstraint.activate([
            versionSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            versionSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view.trailingAnchor.constraint(equalTo: versionSegmentedControl.trailingAnchor),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.topAnchor.constraint(equalTo: versionSegmentedControl.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: productsTableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: productsTableView.bottomAnchor),
        ])
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        productsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        loadProducts()
    }

    @objc private func segmentedControlDidChange() {
        productRequest?.cancel()
        switch versionSegmentedControl.selectedSegmentIndex {
        case 1:
            if #available(iOS 15, *) {
                productProvider = StoreKit2ProductProvider()
            } else {
                versionSegmentedControl.selectedSegmentIndex = 0
                fallthrough
            }
        default:
            productProvider = StoreKit1ProductProvider()
        }
        loadProducts()
    }

    private func loadProducts() {
        productRequest?.cancel()
        loadedProductsResult = .success([])
        productsTableView.reloadData()
        productRequest = Task {
            do {
                self.loadedProductsResult = try await .success(productProvider.products(for: productIdsToLoad))
            } catch {
                self.loadedProductsResult = .failure(error)
            }
            productsTableView.reloadData()
        }
    }
}

extension ProductViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var cellConfig = UIListContentConfiguration.cell()

        switch loadedProductsResult {
        case .success(let products):
            cellConfig.text = products[indexPath.row].id
        case .failure(let error):
            cellConfig.text = "\(error)"
        }

        cell.contentConfiguration = cellConfig
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch loadedProductsResult {
        case .success(let products):
            return products.count
        case .failure:
            return 1
        }
    }
}

