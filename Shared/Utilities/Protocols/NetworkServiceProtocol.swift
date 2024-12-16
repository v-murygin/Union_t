//
//  NetworkServiceProtocol.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
    
    /// Fetches data from the given URL
    func fetch<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void)
}
