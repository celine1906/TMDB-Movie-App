//
//  DetailViewController.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import UIKit
import YouTubeiOSPlayerHelper
import Combine

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemYellow
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, infoLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trailerPlayerView: YTPlayerView = {
        let view = YTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    private let reviewsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reviewsTableView: SelfSizingTableView = {
        let tv = SelfSizingTableView()
        tv.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tv.isScrollEnabled = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(id: Int, type: DiscoverType) {
        self.viewModel = DetailViewModel(
            id: id,
            type: type
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        viewModel.loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(trailerPlayerView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(genreLabel)
        contentView.addSubview(overviewTitleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(reviewsTitleLabel)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(reviewsTableView)
        view.addSubview(loadingIndicator)
        
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
 
        NSLayoutConstraint.activate([
            
            trailerPlayerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trailerPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailerPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trailerPlayerView.heightAnchor.constraint(equalToConstant: 220),
            
            scrollView.topAnchor.constraint(equalTo: trailerPlayerView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            taglineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taglineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingStackView.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genreLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            overviewTitleLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 16),
            overviewTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 8),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewsTitleLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            reviewsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            seeAllButton.centerYAnchor.constraint(equalTo: reviewsTitleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewsTableView.topAnchor.constraint(equalTo: reviewsTitleLabel.bottomAnchor, constant: 8),
            reviewsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reviewsTableView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor
                                                    ),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.detailDidUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviews in
                self?.updateReviews(reviews)
            }
            .store(in: &cancellables)
        
        viewModel.$trailerKey
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key in
                self?.updateTrailer(with: key)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI() {
        titleLabel.text = viewModel.displayTitle
        overviewLabel.text = viewModel.overviewText
        taglineLabel.text = viewModel.taglineText
        taglineLabel.isHidden = viewModel.taglineText?.isEmpty ?? true
        infoLabel.text = viewModel.infoText
        genreLabel.text = viewModel.genresText
    }

    
    private func updateReviews(_ reviews: [Review]) {
        let isEmpty = reviews.isEmpty
        reviewsTitleLabel.isHidden = isEmpty
        seeAllButton.isHidden = isEmpty || reviews.count <= 1
        reviewsTableView.isHidden = isEmpty
        
        reviewsTitleLabel.text = isEmpty ? "" : "Reviews (\(reviews.count))"
        
        reviewsTableView.reloadData()
    }
    
    @objc private func seeAllTapped() {
        let vc = ReviewsViewController(reviews: viewModel.reviews, movieTitle: viewModel.displayTitle ?? "")
        navigationController?.pushViewController(vc, animated: true)
    }

    
    private func updateTrailer(with key: String?) {
        guard let key else {
            trailerPlayerView.isHidden = true
            return
        }

        trailerPlayerView.isHidden = false
        trailerPlayerView.load(
            withVideoId: key,
            playerVars: [
                "playsinline": 1,
                "controls": 1,
                "autoplay": 0,
                "modestbranding": 1
            ]
        )
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(viewModel.reviews.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as? ReviewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.reviews[indexPath.row])
        return cell
    }
}
