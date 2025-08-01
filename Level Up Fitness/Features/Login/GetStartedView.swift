//
//  GetStartedView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/15/25.
//

import SwiftUI

struct GetStartedView: View {
    enum NavigationDestination {
        case signup
        case login
    }
    
    @State var navDestination: NavigationDestination?
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                
                VStack(spacing: 40) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    becomeHeroText
                    Spacer()
                    Spacer()
                    
                    footer
                }
                .padding(.horizontal, 32)
                .background(
                    Image("getting_started_bg")
                        .resizable()
                        .ignoresSafeArea()
                )
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $navDestination) { destination in
                LoginView(isLogin: destination == .login)
            }
        }
    }
    
    var becomeHeroText: some View {
        VStack(spacing: -10) {
            Text("BECOME")
                .font(.mainFont(size: 60))
            
            Text("YOUR OWN")
                .font(.mainFont(size: 45))
            
            Text("HERO")
                .font(.mainFont(size: 60))
                
        }
        .foregroundStyle(.title)
        .bold()
    }
    
    var footer: some View {
        VStack(spacing: 24) {
            Text("BEGIN YOUR JOURNEY")
                .font(.mainFont(size: 18))
                .fontWeight(.medium)
                .foregroundStyle(Color.title)
            
            LUButton(title: "SIGN UP", fillSpace: true) {
                navDestination = .signup
            }
            // Log in link
            
            Button{
                navDestination = .login
            } label: {
                HStack {
                    Text("Do you have an account?")
                    Text("Log In")
                        .fontWeight(.bold)
                }
                .foregroundStyle(Color.textDetail)
                .font(.system(size: 16))
            }
            Spacer()
        }
    }
}

#Preview {
    GetStartedView()
}
