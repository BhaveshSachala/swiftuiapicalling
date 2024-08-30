//
//  UserListView.swift
//  swiftuiapicalling
//
//  Created by Bhavesh Sachala on 30/08/24.
//

import SwiftUI

import SwiftUI

struct UserListView: View {
    @State private var users: [User] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(users) { user in
                        HStack {
                            AsyncImage(url: URL(string: user.avatar)) { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: fetchUsers)
            .navigationTitle("Users")
        }
    }

    private func fetchUsers() {
        isLoading = true
        ApiService.shared.get(endpoint: "users?page=1&per_page=14") { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    do {
                        let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                        users = userResponse.data
                    } catch {
                        errorMessage = "Failed to parse response"
                        print("Decoding error: \(error)")
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("API error: \(error)")
                }
            }
        }
    }
}
