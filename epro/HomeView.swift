import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [AppConfig]
    
    @State private var selectedTab: String = "HOME"
    @State private var showLogoutAlert: Bool = false
    
    //    let primaryPurple = Color(red: 0.65, green: 0.02, blue: 0.76)
    let lightBlueBG = Color(red: 0.92, green: 0.96, blue: 1.00)
    
    var body: some View {
        ZStack(alignment: .top) {
            // scroll start
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: self.controller.imageUrl + self.controller.main_background_image)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                                     
                            } else {
                                // Kontainer kosong transparan saat gambar sedang di-load
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                            }
                        }
                    }
                    
                    
                    
                    VStack(spacing: 0) {
                        Text(self.controller.user_fullname)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        Text(self.controller.branch_name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .padding(.bottom, 20)
                        
                        
                        VStack(spacing: 24) {
                            AsyncImage(url: URL(string: self.controller.imageUrl + self.controller.main_image_header)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 220)
                                        .cornerRadius(16)
                                        .padding(.horizontal, 16)
                                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            if controller.pageName == "HOME"{
                                MenuView()
                            } else if controller.pageName == "INPEKSI" {
                                InpeksiView()
                            } else if controller.pageName == "CEKLIST BULANAN" {
                                CeklistBulananView()
                            } else if controller.pageName == "VERIFIKASI ASSET" {
                                VerifyAssetView()
                            } else if controller.pageName ==  "ASSET HISTORY"{
                                AssetHistoryView()
                            } else if controller.pageName == "USER" {
                                UserView()
                            }
                        }
                        
                    }
                    .padding(.top, -200)
                    .padding(.bottom, 80)
                    
                    Spacer().frame(height: 140)
                    
                }
            }
            // scroll end
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    BottomTabItem(icon: "house", title: "HOME", isSelected: selectedTab == "HOME") {
                        selectedTab = "HOME"
                        controller.pageName = "HOME"
                    }
                    BottomTabItem(icon: "list.clipboard.fill", title: "INPEKSI", isSelected: selectedTab == "INPEKSI")
                    {
                        selectedTab = "INPEKSI"
                        controller.pageName = "INPEKSI"
                    }
                    BottomTabItem(icon: "person.fill", title: "USER", isSelected: selectedTab == "USER")
                    {
                        selectedTab = "USER"
                        controller.pageName = "USER"
                    }
                    
                    BottomTabItem(icon: "arrow.right.isActive", title: "LOGOUT", isSelected: selectedTab == "LOGOUT") {
                        showLogoutAlert = true
                    }
                }
                .padding(.vertical, 12)
                .background(Color.fromRGBAString(self.controller.main_menu_color))
                .cornerRadius(32)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
        }
        // ALERT DIALOG KONFIRMASI LOGOUT
        .alert("Konfirmasi Logout", isPresented: $showLogoutAlert) {
            Button("Batal", role: .cancel) { }
            Button("Logout", role: .destructive) {
                prosesLogout()
            }
        } message: {
            Text("Apakah Anda yakin ingin keluar ?")
        }
        .onAppear() {
            controller.pageName = "HOME"
            loadConfigOld()
        }
    }
    
    // Fungsi Eksekusi Aksi Tombol Keluar
    private func prosesLogout() {
        print("Sesi akun ditutup, mengalihkan halaman...")
        controller.isLoggedIn = false
    }
    
    func loadConfigOld() {
        
        if let savedConfig = configs.first {
            controller.bussinessunit_id_old = savedConfig.bussinessunit_id
            print("Data dimuat: \(controller.bussinessunit_id_old)")
        } else {
            print("Data kosong, menggunakan nilai default.")
        }
    }
    
}

struct MenuView : View {
    @EnvironmentObject var controller: Controller
    
    @State private var  primaryPurple = Color(red: 0.65, green: 0.02, blue: 0.76)
    
    let lightBlueBG = Color(red: 0.92, green: 0.96, blue: 1.00)
    
    let menuColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        
        VStack(spacing: 20) {
            Text("PILIH MENU PEKERJAAN")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.fromRGBAString(self.controller.main_menu_color))
                .tracking(0.5)
                .padding(.top, 8)
            
            
            LazyVGrid(columns: menuColumns, spacing: 16) {
                // Inspeksi
                Button(action: {
                    controller.pageName = "INPEKSI"
                    print(controller.pageName)
                })
                {
                    MainGridMenuButton(icon: "ico_task", title: "INPEKSI", iconColor: primaryPurple, boxColor: lightBlueBG)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Ceklist Bulanan
                Button(action: {
                    controller.pageName = "CEKLIST BULANAN"
                    print(controller.pageName)
                })
                {
                    MainGridMenuButton(icon: "schedulebualanan", title: "CEKLIST BULANAN", iconColor: primaryPurple, boxColor: lightBlueBG)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Verifikasi Asset
                Button(action: {
                    controller.pageName = "VERIFIKASI ASSET"
                    print(controller.pageName)
                })
                {
                    MainGridMenuButton(icon: "scanasset", title: "VERIFIKASI ASSET", iconColor: primaryPurple, boxColor: lightBlueBG)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Asset History
                Button(action: {
                    controller.pageName =  "ASSET HISTORY"
                    print(controller.pageName)
                })
                {
                    MainGridMenuButton(icon: "scanasset", title: "ASSET HISTORY", iconColor: primaryPurple, boxColor: lightBlueBG)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
        }
    }
    
}

struct MainGridMenuButton: View {
    @EnvironmentObject var controller: Controller
    
    let icon: String
    let title: String
    let iconColor: Color
    let boxColor: Color
    
    var body: some View {
        VStack(spacing: 14) {
            // Ikon Kotak Ungu di dalam
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.fromRGBAString(self.controller.main_menu_color))
                    .frame(width: 72, height: 72)
                
                Image(icon)
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .font(.system(size: 32, weight: .medium))
                    .frame(width: 50, height: 50)
            }
            .padding(.top, 14)
            
            // Label Teks di bawah kotak ikon
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .background(boxColor)
        .cornerRadius(18)
    }
}

// Komponen Elemen Navigasi Bar Bawah (Bottom Bar Item)
struct BottomTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Penyesuaian khusus simbol kustom untuk tombol logout panah keluar
                Image(systemName: icon == "arrow.right.isActive" ? "rectangle.portrait.and.arrow.right" : icon)
                    .font(.system(size: 20, weight: .medium))
                
                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}
