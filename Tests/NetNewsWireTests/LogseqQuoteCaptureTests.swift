//
//  LogseqQuoteCaptureTests.swift
//  NetNewsWire
//
//  Created by Shishir Aravindan on 6/17/26.
//  Copyright © 2026 Ranchero Software. All rights reserved.
//

import XCTest

@testable import NetNewsWire

final class LogseqQuoteCaptureTests: XCTestCase {

	func testMarkdownWithAuthorAndFeed() {
		let markdown = LogseqQuoteCapture.markdown(selectedText: "  Hello world  ", author: "Jane Doe", feedName: "The Verge", title: "Big News", link: "https://example.com/a")
		XCTAssertEqual(markdown, "#+BEGIN_QUOTE\nHello world\n\n— _Jane Doe (The Verge)_ in [Big News](https://example.com/a)\n#+END_QUOTE")
	}

	func testMarkdownAuthorWithoutFeed() {
		let markdown = LogseqQuoteCapture.markdown(selectedText: "Quote", author: "Jane Doe", feedName: nil, title: "Big News", link: "https://example.com/a")
		XCTAssertEqual(markdown, "#+BEGIN_QUOTE\nQuote\n\n— _Jane Doe_ in [Big News](https://example.com/a)\n#+END_QUOTE")
	}

	func testMarkdownDropsAuthorSegmentWhenAuthorMissing() {
		let markdown = LogseqQuoteCapture.markdown(selectedText: "Quote", author: nil, feedName: "The Verge", title: "Big News", link: "https://example.com/a")
		XCTAssertEqual(markdown, "#+BEGIN_QUOTE\nQuote\n\n— [Big News](https://example.com/a)\n#+END_QUOTE")
	}

	func testMarkdownNoAttributionWhenNothingToCite() {
		let markdown = LogseqQuoteCapture.markdown(selectedText: "Quote", author: nil, feedName: nil, title: nil, link: nil)
		XCTAssertEqual(markdown, "#+BEGIN_QUOTE\nQuote\n#+END_QUOTE")
	}

	func testCaptureURLTargetsTodayAndEncodesDelimiters() throws {
		let url = try XCTUnwrap(LogseqQuoteCapture.captureURL(selectedText: "Hello & goodbye", author: "Jane Doe", feedName: "The Verge", title: "Big News", link: "https://example.com/a"))
		let string = url.absoluteString
		XCTAssertTrue(string.hasPrefix("logseq://x-callback-url/quickCapture?page=TODAY&append=true&content="))
		XCTAssertTrue(string.contains("%26")) // the ampersand inside the selection is encoded
		XCTAssertFalse(string.contains("Hello & goodbye"))
	}

	func testCaptureURLNilForEmptySelection() {
		XCTAssertNil(LogseqQuoteCapture.captureURL(selectedText: "   \n  ", author: "Jane Doe", feedName: "The Verge", title: "Big News", link: "https://example.com/a"))
	}
}
