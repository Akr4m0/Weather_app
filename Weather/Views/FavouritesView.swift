//
//  FavouritesView.swift
//  Weather
//

import SwiftUI

struct FavouritesView: View {
    @StateObject private var viewModel = FavouritesViewModel()
    @State private var showingAddLocation = false
    @State private var selectedLocation: SavedLocation?
    let weatherManager = WeatherManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Text("Favourites")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingAddLocation = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    // Cities Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(viewModel.savedLocations) { location in
                                CityCard(location: location) {
                                    selectedLocation = location
                                } onDelete: {
                                    withAnimation {
                                        viewModel.removeLocation(location)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView(viewModel: viewModel)
            }
            .sheet(item: $selectedLocation) { location in
                NavigationView {
                    LocationWeatherView(
                        location: location,
                        weatherManager: weatherManager
                    )
                }
            }
        }
    }
}

struct CityCard: View {
    let location: SavedLocation
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Content
                VStack {
                    // Delete button
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                        }
                    }
                    
                    // City Name
                    Text(location.name)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // View Weather Text
                    Text("View Weather")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 10)
                }
            }
            .frame(height: 120)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FavouritesViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Search city...", text: $searchText)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .autocapitalization(.none)
                                .onSubmit {
                                    viewModel.performSearch(searchText)
                                }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding()
                    
                    // Loading Indicator
                    if viewModel.isSearching {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    }
                    
                    // Search Results
                    if let searchResults = viewModel.searchResults {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(searchResults, id: \.name) { result in
                                    Button(action: {
                                        viewModel.addLocation(
                                            name: result.name,
                                            latitude: result.latitude,
                                            longitude: result.longitude
                                        )
                                        dismiss()
                                    }) {
                                        HStack {
                                            Text(result.name)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
