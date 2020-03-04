import XCTest
@testable import UIProgressRing

final class UIProgressRingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UIProgressRing().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
