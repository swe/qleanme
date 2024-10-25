import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

