//
//  BorderedGroup.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/13/25.
//

import SwiftUI

struct BorderedGroup<Content: View>: View {
    let content: Content
    let padding: CGFloat
    init(padding: CGFloat = 30, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
        .containerBorder()
    }
}

#Preview {
    BorderedGroup {
        VStack {
            Text("Hi")
            Text("Hello")
        }
    }
}
