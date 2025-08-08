//
//  PathAssignmentOverlay.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI
import DotLottie

struct PathAssignmentOverlay: View {
    let assignedPath: HeroPath
    let onDismiss: () -> Void
    let pathIconNamespace: Namespace.ID
    
    @State private var showContent = false
    @State private var contentOpacity: Double = 0
    @State private var showLargeIcon = true
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            ZStack {
                // Large Path Icon - will animate to small position
                if showLargeIcon {
                    ZStack {
                        DotLottieAnimation(
                            fileName: "Lightning",
                            config: AnimationConfig(autoplay: true, loop: true, speed: 0.5)
                        )
                            .view()
                        Image(assignedPath.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.scale)
                            .foregroundColor(.black)
                            .matchedGeometryEffect(id: "pathIcon", in: pathIconNamespace)
                            .frame(width: 130, height: 130)
                    }
                    .offset(y: 50)
                }
                
                VStack(spacing: 8) {
                    // Path Name
                    Text(assignedPath.name)
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.textPath)
                        .fixedSize()
                        .matchedGeometryEffect(id: "pathName", in: pathIconNamespace)
                    
                    // Path Description
                    Text(assignedPath.description)
                        .font(.system(size: 16))
                        .foregroundColor(.textPath)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(contentOpacity)
                    
                }
                .offset(y: 180)
            }
        }
        .onAppear {
            startInitialAnimation()
        }
        .onTapGesture {
            withAnimation {
                onDismiss()
            }
        }
    }
    
    private func startInitialAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
            showContent = true
        }
        
        withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
            contentOpacity = 1.0
        }
    }
    
    private func animateIconToPosition() {
        // Fade out other content first
        withAnimation(.easeInOut(duration: 0.4)) {
            contentOpacity = 0
        }
        
        // Then animate the icon to its destination using matchedGeometryEffect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showLargeIcon = false
            }
            
            // Dismiss after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onDismiss()
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    return PathAssignmentOverlay(
        assignedPath: .sentinel,
        onDismiss: {},
        pathIconNamespace: namespace
    )
}
