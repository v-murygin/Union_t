//
//  RedditViewController.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import UIKit
import SafariServices

class RedditViewController: UIViewController{
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Elements
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private let sortSegmentedControl = UISegmentedControl(items: ["Top", "New", "Hot"])
    
    // MARK: - Properties
    private var afterToken: String? = nil
    private var isFetching: Bool = false
    private var hasMoreData: Bool = true
    private var redditService: RedditServiceProtocol?
    private var articles: [RedditPost] = []
    private var filteredArticles: [RedditPost] = []
    private var selectedSort: RedditSort = .top
    private var isSearching: Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }
   
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "/r/Austin"
        setupTableView()
        setupActivityIndicator()
        setupSearchController()
        setupSegmentedControl()
        fetchArticles(isRefreshing: false)
    }
    
    // MARK: - Setup
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
    }
    
    private func setupSegmentedControl() {
        sortSegmentedControl.selectedSegmentIndex = 0
        sortSegmentedControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        navigationItem.titleView = sortSegmentedControl
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RedditCell.nib(), forCellReuseIdentifier: RedditCell.identifier)
        errorLabel.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Articles"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - User Actions
    @objc private func sortChanged() {
        selectedSort = RedditSort(rawValue: sortSegmentedControl.titleForSegment(at: sortSegmentedControl.selectedSegmentIndex)!.lowercased())!
        afterToken = nil
        hasMoreData = true
        fetchArticles(isSegmentChange: true)
    }
    
    @objc private func refreshArticles() {
        afterToken = nil
        articles.removeAll()
        tableView.reloadData()
        hasMoreData = true
        fetchArticles(isRefreshing: true)
    }
    
    // MARK: - Network
    /// Fetches articles from the Reddit API
    private func fetchArticles(isRefreshing: Bool = false, isSegmentChange: Bool = false) {
        guard let networkManager = redditService, hasMoreData, !isFetching else { return }
        
        isFetching = true

        if !isRefreshing && isSegmentChange {
            activityIndicator.startAnimating()
            tableView.isHidden = true
        }
        
        networkManager.fetchPosts(sort: selectedSort, after: afterToken, limit: 25) { [weak self] (result: Result<RedditResponse, Error>) in
            guard let self = self else { return }
            self.isFetching = false
            
            DispatchQueue.main.async {
                if !isRefreshing && isSegmentChange {
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                }
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let redditResponse):
                    if redditResponse.data.after == nil {
                        self.hasMoreData = false
                    } else {
                        self.afterToken = redditResponse.data.after
                    }
                    
      
                    if isSegmentChange || isRefreshing {
                        self.articles = redditResponse.data.children.map { $0.data }
                    } else {
                        self.articles.append(contentsOf: redditResponse.data.children.map { $0.data })
                    }
                    self.errorLabel.isHidden = true
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.errorLabel.text = "Failed to load articles. Please try again later."
                    self.errorLabel.isHidden = false
                    self.tableView.isHidden = true
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    /// Presents an action sheet for the user to choose how to open the article.
    private func presentOpenOptions(for url: URL) {
        let alertController = UIAlertController(
            title: "Open Article",
            message: "How would you like to open this article?",
            preferredStyle: .actionSheet
        )
        
        let openInAppAction = UIAlertAction(title: "Open in App", style: .default) { [weak self] _ in
            let safariVC = SFSafariViewController(url: url)
            self?.present(safariVC, animated: true)
        }
        
        let openInBrowserAction = UIAlertAction(title: "Open in Browser", style: .default) { _ in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(openInAppAction)
        alertController.addAction(openInBrowserAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    /// Injects the RedditService dependency into the view controller.
    func configure(with redditService: RedditServiceProtocol) {
        self.redditService = redditService
    }
}

extension RedditViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredArticles = []
            tableView.reloadData()
            return
        }
        
        filteredArticles = articles.filter { $0.title.lowercased().contains(searchText) }
        tableView.reloadData()
    }
}

extension RedditViewController: UITableViewDataSource, UITableViewDelegate  {
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredArticles.count : articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RedditCell.identifier, for: indexPath) as! RedditCell
        let article = isSearching ? filteredArticles[indexPath.row] : articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = isSearching ? filteredArticles[indexPath.row] : articles[indexPath.row]
        guard let url = URL(string: article.url) else {
            print("Invalid URL: \(article.url)")
            return
        }
        presentOpenOptions(for: url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > contentHeight - scrollViewHeight - 100 {
            fetchArticles()
        }
    }
}
