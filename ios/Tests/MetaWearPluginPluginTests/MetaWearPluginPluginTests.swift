import XCTest
@testable import MetaWearPluginPlugin

class MetaWearPluginTests: XCTestCase {
    func testMetaWearPluginInitialization() {
        // Test that the plugin can be initialized
        let implementation = MetaWearPlugin()
        XCTAssertNotNil(implementation)
    }
    
    func testUseSensorDataClassSetting() {
        // Test the setUseSensorDataClass method
        let implementation = MetaWearPlugin()
        implementation.setUseSensorDataClass(true)
        // Note: We can't directly test the private property, but we can verify the method doesn't crash
        XCTAssertNotNil(implementation)
    }
}
