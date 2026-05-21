import SwiftUI

struct UserView: View {
    @EnvironmentObject var controller: Controller
     
    @State private var namaLengkap: String = ""
    @State private var usernameEmail: String = "userdev"
    @State private var passwordLama: String = ""
    @State private var passwordBaru: String = ""
     
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96) 
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                     
                    VStack(spacing: 16) {
                        Text("PROFILE PENGGUNA")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryPurple)
                            .tracking(0.5)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            // Field 1: Nama Lengkap
                            VStack(alignment: .leading, spacing: 6) {
                                Text("NAMA LENGKAP")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    ProfileCircleIcon(icon: "person.fill", color: primaryPurple)
                                    TextField("", text: $namaLengkap)
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Field 2: Username / Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text("USER NAME / EMAIL")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    ProfileCircleIcon(icon: "envelope.fill", color: primaryPurple)
                                    TextField("", text: $usernameEmail)
                                        .font(.system(size: 16, weight: .medium))
                                        .disabled(true)
                                }
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                     
                    VStack(spacing: 16) {
                        Text("GANTI PASSWORD")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryPurple)
                            .tracking(0.5)
                        
                        VStack(alignment: .trailing, spacing: 16) {
                            // Input Password Lama
                            HStack(spacing: 12) {
                                ProfileCircleIcon(icon: "lock.fill", color: primaryPurple)
                                SecureField("Password Lama", text: $passwordLama)
                                    .font(.system(size: 16))
                            }
                            .padding(6)
                            .background(lightGrayBG)
                            .cornerRadius(12)
                            
                            // Input Password Baru
                            HStack(spacing: 12) {
                                ProfileCircleIcon(icon: "lock.fill", color: primaryPurple)
                                SecureField("Password Baru", text: $passwordBaru)
                                    .font(.system(size: 16))
                            }
                            .padding(6)
                            .background(lightGrayBG)
                            .cornerRadius(12)
                             
                            Button(action: {
                                print("Menyimpan perubahan password...")
                            }) {
                                Text("Simpan")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 12)
                                    .background(primaryPurple)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
        }
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
        }
    }
}
 
struct ProfileCircleIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 38, height: 38)
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 15))
        }
    }
}
