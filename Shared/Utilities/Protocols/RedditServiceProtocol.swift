//
//  RedditServiceProtocol.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

protocol RedditServiceProtocol {
    
    /// Fetches posts from Reddit
    func fetchPosts(sort: RedditSort, after: String?, limit: Int, completion: @escaping (Result<RedditResponse, Error>) -> Void)
}
