//
//  Webservice.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidData
    case decodingError
}

class Webservice {
    
    // 1. First way to convert from closure style to async/await style
    func fetchSources(url: URL?) async throws -> [NewsSource] {
        
        guard let url = url else {
            return []
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let newsSourceResponse = try? JSONDecoder().decode(NewsSourceResponse.self, from: data)
        
        return newsSourceResponse?.sources ?? []
    }
    
    //    func fetchSources(url: URL?, completion: @escaping (Result<[NewsSource], NetworkError>) -> Void) {
    //
    //        guard let url = url else {
    //            completion(.failure(.badUrl))
    //            return
    //        }
    //
    //        URLSession.shared.dataTask(with: url) { data, _, error in
    //
    //            guard let data = data, error == nil else {
    //                completion(.failure(.invalidData))
    //                return
    //            }
    //
    //            let newsSourceResponse = try? JSONDecoder().decode(NewsSourceResponse.self, from: data)
    //            completion(.success(newsSourceResponse?.sources ?? []))
    //
    //        }.resume()
    //
    //    }
    
    private func fetchNews(by sourceId: String, url: URL?, completion: @escaping (Result<[NewsArticle], NetworkError>) -> Void) {
        
        guard let url = url else {
            completion(.failure(.badUrl))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            
            let newsArticleResponse = try? JSONDecoder().decode(NewsArticleResponse.self, from: data)
            completion(.success(newsArticleResponse?.articles ?? []))
            
        }.resume()
    }
    
    // 2. Assume that we don't have any access to fetchNews, we need another approach to convert
    
    func fetchNewsAsync(sourceId: String, url: URL?) async throws -> [NewsArticle]{
        
        try await withCheckedThrowingContinuation { continuation in
            fetchNews(by: sourceId, url: url) { result in
                switch result {
                case .success(let newsArticles):
                    continuation.resume(returning: newsArticles)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
