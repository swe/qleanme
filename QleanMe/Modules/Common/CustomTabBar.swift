import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme
    
    let tabs: [String]
    let action: (Int) -> Void
    var isHidden: Bool = false
    
    private func getIcon(for tab: String, isSelected: Bool) -> String {
        switch tab {
        case "house.circle":
            return isSelected ? "house.circle.fill" : "house.circle"
        case "plus":
            return "plus" // Plus icon stays the same
        case "person.circle":
            return isSelected ? "person.circle.fill" : "person.circle"
        default:
            return tab
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if !isHidden {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                                action(index)
                            }
                        }) {
                            if index == 1 {  // Middle button (larger and brighter)
                                Image(systemName: tabs[index])
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .offset(y: -15)
                            } else {
                                ZStack {
                                    if selectedTab == index {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                    }
                                    Image(systemName: getIcon(for: tabs[index], isSelected: selectedTab == index))
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTab == index ? .blue : .gray)
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                        if index != tabs.count - 1 {
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.8, height: 60)
                .background(
                    BlurView(style: colorScheme == .dark ? .dark : .light)
                        .cornerRadius(30)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                .offset(y: -30)
            }
        }
    }
}

private struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let isMiddle: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                if isMiddle {
                    // Middle button (larger and elevated)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        .offset(y: -20)
                } else {
                    // Regular buttons
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 50, height: 50)
                        }
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                }
            }
        }
        .frame(width: 60)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                CustomTabBar(
                    selectedTab: .constant(2),
                    tabs: [
                        "house.fill",
                        "plus.circle.fill",
                        "person.fill"
                    ],
                    action: { _ in }
                )
            }
        }
        .previewDisplayName("Light Mode")
        
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                CustomTabBar(
                    selectedTab: .constant(2),
                    tabs: [
                        "house.fill",
                        "plus.circle.fill",
                        "person.fill"
                    ],
                    action: { _ in }
                )
            }
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
