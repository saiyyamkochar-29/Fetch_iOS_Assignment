
import XCTest

final class Fetch_iOS_Assignment_2UITests: XCTestCase {

    override func setUpWithError() throws {

        let app = XCUIApplication()
        app.launch()
    }

    func testPresenceOfNavigationBarTitle() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.navigationBars["Desserts"].exists) // Check if "Desserts" navigation bar exists
    }
    
    func testNavigationToDessertDetailView() {
        let app = XCUIApplication()
        app.launch()
            
        // Assert that the navigation bar appears
        let navBar = app.navigationBars["Desserts"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 10))
            
        let cells = app.tables.cells
        if cells.count > 0 {
            let firstCell = cells.element(boundBy: 0)
            firstCell.tap()

            // Check if navigated to the DessertDetailView
            XCTAssertTrue(app.otherElements["DessertDetailView"].waitForExistence(timeout: 10))
        }
    }
}
