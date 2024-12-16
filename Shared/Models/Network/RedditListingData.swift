//
//  RedditListingData.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

struct RedditListingData: Codable {
    let children: [RedditPostWrapper]
    let after: String?
}
