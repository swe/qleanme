import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme
    
    let tabs: [String]
    let action: (Int) -> Void
    var isHidden: Bool = false  // New parameter to control visibility
    
    var body: some View {
        GeometryReader { geometry in
            if !isHidden {  // Only show the tab bar if it's not hidden
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                                action(index)
                            }
                        }) {
                            if index == tabs.count / 2 {
                                // Middle button (larger and brighter)
                                Image(systemName: tabs[index])
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .offset(y: -15) // Adjust this to raise the middle button
                            } else {
                                // Regular buttons
                                ZStack {
                                    if selectedTab == index {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                    }
                                    Image(systemName: selectedTab == index ? tabs[index] + ".fill" : tabs[index])
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
                .offset(y: -30) // Adjust this value to position the tab bar above the safe area
            }
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(2), tabs: [
                "house",
                "tray",
                "plus",
                "bell",
                "person"
            ], action: { _ in })
        }
        .background(Color.gray.opacity(0.1))
        .edgesIgnoringSafeArea(.all)
    }
}
