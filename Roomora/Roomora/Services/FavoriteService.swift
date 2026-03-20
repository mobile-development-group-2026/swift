//
//  FavoriteService.swift
//  Roomora
//
//  Created by Samuel Ortiz Prada on 20/03/26.
//

import Foundation
import Combine

final class FavoritesService {
    static let shared = FavoritesService()
    private let key = "favorite_listing_ids"

    private init() {}

    func getFavoriteIds() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func isFavorite(listingId: String) -> Bool {
        getFavoriteIds().contains(listingId)
    }

    func toggleFavorite(listingId: String) {
        var ids = getFavoriteIds()
        if let index = ids.firstIndex(of: listingId) {
            ids.remove(at: index)
        } else {
            ids.append(listingId)
        }
        UserDefaults.standard.set(ids, forKey: key)
    }
}
