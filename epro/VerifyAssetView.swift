import SwiftUI

struct VerifyAssetView : View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.95, blue: 0.97)
    var body: some View {
        VStack {
                Button(action: { print("Scan Asset") }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")  
                                                        .font(.system(size: 18, weight: .semibold))
                        Text("Scan Asset")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(primaryPurple)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            
        }
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
        }
    }
}
