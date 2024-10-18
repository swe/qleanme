import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image Carousel
                InfiniteCarousel(items: viewModel.backgroundImages, currentIndex: $viewModel.currentPage) { item in
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Blurry section
                    VStack(spacing: 15) {
                        Text(viewModel.backgroundImages[viewModel.currentPage].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)
                        
                        Text(viewModel.backgroundImages[viewModel.currentPage].description)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)
                        
                        Button(action: {
                            viewModel.showPhoneInput = true
                        }) {
                            HStack {
                                Text("Login or Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Image(systemName: "sparkles")
                                    .foregroundColor(viewModel.starColor)
                                    .animation(.easeInOut(duration: 0.5), value: viewModel.starColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        // Carousel Dots
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.backgroundImages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == viewModel.currentPage ? textColor : textColor.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                    .frame(height: geometry.size.height * 0.3)
                    .frame(maxWidth: .infinity)
                    .background(BlurView(style: colorScheme == .dark ? .systemMaterialDark : .systemMaterialLight))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                }
                
                // Present LoginView as a sheet
                .sheet(isPresented: $viewModel.showPhoneInput) {
                    LoginView()
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}

struct InfiniteCarousel<Content: View, T: Identifiable>: View {
    let items: [T]
    let content: (T) -> Content
    @Binding var currentIndex: Int
    
    init(items: [T], currentIndex: Binding<Int>, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
        self._currentIndex = currentIndex
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    content(items[index])
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(currentIndex == index ? 1 : 0)
                        .animation(.easeInOut(duration: 1), value: currentIndex)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        withAnimation {
                            currentIndex = (currentIndex + 1) % items.count
                        }
                    } else if value.translation.width > threshold {
                        withAnimation {
                            currentIndex = (currentIndex - 1 + items.count) % items.count
                        }
                    }
                }
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView()
                .preferredColorScheme(.light)
            
            WelcomeView()
                .preferredColorScheme(.dark)
        }
    }
}
