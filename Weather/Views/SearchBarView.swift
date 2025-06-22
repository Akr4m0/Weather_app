//
//  SearchBarView.swift
//  Weather
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    let isSearching: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("Search location...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit(onSubmit)
                }
                .padding(10)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                
                if !searchText.isEmpty {
                    Button(action: onSubmit) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, 8)
            }
        }
    }
}

// Preview
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue // Background for preview
                .ignoresSafeArea()
            
            SearchBarView(
                searchText: .constant(""),
                isSearching: false,
                onSubmit: {}
            )
        }
    }
}
