import SwiftUI

struct OrderCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = OrderCreationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(OrderCleaningType.allCases) { type in
                            CleaningTypeCard(type: type, isSelected: viewModel.selectedCleaningType == type) {
                                viewModel.selectCleaningType(type)
                            }
                        }
                    }
                    .padding()
                }
                
                Button(action: viewModel.proceedToNextStep) {
                    HStack {
                        Text("Next")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isNextButtonActive ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.isNextButtonActive)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Select service", displayMode: .inline)
            .navigationBarItems(trailing: cancelButton)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToDetail) {
                destinationView
            }
        }
    }
    
    private var destinationView: some View {
        Group {
            switch viewModel.selectedCleaningType {
            case .baseCleaning:
                OrderBaseCleaningView()
            case .carDetailing:
                OrderCarDetailingView(viewModel: OrderCarDetailingViewModel())
            case .laundry:
                OrderLaundryView(viewModel: OrderLaundryViewModel())
            case .none:
                EmptyView()
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel", action: dismiss)
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct CleaningTypeCard: View {
    let type: OrderCleaningType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: type.iconName)
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.headline)
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .font(.system(size: 24))
                    .foregroundStyle(checkmarkStyle)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? [.blue, .purple] : [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var checkmarkStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            return AnyShapeStyle(Color.white.opacity(0.001))
        }
    }
}

struct OrderCreationView_Previews: PreviewProvider {
    static var previews: some View {
        OrderCreationView()
    }
}
