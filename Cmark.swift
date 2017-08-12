import Foundation
import libcmark

public struct Cmark {

    public enum CmarkError: Error {
        case parsingError
        case renderingError
    }

    /// See `## Options` in the cmark.h file
    /// https://github.com/commonmark/cmark/blob/5c2f3341e3c129aeb27f70fe6ca9ed0fea8f2383/src/cmark.h#L531
    public struct Options: OptionSet {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Default options.
        public static let `default` = Options(rawValue: 0)

        // Options affecting rendering.

        /// Include a `data-sourcepos` attribute on all block elements.
        public static let sourcePos = Options(rawValue: 1 << 1)

        /// Render `softbreak` elements as hard line breaks.
        public static let hardBreaks = Options(rawValue: 1 << 2)

        /// Suppress raw HTML and unsafe links (`javascript:`, `vbscript:`,
        /// `file:`, and `data:`, except for `image/png`, `image/gif`,
        /// `image/jpeg`, or `image/webp` mime types).  Raw HTML is replaced
        /// by a placeholder HTML comment. Unsafe links are replaced by
        /// empty strings.
        public static let safe = Options(rawValue: 1 << 3)

        // Options affecting parsing.

        /// Normalize tree by consolidating adjacent text nodes.
        public static let normalize = Options(rawValue: 1 << 8)

        /// Validate UTF-8 in the input before parsing, replacing illegal
        /// sequences with the replacement character U+FFFD.
        public static let validateUTF8 = Options(rawValue: 1 << 9)

        /// Convert straight quotes to curly, --- to em dashes, -- to en dashes.
        public static let smart = Options(rawValue: 1 << 10)
    }

    private let value: String

    public init(_ string: String) {
        self.value = string
    }

    public func renderHTMLEntities() -> Cmark {
        let newValue = self.value.renderHtmlEntities()
        return Cmark(newValue)
    }

    public func toHtml(options: Options = .default) throws -> String {
        var result: String?
        try value.withCString {
            guard let buffer = cmark_markdown_to_html($0, Int(strlen($0)), options.rawValue) else {
                throw CmarkError.parsingError
            }
            defer { free(buffer) }
            result = String(validatingUTF8: buffer)
        }
        if result == nil { throw CmarkError.parsingError }
        return result!
    }

    private func ast(options: Options = .default) -> UnsafeMutablePointer<cmark_node>? {
        var ast: UnsafeMutablePointer<cmark_node>?
        value.withCString {
            ast = cmark_parse_document($0, Int(strlen($0)), options.rawValue)
        }
        return ast
    }

    public enum OutputType {
        case xml(options: Options)
        case html(options: Options)
        case man(options: Options, width: Int32)
        case commonmark(options: Options, width: Int32)
        case latex(options: Options, width: Int32)

        var options: Options {
            switch self {
            case .xml(let options):
                return options
            case .html(let options):
                return options
            case .man(let options, _):
                return options
            case .commonmark(let options, _):
                return options
            case .latex(let options, _):
                return options
            }
        }

        func buffer(with ast: UnsafeMutablePointer<cmark_node>) throws -> UnsafeMutablePointer<Int8> {
            let buffer: UnsafeMutablePointer<Int8>?
            switch self {
            case .xml(let options):
                buffer = cmark_render_xml(ast, options.rawValue)
            case .html(let options):
                buffer = cmark_render_html(ast, options.rawValue)
            case .man(let options, let width):
                buffer = cmark_render_man(ast, options.rawValue, width)
            case .commonmark(let options, let width):
                buffer = cmark_render_commonmark(ast, options.rawValue, width)
            case .latex(let options, let width):
                buffer = cmark_render_latex(ast, options.rawValue, width)
            }
            guard buffer != nil else { throw CmarkError.renderingError }
            return buffer!
        }
    }

    public func render(_ outputType: OutputType) throws -> String {
        guard let ast = self.ast(options: outputType.options) else { throw CmarkError.parsingError }
        defer { cmark_node_free(ast); ast.deinitialize() }
        let buffer = try outputType.buffer(with: ast)
        defer { free(buffer); buffer.deinitialize() }
        guard let result = String(validatingUTF8: buffer) else { throw CmarkError.parsingError }
        return result
    }

    public func renderXml(options: Options = .default) throws -> String {
        return try render(.xml(options: options))
    }

    public func renderHtml(options: Options = .default) throws -> String {
        return try render(.html(options: options))
    }

    public func renderMan(options: Options = .default, width: Int32 = 0) throws -> String {
        return try render(.man(options: options, width: width))
    }

    public func renderCommonmark(options: Options = .default, width: Int32 = 0) throws -> String {
        return try render(.commonmark(options: options, width: width))
    }

    public func renderLatex(options: Options = .default, width: Int32 = 0) throws -> String {
        return try render(.latex(options: options, width: width))
    }
}

#if os(macOS)
    import AppKit
    extension Cmark {
        public func renderAttributedString(options: Options = .default) throws -> NSAttributedString {
            let cmark = self.renderHTMLEntities()
            let html = try cmark.renderHtml(options: options)
            let data = html.data(using: .utf8)!
            let result = NSAttributedString(html: data, options: [:], documentAttributes: nil)!
            return result
        }
    }
#endif
