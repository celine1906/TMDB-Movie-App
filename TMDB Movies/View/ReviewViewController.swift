//
//  ReviewViewController.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 22/01/26.
//

import UIKit

class ReviewsViewController: UIViewController {
    private let reviews: [Review]
    private let movieTitle: String
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tv.separatorStyle = .none
        tv.backgroundColor = .systemBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(reviews: [Review], movieTitle: String) {
        self.reviews = reviews
        self.movieTitle = movieTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Reviews"
        navigationItem.prompt = "\(movieTitle)"
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as? ReviewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: reviews[indexPath.row])
        return cell
    }
}

