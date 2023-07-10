import SwiftUI
import Foundation

// This view lists all the fetched desserts
struct ContentView: View {
    @StateObject private var dessertManager = DessertManager()
    
    var body: some View {
        NavigationView {
            List(dessertManager.desserts.sorted(by: { $0.name < $1.name }), id: \.id) { dessert in
                NavigationLink(destination: DessertDetailView(dessert: dessert, networkManager: dessertManager.networkManager)) {
                    Text(dessert.name)
                }
            }
            .navigationBarTitle("Desserts")
            .onAppear(perform: dessertManager.fetchDesserts)
        }
    }
}

// This class fetches and stores the desserts
class DessertManager: ObservableObject {
    @Published private(set) var desserts: [Dessert] = [] // The desserts fetched from the network
    let networkManager = NetworkManager() // Network manager to fetch data
    private let lock = NSLock() // To make array updates thread-safe
    
    // Fetch desserts from the network
    func fetchDesserts() {
        networkManager.fetchDesserts { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let desserts):
                    self.updateDesserts(desserts)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Update desserts array in the threadsafe manner
    private func updateDesserts(_ newDesserts: [Dessert]) {
        lock.lock()
        desserts = newDesserts
        lock.unlock()
    }
}

// Model for Dessert data
struct Dessert: Identifiable, Codable {
    var id: String
    let name: String
    
    // Define the coding keys for JSON serialization
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
    }
}

// Model for network response
struct DessertResponse: Codable {
    let meals: [Dessert]
    
    // Define the coding keys for JSON serialization
    enum CodingKeys: String, CodingKey {
        case meals = "meals"
    }
}

// Detail view for a single dessert
struct DessertDetailView: View {
    let dessert: Dessert
    @State private var recipe: Recipe?
    private let networkManager: NetworkManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let recipe = recipe {
                    Text(recipe.name)
                        .font(.title)
                        .underline()
                        .multilineTextAlignment(.center)
                        .padding([.top, .horizontal])
                    
                    if let imageURL = URL(string: recipe.thumbnailURL) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 400)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 400)
                                .opacity(0.4)
                        }
                    }
                    
                    Text("Ingredients/Measurements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .underline()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            if !recipe.ingredients[index].isEmpty {
                                Text("\(recipe.ingredients[index]) : \(recipe.measurements[index])")
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .underline()
                    
                    Text(recipe.instructions)
                        .font(.body)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    
                } else {
                    ProgressView()
                }
            }
            .onAppear(perform: fetchRecipe)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Initialize the view with dessert and network manager
    init(dessert: Dessert, networkManager: NetworkManager) {
        self.dessert = dessert
        self.networkManager = networkManager
    }    
    // Fetch recipe for the dessert
    func fetchRecipe() {
        networkManager.fetchRecipe(for: dessert.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recipe):
                    self.recipe = recipe
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// Model for a Recipe
struct Recipe: Codable {
    let name: String
    let instructions: String
    let ingredients: [String]
    let measurements: [String]
    let thumbnailURL: String
}


// This class manages all network related tasks
class NetworkManager {
    // Fetch desserts from the network
    func fetchDesserts(completion: @escaping (Result<[Dessert], Error>) -> Void) {
        // Ensure URL is valid
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create a data task
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            // Ensure data is present
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            // Attempt to decode the data
            do {
                let response = try JSONDecoder().decode(DessertResponse.self, from: data)
                completion(.success(response.meals))
            } catch {
                completion(.failure(error))
            }
        }.resume() // Start the data task
    }
    
    // Fetch recipe for a dessert ID
    func fetchRecipe(for dessertId: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        // Ensure URL is valid
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(dessertId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create a data task
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure data is present
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Attempt to decode the data
            do {
                let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
                if let recipe = response.meals?.first?.recipe {
                    completion(.success(recipe))
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
               completion(.failure(error))
            }
        }.resume() // Start the data task
    }
}

// Model for the response received when fetching a recipe
struct RecipeResponse: Codable {
    let meals: [Meal]?
    
    struct Meal: Codable {
        let strMeal: String
       let strInstructions: String
        let strIngredient1: String?
        let strIngredient2: String?
        let strIngredient3: String?
        let strIngredient4: String?
        let strIngredient5: String?
        let strIngredient6: String?
        let strIngredient7: String?
        let strIngredient8: String?
        let strIngredient9: String?
        let strIngredient10: String?
        let strIngredient11: String?
        let strIngredient12: String?
        let strIngredient13: String?
        let strIngredient14: String?
        let strIngredient15: String?
        let strIngredient16: String?
        let strIngredient17: String?
        let strIngredient18: String?
        let strIngredient19: String?
        let strIngredient20: String?
        let strMeasure1: String?
        let strMeasure2: String?
        let strMeasure3: String?
        let strMeasure4: String?
        let strMeasure5: String?
        let strMeasure6: String?
        let strMeasure7: String?
        let strMeasure8: String?
        let strMeasure9: String?
        let strMeasure10: String?
        let strMeasure11: String?
        let strMeasure12: String?
        let strMeasure13: String?
        let strMeasure14: String?
        let strMeasure15: String?
        let strMeasure16: String?
        let strMeasure17: String?
        let strMeasure18: String?
        let strMeasure19: String?
        let strMeasure20: String?
        let strMealThumb: String
        
        // Convert Meal to Recipe object
        var recipe: Recipe {
            let ingredients = [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
                strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20]
                .compactMap { $0 }
            
            let measurements = [strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20]
                .compactMap { $0 }
            
            return Recipe(name: strMeal, instructions: strInstructions, ingredients: ingredients, measurements: measurements, thumbnailURL: strMealThumb)
        }
    }
}

// Enumeration for possible network errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
