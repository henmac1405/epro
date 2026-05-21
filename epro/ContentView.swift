

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
        
    }
}

#Preview {
    ContentView().environmentObject(Controller())
}
