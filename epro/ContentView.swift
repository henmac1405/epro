

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controller : Controller
    @State private var startAnimating = false
    
    var body: some View {
        ZStack {
            VStack{
                if (self.controller.isLoggedIn == false){
                    LoginView()
                } else {
                    HomeView()
                }
            }
            .disabled(controller.isLoading)
             
        }
        .alert("Info", isPresented:$controller.showAlert) {
            Button("Oke", role: .cancel) {}
            
        } message: {
            Text(self.controller.responseMessage).font(.title).bold()
        }
        
        //Toast
        .overlay(alignment: .bottom) {
            if controller.showToast {
                HStack(spacing: 12) {
                    Image(systemName: controller.toastStyle == .success ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(controller.toastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    Color.black.opacity(0.9)
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)  
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }


    }
}

#Preview {
    ContentView().environmentObject(Controller())
}
