import SwiftUI

struct OrderCreationSupportingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            OrderCreationView()
                .navigationBarTitle("Select service", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct OrderCreationSupportingView_Previews: PreviewProvider {
    static var previews: some View {
        OrderCreationSupportingView()
    }
}
