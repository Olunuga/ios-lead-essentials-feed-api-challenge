//
//  FeedLoaderItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Mayowa Olunuga on 10/04/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation
class FeedLoaderItemMapper {
	private static var OK_200: Int { 200 }

	private struct Root: Decodable {
		let items: [ImageItem]

		var feeds: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct ImageItem: Decodable {
		let imageId: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageUrl: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageUrl = "image_url"
		}

		var feedImage: FeedImage {
			return FeedImage(id: imageId, description: imageDescription, location: imageLocation, url: imageUrl)
		}
	}

	static func map(data: Data, httpResponse: HTTPURLResponse) -> FeedLoader.Result {
		guard httpResponse.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feeds)
	}
}
