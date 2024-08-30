//
//  ApiService.swift
//  swiftuiapicalling
//
//  Created by Bhavesh Sachala on 30/08/24.
//

import Foundation

class ApiService {
    static let shared = ApiService()
    private let baseUrl = "https://reqres.in/api/"

    private func getUrl(endpoint: String) -> URL? {
        return URL(string: "\(baseUrl)\(endpoint)")
    }

    private func accessToken() -> String {
        return ""
    }

    private func headers() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken())"
        ]
    }

    private func sendRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during API call to \(request.url?.absoluteString ?? ""): \(error)")
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                if response.statusCode == 401 || response.statusCode == 403 {
                    self.handleUnauthorizedAccess()
                }
                let error = NSError(domain: "HTTPError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(response.statusCode)"])
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }

    private func handleUnauthorizedAccess() {
        print("Unauthorized access detected.")
        // Handle unauthorized access (e.g., token refresh, logout)
    }

    func get(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = getUrl(endpoint: endpoint) else { return }
        print(url);
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers()
        sendRequest(request, completion: completion)
    }

    func post(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = getUrl(endpoint: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers()
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        sendRequest(request, completion: completion)
    }

    func put(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = getUrl(endpoint: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers()
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        sendRequest(request, completion: completion)
    }

    func patch(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = getUrl(endpoint: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = headers()
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        sendRequest(request, completion: completion)
    }

    func delete(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = getUrl(endpoint: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers()
        sendRequest(request, completion: completion)
    }
}
