//
//  MoviesViewController.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import UIKit
import Combine

class DiscoverViewController: UIViewController {
    
    private let viewModel = DiscoverViewModel(type: .movie)
    private var cancellables = Set<AnyCancellable>()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Movies", "TV Shows"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var searchCategoryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Movies"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        categoryButton.setTitle("All Genres ⬍", for: .normal)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.addTarget(self, action: #selector(handleCategoryTap), for: .touchUpInside)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        view.addSubview(searchBar)
        view.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: categoryButton.leadingAnchor),
            
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            categoryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        return view
    }()
    
    private let categoryButton = UIButton(type: .system)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        cv.refreshControl = refreshControl
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.load()
    }
    
    private func setupUI() {
        title = "Discover"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        view.addSubview(searchCategoryView)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorContainerView)
        
        errorContainerView.addSubview(errorLabel)
        errorContainerView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            searchCategoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchCategoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchCategoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchCategoryView.heightAnchor.constraint(equalToConstant: 56),
            
            collectionView.topAnchor.constraint(equalTo: searchCategoryView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            errorContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            
            errorLabel.topAnchor.constraint(equalTo: errorContainerView.topAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.collectionView.reloadData()
                
                if !items.isEmpty {
                    self?.errorContainerView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading && self.viewModel.items.isEmpty {
                    self.loadingIndicator.startAnimating()
                    self.errorContainerView.isHidden = true
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    if self.viewModel.items.isEmpty {
                        self.showError(error)
                    } else {
                        self.showErrorAlert(error)
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedGenre
            .receive(on: DispatchQueue.main)
            .sink { [weak self] genre in
                if let genre = genre {
                    self?.categoryButton.setTitle("\(genre.name) ⬍", for: .normal)
                } else {
                    self?.categoryButton.setTitle("All Genres ⬍", for: .normal)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: NetworkError) {
        errorLabel.text = error.message
        errorContainerView.isHidden = false
        collectionView.isHidden = true
    }
    
    private func showErrorAlert(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.load()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func segmentChanged() {
        let type: DiscoverType = segmentedControl.selectedSegmentIndex == 0 ? .movie : .tv
        viewModel.changeType(type)
    }
    
    @objc private func handleRefresh() {
        viewModel.load(refresh: true)
    }
    
    @objc private func handleRetry() {
        errorContainerView.isHidden = true
        collectionView.isHidden = false
        viewModel.load(refresh: true)
    }
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension DiscoverViewController {
    @objc private func handleCategoryTap() {
        let alert = UIAlertController(
            title: "Select Genre",
            message: "Choose a genre to filter",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "All Genres", style: .default) { [weak self] _ in
            self?.viewModel.applyFilter(genre: nil)
        })
        
        for genre in viewModel.genres {
            let isSelected = viewModel.selectedGenre?.id == genre.id
            let title = isSelected ? "✓ \(genre.name)" : genre.name
            
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.applyFilter(genre: genre)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = categoryButton
            popoverController.sourceRect = categoryButton.bounds
        }
        
        present(alert, animated: true)
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PosterCell",
            for: indexPath
        ) as? PosterCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewModel.items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 3
        let spacing: CGFloat = 10
        let inset: CGFloat = 10

        let totalSpacing = (columns - 1) * spacing + inset * 2

        let width = (collectionView.bounds.width - totalSpacing) / columns

        let height = width * 3 / 2 + 24

        return CGSize(width: floor(width), height: floor(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.items.count - 5 {
            viewModel.load()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.item]
        let detailVC = DetailViewController(
            id: item.id,
            type: segmentedControl.selectedSegmentIndex == 0 ? .movie : .tv
        )
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

