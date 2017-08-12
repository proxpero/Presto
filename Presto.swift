import Foundation

#if os(macOS)
    import AppKit
    typealias Color = NSColor
    let fixedWidth = NSFont.userFixedPitchFont(ofSize: 12)!
#else
    import UIKit
    typealias Color = UIColor
    let fixedWidth = UIFont.systemFont(ofSize: 12)
#endif

extension String {

    public var html: String {

        var result = self
        result = result.renderHtmlEntities()
        let cmark = Cmark(result)
        do {
            result = try cmark.renderHtml()
        } catch {
            fatalError()
        }
        return result
    }

    public var attributedString: NSAttributedString {
        let result = NSMutableAttributedString.init(string: self)
        self.enumerateSubstrings(in: self.startIndex..<self.endIndex,
                                 options: .byComposedCharacterSequences) { (substring, range, _, _) in
            guard let substring = substring, substring == "\\" else { return }
            let next = self[range.lowerBound...]
            for entity in HTMLEntity.entities.map({ $0.tex }) {
                if next.hasPrefix(entity) {
                    let partialRange = Range.init(uncheckedBounds: (range.lowerBound, self.endIndex))
                    // swiftlint:disable next line_length
                    guard let found = self.range(of: entity, options: [.literal], range: partialRange, locale: nil) else { continue }
                    let nsrange = NSRange(found, in: self)
                    result.addAttribute(.font, value: fixedWidth, range: nsrange)
                    result.addAttribute(.foregroundColor, value: Color.red, range: nsrange)
                }
            }
        }

        return result
    }
}
