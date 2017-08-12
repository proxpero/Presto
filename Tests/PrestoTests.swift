import XCTest
@testable import Presto

class PrestoTests: XCTestCase {

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

    func testCMarkToHtml() {
        let cmark = Cmark(markdown)
        let result = try? cmark.toHtml()
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, html)
    }

    func testCMarkRenderXML() {
        let cmark = Cmark(markdown)
        let result = try? cmark.render(.xml(options: .default))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, xml)
    }

    func testCMarkRenderHTML() {
        let cmark = Cmark(markdown)
        let result = try? cmark.render(.html(options: .default))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, html)
    }

    func testCMarkRenderMan() {
        let cmark = Cmark(markdown)
        let result = try? cmark.render(.man(options: .default, width: 0))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, man)
    }

    func testCMarkRenderCommonmark() {
        let cmark = Cmark(markdown)
        let result = try? cmark.render(.commonmark(options: .default, width: 0))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, commonmark)
    }

    func testCMarkRenderLatex() {
        let cmark = Cmark(markdown)
        let result = try? cmark.render(.latex(options: .default, width: 0))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, latex)
    }

#if os(macOS)

    func testAttributedString() {
        let result = try? Cmark(markdown).renderAttributedString()
        XCTAssertNotNil(result)
        print(result!)
    }

#endif

}
