import Foundation
import XCTest

final class PluginTests: XCTestCase {
    func testPluginGeneratedSources() {
        XCTAssertEqual(
            Localizable.demoBasic,
            "A basic string"
        )

        XCTAssertEqual(
            Localizable.multiline(2),
            """
            A string that
            spans 2 lines
            """
        )
        XCTAssertEqual(
            Localizable.multiline(2),
            """
            A string that
            spans 2 lines
            """
        )

        XCTAssertEqual(
            FeatureOne.pluralExample(1),
            "1 string remaining"
        )
        XCTAssertEqual(
            FeatureOne.pluralExample(1),
            "1 string remaining"
        )

        XCTAssertEqual(
            FeatureOne.pluralExample(10),
            "10 strings remaining"
        )
        XCTAssertEqual(
            FeatureOne.pluralExample(10),
            "10 strings remaining"
        )
    }
}
