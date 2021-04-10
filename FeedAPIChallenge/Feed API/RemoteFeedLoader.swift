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
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, httpResponse)):
				guard httpResponse.statusCode == 200, let _ = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
			}
		}
	}
}

struct Root: Decodable {
	let items: [ImageItem]
}

struct ImageItem: Decodable {
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
}
