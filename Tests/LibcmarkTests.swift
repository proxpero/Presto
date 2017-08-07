import XCTest
import libcmark

class LibcmarkTests: XCTestCase {

    let markdown = "This is *my* html."
    let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE document SYSTEM "CommonMark.dtd">
        <document xmlns="http://commonmark.org/xml/1.0">
          <paragraph>
            <text>This is </text>
            <emph>
              <text>my</text>
            </emph>
            <text> html.</text>
          </paragraph>
        </document>\n
        """
    let html = "<p>This is <em>my</em> html.</p>\n"
    let man = ".PP\nThis is \\f[I]my\\f[] html.\n"
    let commonmark = "This is *my* html.\n"
    let latex = "This is \\emph{my} html.\n"

    func testCMarkVersion() {
        let version = CMARK_VERSION_STRING
            .components(separatedBy: ".")
            .flatMap { Int($0) }
        XCTAssertTrue(version[0] >= 0)
        XCTAssertTrue(version[1] >= 25)
        XCTAssertTrue(version[2] >= 2)
    }

    func testCMarkToHTML() {
        markdown.withCString { body in
            guard let buffer = cmark_markdown_to_html(body, Int(strlen(body)), 0) else { XCTFail(); return }
            defer { free(buffer) }
            let result = String(validatingUTF8: buffer)
            XCTAssertEqual(result, html)
        }
    }

    func testCMarkAST() {
        let ast = self.ast(with: markdown)
        XCTAssertNotNil(ast)
    }

    private func ast(with value: String) -> UnsafeMutablePointer<cmark_node>? {
        var ast: UnsafeMutablePointer<cmark_node>?
        value.withCString {
            ast = cmark_parse_document($0, Int(strlen($0)), 0)
        }
        return ast
    }

    func testCMarkRenderHtml() {
        guard let ast = self.ast(with: markdown) else { XCTFail(); fatalError() }
        guard let buffer = cmark_render_html(ast, 0) else { XCTFail(); fatalError() }
        defer { free(buffer); buffer.deinitialize() }
        let result = String(validatingUTF8: buffer)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, html)
    }

    func testCMarkRenderXml() {
        guard let ast = self.ast(with: markdown) else { XCTFail(); fatalError() }
        defer { cmark_node_free(ast); ast.deinitialize() }
        guard let buffer = libcmark.cmark_render_xml(ast, 0) else { XCTFail(); fatalError() }
        defer { free(buffer); buffer.deinitialize() }
        let result = String(validatingUTF8: buffer)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, xml)
    }

    func testCMarkRenderLatex() {
        guard let ast = self.ast(with: markdown) else { XCTFail(); fatalError() }
        defer { cmark_node_free(ast) }
        guard let buffer = libcmark.cmark_render_latex(ast, 0, 0) else { XCTFail(); fatalError() }
        defer { free(buffer) }
        let result = String(validatingUTF8: buffer)
        XCTAssertNotNil(result)
        print(result!)
        XCTAssertEqual(result!, latex)
    }

    func testCMarkRenderMan() {
        guard let ast = self.ast(with: markdown) else { XCTFail(); fatalError() }
        defer { cmark_node_free(ast) }
        guard let buffer = cmark_render_man(ast, 0, 0) else { XCTFail(); fatalError() }
        defer { free(buffer) }
        let result = String(validatingUTF8: buffer)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, man)
    }

    func testCMarkRenderCommonMark() {
        guard let ast = self.ast(with: markdown) else { XCTFail(); fatalError() }
        defer { cmark_node_free(ast) }
        guard let buffer = cmark_render_commonmark(ast, 0, 0) else { XCTFail(); fatalError() }
        defer { free(buffer) }
        let result = String(validatingUTF8: buffer)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, commonmark)
    }

}
