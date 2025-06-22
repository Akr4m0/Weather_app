//
//  ContentView.swift
//  Weather
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State private var selectedTab = 0
    
    init() {
        // Customize Tab Bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        // Customize Tab Bar item appearance
        let itemAppearance = UITabBarItemAppearance()
        
        // Normal state (not selected)
        itemAppearance.normal.iconColor = .white.withAlphaComponent(0.7)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        
        // Selected state
        itemAppearance.selected.iconColor = .white
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Weather Tab
            mainWeatherView
                .tabItem {
                    Label {
                        Text("Weather")
                    } icon: {
                        Image(systemName: selectedTab == 0 ? "cloud.sun.fill" : "cloud.sun")
                    }
                }
                .tag(0)
            
            // Forecast Tab
            forecastView
                .tabItem {
                    Label {
                        Text("Forecast")
                    } icon: {
                        Image(systemName: selectedTab == 1 ? "calendar.circle.fill" : "calendar.circle")
                    }
                }
                .tag(1)
            
            // Map Tab
            InteractiveMapView(weatherManager: weatherManager)
                .tabItem {
                    Label {
                        Text("Map")
                    } icon: {
                        Image(systemName: selectedTab == 2 ? "map.fill" : "map")
                    }
                }
                .tag(2)
            
            // Compass Tab
            compassView
                .tabItem {
                    Label {
                        Text("Compass")
                    } icon: {
                        Image(systemName: selectedTab == 3 ? "location.north.circle.fill" : "location.north.circle")
                    }
                }
                .tag(3)
            
            // Settings Tab
            if #available(iOS 16.0, *) {
                FavouritesView()
                    .tabItem {
                        Label {
                            Text("Favourites")
                        } icon: {
                            Image(systemName: selectedTab == 4 ? "star.fill" : "star")
                        }
                    }
                    .tag(4)
            } else {
                Text("Settings available in iOS 16.0 or later")
                    .tabItem {
                        Label {
                            Text("Settings")
                        } icon: {
                            Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                        }
                    }
                    .tag(4)
            }
        }
        .tint(.white)
    }
    
    var mainWeatherView: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    WeatherView(weather: weather)
                } else {
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            } catch {
                                print("Error getting weather: \(error)")
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .background(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
    }
    
    var forecastView: some View {
        Group {
            if let location = locationManager.location {
                DetailedWeatherView(
                    weatherManager: weatherManager,
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
    }
    
    var compassView: some View {
        Group {
            if let weather = weather {
                CompassView(
                    windDirection: Double(weather.wind.deg),
                    windSpeed: weather.wind.speed
                )
            } else {
                CompassView()
            }
        }
        .background(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
