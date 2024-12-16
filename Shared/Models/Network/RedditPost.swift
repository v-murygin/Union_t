//
//  RedditPost.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

struct RedditPost: Codable {
    let title: String
    let author: String
    let createdUTC: TimeInterval
    let url: String
    let thumbnail: String?
    let numComments: Int

    private enum CodingKeys: String, CodingKey {
        case title
        case author
        case createdUTC = "created_utc"
        case url
        case thumbnail
        case numComments = "num_comments"
    }

    var createdDate: Date {
        return Date(timeIntervalSince1970: createdUTC)
    }
}
