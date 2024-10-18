import SwiftUI

struct AddressFormView: View {
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var province: String = ""
    @State private var postalCode: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: (Address) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Address Details")) {
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("Province", text: $province)
                    TextField("Postal Code", text: $postalCode)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newAddress = Address(id: UUID().uuidString, street: street, city: city, province: province, postalCode: postalCode)
                    onSave(newAddress)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(street.isEmpty || city.isEmpty || province.isEmpty || postalCode.isEmpty)
            )
        }
    }
}

struct AddressFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddressFormView { _ in }
    }
}
