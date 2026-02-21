import Articles
import Foundation
import XCTest

@testable import NetNewsWire

@MainActor final class ArticleRendererTests: XCTestCase {

	func testRendererUsesExternalURLAsBaseWhenPermalinkMissing() {
		let articleID = UUID().uuidString
		let article = Article(accountID: UUID().uuidString,
						articleID: articleID,
						feedID: UUID().uuidString,
						uniqueID: UUID().uuidString,
						title: "Test",
						contentHTML: "<p>Body<a href=\"#fn1\">1</a></p><div id=\"fn1\">Footnote</div>",
						contentText: nil,
						markdown: nil,
						url: nil,
						externalURL: "https://moneyandmeaning.substack.com/p/the-long-dark-part-i",
						summary: nil,
						imageURL: nil,
						datePublished: nil,
						dateModified: nil,
						authors: nil,
						status: ArticleStatus(articleID: articleID, read: true, dateArrived: Date()))

		let rendering = ArticleRenderer.articleHTML(article: article, theme: .defaultTheme)
		XCTAssertEqual(rendering.baseURL, "https://moneyandmeaning.substack.com/p/the-long-dark-part-i")
	}
}
