import SwiftUI

struct CeklistBulananView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
     
    @State private var selectedLocation: String = ""
    @State private var selectedDate: Date = Date()
    @State private var isSudahDicek: Bool = false
    @State private var selectedRowsLimit: Int = 5
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 303
    @State private var selectedTab: String = "INPEKSI"
    @State private var showLogoutAlert: Bool = false
     
    @State private var assetsList: [AssetItem] = [
        AssetItem(id: "1310052", name: "PANEL LISTRIK PP F1 M.C"),
        AssetItem(id: "1310053", name: "PANEL LISTRIK PP.ESC F1"),
        AssetItem(id: "1310054", name: "PANEL LISTRIK PP.SELASA"),
        AssetItem(id: "1310055", name: "PANEL LISTRIK PP.TENAN"),
        AssetItem(id: "1310056", name: "PANEL LISTRIK PP.AHU F1")
    ]
     
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.95, green: 0.94, blue: 0.96)
    let segmentUnselectedBG = Color(red: 0.88, green: 0.87, blue: 0.89)
    let headerTextGray = Color(red: 0.90, green: 0.90, blue: 0.92)
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
                .ignoresSafeArea()
             
            VStack(spacing: 16) {
                 
                Menu {
                    Button("Cibubur Mall", action: { selectedLocation = "Cibubur Mall" })
                    Button("Bekasi Mall", action: { selectedLocation = "Bekasi Mall" })
                } label: {
                    HStack {
                        Text(selectedLocation.isEmpty ? "Pilih Lokasi/Store" : selectedLocation)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedLocation.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                 
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                    
                    Text("2026-05-20")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(lightGrayBG)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                 
                HStack(spacing: 12) {
                    HStack(spacing: 0) {
                        Button(action: { isSudahDicek = false }) {
                            Text("Belum Dicek")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(!isSudahDicek ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(!isSudahDicek ? primaryPurple : Color.clear)
                                .cornerRadius(22)
                        }
                        
                        Button(action: { isSudahDicek = true }) {
                            Text("Sudah Dicek")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isSudahDicek ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(isSudahDicek ? primaryPurple : Color.clear)
                                .cornerRadius(22)
                        }
                    }
                    .padding(2)
                    .background(segmentUnselectedBG)
                    .cornerRadius(24)
                     
                    Menu {
                        Button("5", action: { selectedRowsLimit = 5 })
                        Button("10", action: { selectedRowsLimit = 10 })
                    } label: {
                        HStack {
                            Text("\(selectedRowsLimit)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 64, height: 48)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                 
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Aksi")
                            .frame(width: 60, alignment: .leading)
                        Text("Asset ID")
                            .frame(width: 90, alignment: .leading)
                        Text("Nama Asset")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(headerTextGray)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                     
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(assetsList) { item in
                                HStack(spacing: 0) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(primaryPurple)
                                        .frame(width: 60, alignment: .leading)
                                     
                                    Text(item.id)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(width: 90, alignment: .leading)
                                     
                                    Text(item.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                
                                Divider()
                            }
                        }
                    }
                }
                .padding(.top, 12)
                 
                HStack(spacing: 16) {
                    Button(action: { if currentPage > 1 { currentPage -= 1 } }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    Text("Halaman \(currentPage) dari \(totalPages)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Button(action: { if currentPage < totalPages { currentPage += 1 } }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 12)
                
                Spacer()
            }
            .padding(.bottom, 80)
            
            
        }
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
        }
    }
}

 
struct AssetItem: Identifiable {
    let id: String
    let name: String
}
