//
//  ApiClient.swift
//  GaryTube
//
//  Created by Tom Knighton on 01/10/2021.
//

import Foundation

enum APIError: Error {
    case networkFail
    case dataNotFound
    case codingFailure
    case invalidUrl
    case notAuthorized
    case invalidUserDetails
    case chatBan
    case feedBan
    case globalBan
    case badRequest
}

extension Encodable {
    
    func jsonEncode() -> Data? {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        encoder.dateEncodingStrategy = .formatted(formatter)
        let encoded = try? encoder.encode(self)
        return encoded
    }
}

extension Data {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> BodyType? {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ssZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            return formatter.date(from: dateString) ?? Date()
        })
        let decoded = try decoder.decode(BodyType.self, from: self)
        return decoded
        
    }
}

//extension APIResponse where Body == Data? {
//    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
//        guard let data = body else {
//            throw APIError.codingFailure
//        }
//        let decoder = JSONDecoder()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//        decoder.dateDecodingStrategy = .formatted(formatter)
//        let decoded = try decoder.decode(BodyType.self, from: data)
//        return APIResponse<BodyType>(statusCode: self.statusCode, body: decoded)
//
//    }
//}

struct ApiClient {
    
    static func perform<T: Decodable>(url: String, to type: T.Type) async -> T? {
        let data = await performNoDecoding(url: url)
        guard let data = data else { return nil }
        
        do {
            return try data.decode(to: T.self) ?? nil
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
    static func performNoDecoding(url: String) async -> Data? {
        let url = url.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: url) else {
            return nil
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.queryItems?.isEmpty == true || components?.queryItems == nil {
            components?.queryItems = [URLQueryItem(name: "app_id", value: GaryTubeConstants.apiKey), URLQueryItem(name: "app_key", value: GaryTubeConstants.appKey)]
        } else {
            components?.queryItems?.append(URLQueryItem(name: "app_id", value: GaryTubeConstants.apiKey))
            components?.queryItems?.append(URLQueryItem(name: "app_key", value: GaryTubeConstants.appKey))
        }
        
        guard let finalUrl = components?.url else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: finalUrl)
            return data
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}
