import Foundation
import Combine
import SwiftUI

struct CarouselItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

class WelcomeViewModel: ObservableObject {
    @Published var isShowingAuthFlow = false
    @Published var starColor: Color = .white
    @Published var currentPage = 0
    @Published var showPhoneInput = false
    
    private var starBlinkTimer: AnyCancellable?
    private var carouselTimer: AnyCancellable?
    
    let backgroundImages: [CarouselItem] = [
        CarouselItem(
            imageName: "welcome_1",
            title: "Welcome to CleaningSuperApp",
            description: "Your one-stop solution for all your cleaning needs"
        ),
        CarouselItem(
            imageName: "welcome_2",
            title: "Book with Ease",
            description: "Schedule your cleaning service with just a few taps"
        ),
        CarouselItem(
            imageName: "welcome_3",
            title: "Professional Cleaners",
            description: "Our vetted professionals ensure top-quality service"
        ),
        CarouselItem(
            imageName: "welcome_4",
            title: "Eco-Friendly Options",
            description: "Choose from a range of eco-friendly cleaning solutions"
        )
    ]
    
    init() {
        startBlinkingAnimation()
        startCarouselTimer()
    }
    
    func navigateToAuthFlow() {
        isShowingAuthFlow = true
    }
    
    private func startBlinkingAnimation() {
        starBlinkTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.starColor = self?.starColor == .white ? .yellow : .white
            }
    }
    
    private func startCarouselTimer() {
        carouselTimer = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    self?.currentPage = ((self?.currentPage ?? 0) + 1) % (self?.backgroundImages.count ?? 1)
                }
            }
    }
}
