//
//  MovieModels.swift
//  MovieApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import Foundation

struct OMDBMovie: Codable {
    let title: String
    let year: String
    let runtime: String?
    let genre: String?
    let director: String?
    let actors: String?
    let plot: String?
    let country: String?
    let poster: String?
    let imdbRating: String?
    let imdbID: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case actors = "Actors"
        case plot = "Plot"
        case country = "Country"
        case poster = "Poster"
        case imdbRating
        case imdbID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Requeridos
        self.title = try container.decode(String.self, forKey: .title)
        self.year = try container.decode(String.self, forKey: .year)
        self.imdbID = try container.decode(String.self, forKey: .imdbID)

        // Helper para normalizar "N/A" o vacío a nil
        func normalize(_ value: String?) -> String? {
            guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return nil }
            if v.uppercased() == "N/A" { return nil }
            return v
        }

        self.runtime = normalize(try container.decodeIfPresent(String.self, forKey: .runtime))
        self.genre = normalize(try container.decodeIfPresent(String.self, forKey: .genre))
        self.director = normalize(try container.decodeIfPresent(String.self, forKey: .director))
        self.actors = normalize(try container.decodeIfPresent(String.self, forKey: .actors))
        self.plot = normalize(try container.decodeIfPresent(String.self, forKey: .plot))
        self.country = normalize(try container.decodeIfPresent(String.self, forKey: .country))
        self.poster = normalize(try container.decodeIfPresent(String.self, forKey: .poster))
        self.imdbRating = normalize(try container.decodeIfPresent(String.self, forKey: .imdbRating))
    }
}
