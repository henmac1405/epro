import SwiftUI
import CoreData

struct LoginView: View {
    @EnvironmentObject var controller : Controller
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var BUconfig: String = ""
    
    @State private var inputUrl: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isInputFocused: Bool
    @State private var isDialog = false
    
    let menuColorString = "170,4,181,0"
    @State private var secretKey = "" // hendra
    
    // 1. Ambil Context dari Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // 2. Ambil semua data BusinessUnit dari database
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BusinessUnit.bussinessunit_id, ascending: true)],
        animation: .default)
    
    private var businessUnits: FetchedResults<BusinessUnit>
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ImageSliderView()
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.45)
                Color.fromRGBAString(self.controller.login_body_color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        AsyncImage(url: URL(string: self.controller.imageUrl + "themes/" + self.controller.login_logo)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        }
                        
                        if self.controller.isDebug {
                            Text("Debug On : \(self.controller.debugDescr)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                        }
                        
                    }
                    .padding(.top, 10)
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.fromRGBAString(self.controller.login_body_color))
                                .frame(width: 44, height: 44)
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        TextField("USER NAME", text: $username)
                            .font(.system(size: 16, weight: .medium))
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.fromRGBAString(self.controller.login_text1_color))
                    )
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.fromRGBAString(self.controller.login_body_color))
                                .frame(width: 44, height: 44)
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        SecureField("PASSWORD", text: $password)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.fromRGBAString(self.controller.login_text2_color))
                    )
                    
                    Button(action: {
                        if self.username == "DEBUG OFF" {
                            self.controller.isDebug = false
                            self.controller.url_api = self.controller.url_api_prod + self.controller.url_api_path
                            self.controller.imageUrl = self.controller.imageUrl_prod + self.controller.imageUrl_path
                            self.controller.imageAssetUrl = self.controller.imageAssetUrl_prod + self.controller.imageAssetUrl_path
                            self.username = ""
                            self.password = ""
                            self.controller.debugDescr = self.controller.url_api_prod
                        } else if self.username == "DEBUG ON" {
                            self.username = ""
                            self.password = ""
                            self.controller.isDebug = true
                            self.controller.url_api = self.controller.url_api_dev + self.controller.url_api_path
                            self.controller.imageUrl = self.controller.imageUrl_dev + self.controller.imageUrl_path
                            self.controller.imageAssetUrl = self.controller.imageAssetUrl_dev + self.controller.imageAssetUrl_path
                            self.controller.debugDescr = self.controller.url_api_dev
                        } else {
                            if self.username.isEmpty || self.password.isEmpty {
                                self.controller.showAlert = true
                                self.controller.responseMessage = "Username dan password tidak boleh kosong"
                                
                                
                                
                            } else {
                                self.controller.isLoading = true
                                self.controller.username = self.username
                                self.controller.user_password = self.password
                                
                                
                                self.controller.getVersion()
                                print("BUconfig : \(self.BUconfig) - controller.bussinessunit_id : \(self.controller.bussinessunit_id)")
                                
                            }
                        }
                        
                    }) {
                        
                        VStack{
                            if controller.isLoading == true {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                            } else {
                                Text("LOGIN")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.fromRGBAString(self.controller.login_body_color))
                        .cornerRadius(12)
                        
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("@2025 - IT GROUP CT CORP")
                        .font(.system(size: 14, weight: .medium))
                    Text("Version : 1.0.7")
                        .font(.system(size: 13, weight: .regular))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 24)
            }
            
            if isDialog {
                            CustomDialogView(
                                isPresented: $isDialog,
                                inputUrl: $inputUrl,
                                isTextFieldFocused: _isTextFieldFocused
                            )
                            .transition(.opacity)
                        }
            
        }
        .onAppear() {
            
            loadConfig()
            print("bussinessunit_id \(self.controller.bussinessunit_id)")
            print("bussinessunit_id_old \(self.controller.bussinessunit_id_old)")
            if self.controller.bussinessunit_id == self.controller.bussinessunit_id_old {
                print("Old Themes")
            } else {
                self.controller.getThemes()
            }
            
        }
