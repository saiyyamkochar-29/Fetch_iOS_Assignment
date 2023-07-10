# Fetch iOS Assignment
iOS development take-home assignment from Fetch

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
