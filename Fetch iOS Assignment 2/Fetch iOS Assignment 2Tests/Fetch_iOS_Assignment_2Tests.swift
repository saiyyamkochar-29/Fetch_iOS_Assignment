
import XCTest
@testable import Fetch_iOS_Assignment_2

class ContentViewTests: XCTestCase {
    
    var dessertManager: DessertManager!
        var networkManager: NetworkManager!
        
    override func setUp() {
        super.setUp()
        dessertManager = DessertManager()
        networkManager = dessertManager.networkManager
    }
        
        override func tearDown() {
            networkManager = nil
            dessertManager = nil
            super.tearDown()
        }
        
        func testFetchDesserts() {
            // Given
            let expectation = self.expectation(description: "Fetching desserts from network")
            
            // When
            dessertManager.fetchDesserts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                expectation.fulfill()
            }
            
            // Then
            waitForExpectations(timeout: 10, handler: nil)
            XCTAssertFalse(self.dessertManager.desserts.isEmpty)
        }
        
        func testFetchRecipe() {
            // Given
            let expectation = self.expectation(description: "Fetching recipe from network")
            let dessert = Dessert(id: "52929", name: "TestDessert") // Replace with a valid id
            
            // When
            networkManager.fetchRecipe(for: dessert.id) { result in
                switch result {
                case .success(let recipe):
                    // Then
                    XCTAssertNotNil(recipe)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
            
            waitForExpectations(timeout: 10, handler: nil)
        }
    
    // Test to ensure desserts array is initially empty
    func testDessertsInitiallyEmpty() {
        XCTAssertTrue(dessertManager.desserts.isEmpty)
    }

    // Test to ensure desserts array is populated after fetch
    func testDessertsPopulatedAfterFetch() {
        // Given
        let expectation = self.expectation(description: "Desserts array populated")

        // When
        dessertManager.fetchDesserts()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Then
            XCTAssertFalse(self.dessertManager.desserts.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // Test to ensure valid dessert ID results in valid recipe
    func testValidDessertIDFetchesValidRecipe() {
        // Given
        let expectation = self.expectation(description: "Valid dessert ID fetches valid recipe")
        let validDessertID = "52929" // Replace with valid ID
        let dessert = Dessert(id: validDessertID, name: "TestDessert")

        // When
        dessertManager.networkManager.fetchRecipe(for: dessert.id) { result in
            switch result {
            case .success(let recipe):
                // Then
                XCTAssertNotNil(recipe)
                XCTAssertFalse(recipe.name.isEmpty)
                XCTAssertFalse(recipe.instructions.isEmpty)
                XCTAssertFalse(recipe.ingredients.isEmpty)
                XCTAssertFalse(recipe.measurements.isEmpty)
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // Test to ensure invalid dessert ID results in error
    func testInvalidDessertIDFetchesError() {
        // Given
        let expectation = self.expectation(description: "Invalid dessert ID fetches error")
        let invalidDessertID = "InvalidID"
        let dessert = Dessert(id: invalidDessertID, name: "TestDessert")

        // When
        dessertManager.networkManager.fetchRecipe(for: dessert.id) { result in
            switch result {
            case .success:
                XCTFail("Should not have been able to fetch recipe for invalid dessert ID")
            case .failure:
                // Then
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    }

