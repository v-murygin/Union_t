//
//  RedditService.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

class RedditService: RedditServiceProtocol {
    
    /// Base URL for Reddit (Austin subreddit)
    private let baseURL = "https://www.reddit.com/r/Austin/"
    
    /// Network service for fetching data
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    /// Fetches posts from Reddit API
    func fetchPosts(sort: RedditSort, after: String? = nil, limit: Int = 25, completion: @escaping (Result<RedditResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "\(sort.rawValue).json")
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        networkService.fetch(url: url, completion: completion)
    }
}
