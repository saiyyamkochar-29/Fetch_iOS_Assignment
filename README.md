# iDessertful 🍰
iDessertful is a native iOS application designed to help users explore recipes using the MealDB API. Users can browse a variety of dessert recipes sorted alphabetically, with each recipe displaying details such as meal name, instructions, and ingredients with measurements. The application utilizes two endpoints from the MealDB API to fetch the list of meals in the Dessert category and retrieve meal details by ID, enhancing the user experience in discovering and learning about different dessert recipes.

Made with 🤎 by [Saiyyam Kochar](https://github.com/saiyyamkochar-29), supported by girlfriend with a sweet-tooth.

## Features

- Fetch and display a list of desserts from the MealDB API.
- View details about a specific dessert, including the recipe, ingredients, and measurements.
- Sort desserts alphabetically.
- Asynchronously load images from the network.
- Handle errors from network requests.

## Implementation Details (View.swift)

- `ContentView`: Main view of the application that fetches and lists desserts.
- `DessertManager`: ObservableObject class that manages fetching and storing of desserts.
- `Dessert`: Codable and Identifiable struct model for a dessert.
- `DessertResponse`: Codable struct model for the response from the desserts API.
- `DessertDetailView`: View that displays details about a specific dessert.
- `Recipe`: Codable struct model for a recipe.
- `NetworkManager`: Class that manages fetching data from the API.
- `RecipeResponse`: Codable struct model for the response from the recipe API.
- `NetworkError`: Enum for possible network errors.

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+