//        .alert("Debug On : ", isPresented: $isDialog) {
//            TextField("Masukkan URL di sini...", text: $inputUrl, axis: .vertical)
//                .focused($isTextFieldFocused)
//                .font(.system(size: 16))
//                .padding()
//                .frame(minHeight: 55, maxHeight: 250)
//                .background(Color(red: 0.95, green: 0.93, blue: 0.97))
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color(red: 0.45, green: 0.35, blue: 0.65), lineWidth: 2)
//                )
//                .keyboardType(.default)
//            
//            Button("BATAL", role: .cancel) {
//            }
//            Button("OKE") {}
//        } message: {
//            Text("")
//        }
        
        
    }
    
    
    
    
    func loadConfig() {
        self.controller.bussinessunit_id = businessUnits.first?.safeBusinessUnitId ?? ""
        self.controller.BUConfig = businessUnits.first?.safeBusinessUnitId ?? ""
        
        print("BU : \(controller.bussinessunit_id)")
        //        if let savedConfig = configs.first {
        //            controller.bussinessunit_id = savedConfig.bussinessunit_id
        //            print("Data dimuat: \(controller.bussinessunit_id)")
        //        } else {
        //            print("Data kosong, menggunakan nilai default.")
        //        }
    }
    
    //    func saveConfig() {
    //        for config in configs {
    //            modelContext.delete(config)
    //        }
    //
    //        let newConfig = AppConfig(bussinessunit_id: controller.bussinessunit_id)
    //        modelContext.insert(newConfig)
    //
    //        print("Data berhasil diperbarui!")
    //    }
}

struct CustomDialogView: View {
    @EnvironmentObject var controller : Controller
    @Binding var isPresented: Bool
    @Binding var inputUrl: String
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background hitam transparan di luar dialog
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false // Tutup jika luar dialog diklik
                }
            
            // Kotak Dialog Utama
            VStack(alignment: .leading, spacing: 16) {
                Text("Debug On : ")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // Textfield Multi-Line yang Sesungguhnya
                TextField("Masukkan URL di sini...", text: $inputUrl, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .font(.system(size: 16))
                    .padding()
                    .frame(minHeight: 55, maxHeight: 70)
                    .background(Color(red: 0.95, green: 0.93, blue: 0.97))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.45, green: 0.35, blue: 0.65), lineWidth: 2)
                    )
                    .keyboardType(.default)
                
                // Tombol Aksi
                HStack(spacing: 16) {
                   
                    Button("BATAL") {
                        isPresented = false
                        self.controller.isDebug = false
                        
                    }
                    .foregroundColor(.red)
                    Spacer()
                    Button("OKE") {
                        self.controller.isDebug = true
                        isPresented = false
                        self.controller.debugDescr = self.inputUrl
                        self.controller.url_api = self.inputUrl + self.controller.url_api_path
                        self.controller.imageUrl = self.inputUrl + self.controller.imageUrl_path
                        self.controller.imageAssetUrl = self.controller.imageAssetUrl_dev + self.controller.imageAssetUrl_path
                    }
                    .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 32) // Jarak kanan kiri dialog ke layar
            .shadow(radius: 10)
        }
    }
}


extension Color {
    static func fromRGBAString(_ rgbaString: String) -> Color {
        let components = rgbaString.components(separatedBy: ",")
        
        guard components.count >= 3 else {
            return Color.purple
        }
        
        let r = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let g = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let b = Double(components[2].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        
        var a = 1.0
        if components.count == 4 {
            let alphaInput = Double(components[3].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
            a = alphaInput == 0 ? 1.0 : alphaInput
        }
        
        return Color(.sRGB, red: r / 255.0, green: g / 255.0, blue: b / 255.0, opacity: a)
    }
}

#Preview {
    LoginView()
}
