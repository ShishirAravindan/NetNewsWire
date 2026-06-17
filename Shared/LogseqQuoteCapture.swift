//
//  LogseqQuoteCapture.swift
//  NetNewsWire
//
//  Created by Shishir Aravindan on 6/17/26.
//  Copyright © 2026 Ranchero Software. All rights reserved.
//

import Foundation

/// Builds the markdown quote block and the `logseq://` quick-capture URL used to
/// append a highlighted quote to the current day’s journal entry in Logseq.
enum LogseqQuoteCapture {

	/// The markdown quote block for a selection, in the form:
	///
	///     #+BEGIN_QUOTE
	///     {selection}
	///
	///     — _{author} ({feed})_ in [{title}]({link})
	///     #+END_QUOTE
	static func markdown(selectedText: String, author: String?, feedName: String?, title: String?, link: String?) -> String {
		let quote = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)

		guard let attribution = attributionLine(author: author, feedName: feedName, title: title, link: link) else {
			return "#+BEGIN_QUOTE\n\(quote)\n#+END_QUOTE"
		}
		return "#+BEGIN_QUOTE\n\(quote)\n\n\(attribution)\n#+END_QUOTE"
	}

	/// The Logseq quick-capture URL that appends the quote to today’s journal.
	/// Returns nil when the selection is empty or the content can’t be encoded.
	static func captureURL(selectedText: String, author: String?, feedName: String?, title: String?, link: String?) -> URL? {
		guard !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return nil
		}

		let content = markdown(selectedText: selectedText, author: author, feedName: feedName, title: title, link: link)

		// Percent-encode for use as a query value: drop the characters that would
		// otherwise be read as query/fragment delimiters by the URL scheme parser.
		var allowed = CharacterSet.urlQueryAllowed
		allowed.remove(charactersIn: "&=+?#")
		guard let encoded = content.addingPercentEncoding(withAllowedCharacters: allowed) else {
			return nil
		}

		return URL(string: "logseq://x-callback-url/quickCapture?page=TODAY&append=true&content=\(encoded)")
	}
}

private extension LogseqQuoteCapture {

	/// The “— _author (feed)_ in [title](link)” line, or nil when there’s nothing to attribute.
	static func attributionLine(author: String?, feedName: String?, title: String?, link: String?) -> String? {
		let source = sourceLink(title: title, link: link)

		guard let byline = byline(author: author, feedName: feedName) else {
			// No author: keep the source link so the quote stays sourced. Drop the
			// whole line only when there’s nothing to cite at all.
			guard let source else {
				return nil
			}
			return "— \(source)"
		}

		guard let source else {
			return "— _\(byline)_"
		}
		return "— _\(byline)_ in \(source)"
	}

	static func byline(author: String?, feedName: String?) -> String? {
		guard let author, !author.isEmpty else {
			return nil
		}
		guard let feedName, !feedName.isEmpty else {
			return author
		}
		return "\(author) (\(feedName))"
	}

	static func sourceLink(title: String?, link: String?) -> String? {
		guard let title, !title.isEmpty, let link, !link.isEmpty else {
			return nil
		}
		return "[\(title)](\(link))"
	}
}
