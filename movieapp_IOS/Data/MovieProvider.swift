//
//  MovieProvider.swift
//  MovieApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import Foundation

struct MovieSearchItem: Codable {
    let title: String
    let year: String
    let poster: String
    let imdbID: String
}

struct MovieDetail: Codable {
    let title: String
    let year: String
    let plot: String?
    let runtime: String?
    let director: String?
    let genre: String?
    let country: String?
    let poster: String?
}

final class MovieProvider {

    private static let apiKey = "66b92c66" // Sustituye por tu clave válida
    private static let baseURL = "https://www.omdbapi.com/"

    static func searchMovies(query: String) async -> [MovieSearchItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty,
              let url = makeURL(params: [("s", q)]) else { return [] }

        debugPrint("[Provider] Search URL:", url.absoluteString)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse {
                debugPrint("[Provider] Search HTTP:", http.statusCode, "bytes:", data.count)
            }
            struct R: Decodable {
                struct I: Decodable {
                    let title: String
                    let year: String
                    let imdbID: String
                    let poster: String
                    enum CodingKeys: String, CodingKey {
                        case title = "Title", year = "Year", imdbID, poster = "Poster"
                    }
                }
                let response: String
                let error: String?
                let search: [I]?
                enum CodingKeys: String, CodingKey {
                    case response = "Response", error = "Error", search = "Search"
                }
            }
            let r = try JSONDecoder().decode(R.self, from: data)
            if r.response.lowercased() != "true" {
                debugPrint("[Provider] Search Error:", r.error ?? "Unknown error")
                return []
            }
            let items = r.search ?? []
            debugPrint("[Provider] Search Items:", items.count)
            return items.map { .init(title: $0.title, year: $0.year, poster: normalizeNA($0.poster) ?? "", imdbID: $0.imdbID) }
        } catch {
            debugPrint("[Provider] searchMovies error:", error)
            return []
        }
    }

    static func fetchMovieDetail(imdbID: String) async -> MovieDetail? {
        guard let url = makeURL(params: [("i", imdbID), ("plot", "full")]) else { return nil }

        debugPrint("[Provider] Detail URL:", url.absoluteString)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse {
                debugPrint("[Provider] Detail HTTP:", http.statusCode, "bytes:", data.count)
            }
            struct R: Decodable {
                let response: String
                let error: String?
                let title: String
                let year: String
                let runtime: String?
                let genre: String?
                let director: String?
                let plot: String?
                let country: String?
                let poster: String?
                enum CodingKeys: String, CodingKey {
                    case response = "Response", error = "Error", title = "Title", year = "Year",
                         runtime = "Runtime", genre = "Genre", director = "Director",
                         plot = "Plot", country = "Country", poster = "Poster"
                }
            }
            let d = try JSONDecoder().decode(R.self, from: data)
            if d.response.lowercased() != "true" {
                debugPrint("[Provider] Detail Error:", d.error ?? "Unknown error")
                return nil
            }
            return .init(title: d.title,
                         year: d.year,
                         plot: normalizeNA(d.plot),
                         runtime: normalizeNA(d.runtime),
                         director: normalizeNA(d.director),
                         genre: normalizeNA(d.genre),
                         country: normalizeNA(d.country),
                         poster: normalizeNA(d.poster))
        } catch {
            debugPrint("[Provider] fetchMovieDetail error:", error)
            return nil
        }
    }

    private static func makeURL(params: [(String, String)]) -> URL? {
        var c = URLComponents(string: baseURL)
        c?.queryItems = [URLQueryItem(name: "apikey", value: apiKey)]
        params.forEach { c?.queryItems?.append(.init(name: $0.0, value: $0.1)) }
        return c?.url
    }

    private static func normalizeNA(_ value: String?) -> String? {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return nil }
        return v.uppercased() == "N/A" ? nil : v
    }
}
