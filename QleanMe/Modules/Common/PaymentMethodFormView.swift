import SwiftUI

struct PaymentMethodFormView: View {
    @State private var selectedType: PaymentMethod.PaymentType = .creditCard
    @State private var cardNumber: String = ""
    @State private var expirationDate: String = ""
    @State private var cvv: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: (PaymentMethod) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Method")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Credit Card").tag(PaymentMethod.PaymentType.creditCard)
                        Text("Apple Pay").tag(PaymentMethod.PaymentType.applePay)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if selectedType == .creditCard {
                    Section(header: Text("Card Details")) {
                        TextField("Card Number", text: $cardNumber)
                            .keyboardType(.numberPad)
                        TextField("Expiration Date (MM/YY)", text: $expirationDate)
                            .keyboardType(.numberPad)
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Add Payment Method")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newPaymentMethod: PaymentMethod
                    if selectedType == .creditCard {
                        newPaymentMethod = PaymentMethod(id: UUID().uuidString, type: .creditCard, last4: String(cardNumber.suffix(4)))
                    } else {
                        newPaymentMethod = PaymentMethod(id: UUID().uuidString, type: .applePay)
                    }
                    onSave(newPaymentMethod)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedType == .creditCard && (cardNumber.isEmpty || expirationDate.isEmpty || cvv.isEmpty))
            )
        }
    }
}

struct PaymentMethodFormView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodFormView { _ in }
    }
}
