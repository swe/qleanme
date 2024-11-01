import SwiftUI

struct OfferDetailsView: View {
    let offer: DashboardOffer
    let details: OfferDetails
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    init(offer: DashboardOffer) {
        self.offer = offer
        self.details = OfferDetails.details(for: offer)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                descriptionSection
                if let code = details.code {
                    promoCodeSection(code)
                }
                termsSection
                validitySection
                
                if offer.action == .newOrder {
                    bookingButton
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            if offer.action == .referFriend {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: "Join me on QleanMe and get $50 off your first cleaning!") {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(offer.emoji)
                .font(.system(size: 64))
            
            Text(details.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(details.discount)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color(hex: UInt(offer.backgroundColor.dropFirst(), radix: 16) ?? 0x4CAF50))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            Text(details.fullDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func promoCodeSection(_ code: String) -> some View {
        VStack(spacing: 12) {
            Text("Promo Code")
                .font(.headline)
            
            HStack {
                Text(code)
                    .font(.system(.title3, design: .monospaced))
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                
                Button(action: {
                    UIPasteboard.general.string = code
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terms & Conditions")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(details.terms, id: \.self) { term in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                        
                        Text(term)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var validitySection: some View {
        VStack(spacing: 8) {
            Text("Valid until")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(details.validUntil.formatted(date: .long, time: .omitted))
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var bookingButton: some View {
        Button(action: {
            // TODO: Implement booking action
            dismiss()
        }) {
            Text("Book Now")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    Color(hex: UInt(offer.backgroundColor.dropFirst(), radix: 16) ?? 0x4CAF50)
                )
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
}

struct OfferDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OfferDetailsView(
                offer: DashboardOffer(
                    title: "Spring Cleaning Special",
                    description: "20% off on deep cleaning services",
                    backgroundColor: "#4CAF50",
                    action: .newOrder,
                    emoji: "🌸"
                )
            )
        }
        
        NavigationView {
            OfferDetailsView(
                offer: DashboardOffer(
                    title: "Refer a Friend",
                    description: "Get $50 off your next cleaning",
                    backgroundColor: "#2196F3",
                    action: .referFriend,
                    emoji: "🤝"
                )
            )
        }
    }
}
