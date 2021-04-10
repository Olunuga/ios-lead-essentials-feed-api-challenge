//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, httpResponse)):
				completion(FeedLoaderItemMapper.map(data: data, httpResponse: httpResponse))
			}
		}
	}
}

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
