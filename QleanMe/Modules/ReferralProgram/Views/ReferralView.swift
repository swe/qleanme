import SwiftUI

struct ReferralProgramView: View {
    @StateObject private var viewModel = ReferralProgramViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 40) {
                headerView
                illustrationView
                messageView
                notifyButton
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 50)
            
            closeButton
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $viewModel.showNotificationConfirmation) {
            Alert(
                title: Text("You're on the list!"),
                message: Text("We'll let you know as soon as the referral program is ready."),
                dismissButton: .default(Text("Great"))
            )
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(colorScheme == .dark ? .systemIndigo : .systemBlue).opacity(0.7),
                Color(colorScheme == .dark ? .systemPurple : .systemIndigo).opacity(0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text(viewModel.comingSoonText)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.2)))
            
            Text(viewModel.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    private var illustrationView: some View {
        Image(systemName: "gift.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundColor(.white.opacity(0.9))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var messageView: some View {
        Text(viewModel.message)
            .font(.body)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var notifyButton: some View {
        Button(action: viewModel.notifyMe) {
            Text(viewModel.notifyButtonText)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(buttonBackground)
                .cornerRadius(15)
        }
    }
    
    private var buttonBackground: some View {
        Group {
            if colorScheme == .light {
                Color.blue
            } else {
                Color.white.opacity(0.2)
            }
        }
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}

struct ReferralProgramView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralProgramView()
            .preferredColorScheme(.light)
        
        ReferralProgramView()
            .preferredColorScheme(.dark)
    }
}
