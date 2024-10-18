import SwiftUI

struct FAQView: View {
    @StateObject private var viewModel = FAQViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            backgroundColor
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                faqList
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchFAQs()
        }
        .padding(.bottom, 110)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color.gray.opacity(0.1)
    }
    
    private var faqList: some View {
        List(viewModel.faqs) { faq in
            DisclosureGroup(
                content: {
                    Text(faq.answer)
                        .padding(.vertical, 8)
                        .foregroundColor(.secondary)
                },
                label: {
                    Text(faq.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            )
            .padding(.vertical, 4)
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Oops! Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                viewModel.fetchFAQs()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FAQView()
        }
    }
}
