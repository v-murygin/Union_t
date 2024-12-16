//
//  DIContainer.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import UIKit

class DIContainer {
    
    static let shared = DIContainer()

    private let redditService: RedditServiceProtocol

    private init() {
        redditService = RedditService()
    }

    func makeRedditViewController() -> RedditViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RedditViewController") as? RedditViewController else {
            fatalError("RedditViewController not found in Storyboard")
        }
        vc.configure(with: redditService)
        return vc
    }
}
