import XCTest
@testable import Presto

class HTMLEntityTests: XCTestCase {

    func testHTMLEntityCount() {
        let entities = HTMLEntity.entities
        XCTAssertEqual(entities.count, 2028)
    }

    func testHTMLEntityName() {
        let name = HTMLEntity.forName("agrave")
        XCTAssertNotNil(name)
        XCTAssertEqual(name?.entityName, "agrave")
        XCTAssertEqual(name?.entityValue, 224)
    }

    func testEntityValue() {
        let name = HTMLEntity.forValue(224)
        XCTAssertNotNil(name)
        XCTAssertEqual(name?.entityName, "agrave")
        XCTAssertEqual(name?.entityValue, 224)
    }

    func testEntityDecimal() {
        let name = HTMLEntity.forDecimal("&#224;")
        XCTAssertNotNil(name)
        XCTAssertEqual(name?.entityName, "agrave")
        XCTAssertEqual(name?.entityValue, 224)
    }

    func testEntityHexidecimal() {
        let name = HTMLEntity.forHex("&#x000E0;")
        XCTAssertNotNil(name)
        XCTAssertEqual(name?.entityName, "agrave")
        XCTAssertEqual(name?.entityValue, 224)
    }

    func testRenderHTMLEntities() {
        let string = "\\Aacute"
        let result = string.renderHtmlEntities()
        print(result)
    }
}
