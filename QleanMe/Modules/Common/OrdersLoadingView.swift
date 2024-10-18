//
//  CustomLoadingView.swift
//  QleanMe
//
//  Created by weirdnameofadmin on 2024-10-15.
//


import SwiftUI

struct OrdersLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("Loading orders...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 20)
        }
        .padding(40)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct CustomLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersLoadingView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.1))
        
        OrdersLoadingView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
            .environment(\.colorScheme, .dark)
    }
}
