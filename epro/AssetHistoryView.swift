import SwiftUI

struct AssetHistoryView : View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.95, blue: 0.97)
    
    @State private var showTable: Bool = false
    @State private var showQRScanner: Bool = false
    @State private var searchAsset = ""
    
    var body: some View {
        VStack {
                Button(action: {
                    self.showQRScanner = true
                   
//                    showTable = true  // ← ini yang membuat tabel muncul
                    
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")  
                                                        .font(.system(size: 18, weight: .semibold))
                        Text("Scan Asset")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.fromRGBAString(self.controller.main_menu_color))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            
            // MODAL POPUP KAMERA SCANNER QR/BARCODE
            .sheet(isPresented: $showQRScanner) {
                QRScannerView { hasilBarcode in
                    print("QR Code Terdeteksi: \(hasilBarcode)")
                    
                    self.searchAsset = hasilBarcode
                    self.findHistoryAsset(barcode : searchAsset)
                    controller.getAssetHistory(barcode:searchAsset)
               
                }
                .ignoresSafeArea()
            }
            
            
            
            if showTable {
                loadassethistory()
            }
  
            
        }
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
           
            
        }
    }
    
    func findHistoryAsset(barcode : String){
        //FIND ASSET
        self.controller.findHistoryAsset(searchText: barcode)
    }
    
    func loadassethistory() -> some View {
        VStack(spacing: 16) { // Jarak antar komponen di layar luar
            
            // --- CONTAINER UTAMA (CARD) ---
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. HEADER CARD (Judul Utama - DIKUNCI, TIDAK IKUT SCROLL)
                Text("Daftar History Asset")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white) // Latar belakang judul tetap putih bersih
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                VStack(){
                    // 2. AREA SCROLLABLE (Hanya bagian tabel saja yang bisa digeser)
                    ScrollView(.horizontal, showsIndicators: true) {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // --- HEADER KOLOM TABEL ---
                            HStack(spacing: 0) {
                                Text("View").frame(width: 60, alignment: .leading)
                                Text("ID").frame(width: 90, alignment: .leading)
                                Text("Nama Asset").frame(width: 150, alignment: .leading)
                                Text("Lokasi").frame(width: 120, alignment: .leading)
                                Text("Tanggal").frame(width: 110, alignment: .leading)
                                Text("Tipe Tugas").frame(width: 130, alignment: .leading)
                                Text("Deskripsi").frame(width: 200, alignment: .leading)
                                Text("Dibuat Oleh").frame(width: 120, alignment: .leading)
                                Text("Store").frame(width: 120, alignment: .leading)
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.fromRGBAString(self.controller.main_table_col_color))
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                            
                            // --- DATA TABEL ---
                            VStack(spacing: 0) {
                                ForEach(controller.assethistory) { history in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            // Kolom View (Tombol)
                                            Button {
                                                let taskMapped = Tasks(
                                                    task_id: history.task_id,
                                                    task_date: history.task_date,
                                                     task_description: history.task_description,
                                                     task_descriptionafter: "",
                                                     task_type: history.task_type,
                                                     task_ismonthly: 0,
                                                     asset_id: history.asset_id,
                                                     branch_id: history.branch_id
                                                    )
                                                //
                                               self.controller.selectedTaskForEdit = taskMapped
                                               self.controller.pageName = "INPUT INPEKSI"
                                               self.controller.input_type = "HISTORY"
                                                
                                            } label: {
                                                Image(systemName: "eye.fill")
                                                    .font(.system(size: 22, weight: .medium))
                                                    .foregroundColor(primaryPurple)
                                            }
                                            .frame(width: 60, alignment: .leading)
                                            
                                            // Data Kolom
                                            Text(history.asset_id).frame(width: 90, alignment: .leading)
                                            Text(history.asset_name).frame(width: 150, alignment: .leading).lineLimit(1)
                                            Text(history.asset_location).frame(width: 120, alignment: .leading).lineLimit(1)
                                            Text(history.task_date).frame(width: 110, alignment: .leading).lineLimit(1)
                                            Text(history.task_type_name).frame(width: 130, alignment: .leading).lineLimit(1)
                                            Text(history.task_description).frame(width: 200, alignment: .leading).lineLimit(1)
                                            Text(history.created_by).frame(width: 120, alignment: .leading).lineLimit(1)
                                            Text(history.branch_name).frame(width: 120, alignment: .leading).lineLimit(1)
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        
                                        if history.id != controller.assethistory.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .background(Color.white)
                        }
                      
                        
                       
                    }
                }.padding(10)
                
              
            
            }
            // BORDER SEKARANG MEMBUNGKUS CONTAINER LUAR
            // Efeknya: Judul dan Tabel berada di dalam satu kotak melengkung yang sama,
            // tetapi hanya bagian dalam tabel yang bisa digeser ke kanan-kiri.
           
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 16) // Padding luar agar card berjarak dari tepi layar ponsel
        }
        .padding(.top, 16) // Padding atas untuk memberikan jarak turun ke bawah dari screen top
    }
}


