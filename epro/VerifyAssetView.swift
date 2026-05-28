import SwiftUI

struct VerifyAssetView : View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.95, blue: 0.97)
    
    @State private var showQRScanner: Bool = false
    @State private var showPhotoOptions: Bool = false
    @State private var searchAsset = ""
    
    @State private var  asset_selected : Bool = false
    @State private var  openKamera : Bool = false
    @State private var  openGaleri : Bool = false
    @State private var tempFotoVerifikasi: UIImage? = nil
    
    @State private var asset_id = ""
    @State private var asset_name = ""
    @State private var asset_type = ""
    @State private var asset_ismonthly = 0
    @State private var asset_level = ""
    @State private var asset_image = ""
    @State private var asset_location = ""
    @State private var asset_capacity = ""
    @State private var branch_id = ""
    @State private var branch_name = ""
    @State private var brand_name = ""
    @State private var kode_barcode = ""
    @State private var plan_category = ""
    @State private var vendor_name = ""
    @State private var date_checker = ""
    @State private var username_checker = ""
    @State private var buying_date = ""
    @State private var photo_name = ""
    @State private var asset_isavailable = 0
    @State private var asset_status  = ""
    @State private var showVerifikasiAlert: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                //                self.showQRScanner = true
                self.findVerifyAsset(barcode : "10100006")
            }) {
                HStack {
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
             
            
            // MODAL POPUP KAMERA SCANNER QR/BARCODE
            .sheet(isPresented: $showQRScanner) {
                QRScannerView { hasilBarcode in
                    print("QR Code Terdeteksi: \(hasilBarcode)")
                    
                    self.searchAsset = hasilBarcode
                    
                    self.findVerifyAsset(barcode : searchAsset)
                }
                .ignoresSafeArea()
            }
            
            if self.asset_selected == true {
                // MARK: - 2. KARTU STATUS VERIFIKASI
                VStack(alignment: .leading, spacing: 16) {
                    // Status Judul
                    Text("Status Asset : \(asset_status)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(primaryPurple)
                    
                    if asset_isavailable == 1 {
                        VStack{
                            Text("Foto Verifikasi Terakhir:")
                                .font(.system(size: 14, weight: .bold))
                            
                            AsyncImage(url: URL(string: self.controller.imageUrl + "maintenance/" + self.photo_name)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 190)
                                        .cornerRadius(16)
                                        .clipped()
                                        .padding(.bottom, 8)
                                    
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 190)
                                        .clipped()
                                }
                            }
                        }
                    }
                    
                    // Tombol Ambil Foto
                    Button(action: {
                        self.showPhotoOptions = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                            Text("Ambil Foto")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(primaryPurple)
                        .cornerRadius(24)
                    }
                    // POPUP DIALOG PILIHAN AKSES (Action Sheet)
                    .confirmationDialog("Pilih Sumber Foto", isPresented: $showPhotoOptions, titleVisibility: .visible) {
                        Button("Kamera") {
                            self.openKamera = true
                        }
                        Button("Galeri Foto") {
                            self.openGaleri = true
                        }
                        Button("Batal", role: .cancel) { }
                    }
                    
                    if let gambarTerpilih = self.tempFotoVerifikasi {
                        ZStack(alignment: .topTrailing) {
                            // Menampilkan Foto Verifikasi Aset
                            Image(uiImage: gambarTerpilih)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .cornerRadius(12)
                                .clipped()
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            // Tombol Silang untuk Menghapus / Mengambil Ulang Gambar
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.tempFotoVerifikasi = nil
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .background(Color.white.clipShape(Circle()))
                                    .padding(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 4)
                        .transition(.opacity)
                    }
                    
                    // Detail Teks Informasi Verifikasi
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Diverifikasi Oleh : \(username_checker)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                        
                        Text("Tanggal Verifikasi : \(date_checker)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .padding(.vertical, 8)
                    
                    // Tombol Verifikasi Utama
                    Button(action: {
                        showVerifikasiAlert = true
                       
                    }) {
                        Text("Verifikasi")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(primaryPurple)
                            .cornerRadius(24)
                    }
                    
                    // MARK: - 3. KARTU INFORMASI ASSET (LENGKAP DENGAN DETAIL SPESIFIKASI)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informasi Asset")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 4)
                        
                        // Menampilkan Gambar
                        AsyncImage(url: URL(string: self.controller.imageAssetUrl + self.asset_image)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 190)
                                    .cornerRadius(16)
                                    .clipped()
                                    .padding(.bottom, 8)
                                
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 190)
                                    .clipped()
                            }
                        }
                        
                        // Baris Informasi Detail Sesuai Gambar
                        VStack(spacing: 12) {
                            // Kolom 1: Asset ID
                            infoRow(label: "Asset ID :", value: asset_id) // Ganti dengan variabel dinamis: controller.assetDetail.asset_id
                            
                            // Kolom 2: Kode Barcode
                            infoRow(label: "Kode Barcode :", value: kode_barcode)
                            
                            // Kolom 3: Nama Asset
                            infoRow(label: "Nama Asset :", value: asset_name)
                            
                            // Kolom 4: Lokasi Asset
                            infoRow(label: "Lokasi Asset\n(Store) :", value: branch_name)
                            
                            // Kolom 5: Area / Lantai
                            infoRow(label: "Area / Lantai :", value: asset_location)
                            
                            // Kolom 6: Brand
                            infoRow(label: "Brand :", value: brand_name)
                            
                            // Kolom 7: Type Asset
                            infoRow(label: "Type Asset :", value: asset_type)
                            
                            // Kolom 8: Plan Category
                            infoRow(label: "Plan Category :", value: plan_category)
                            
                            // Kolom 9: Capacity
                            infoRow(label: "Capacity :", value: asset_capacity)
                            
                            // Kolom 10: Vendor Pembelian
                            infoRow(label: "Vendor\nPembelian :", value: vendor_name) // Kosongkan atau beri strip jika nilai kosong dari API
                            
                            // Kolom 11: Tanggal Akhir Garansi
                            infoRow(label: "Tanggal Akhir\nGaransi :", value: buying_date)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
            }
            
        }
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
        }
        // ALERT DIALOG VERIFIKASI
        .alert("Konfirmasi Verifikasi", isPresented: $showVerifikasiAlert) {
            Button("Tidak Tersedia") {
                self.verifyAsset(isavailable: "0")
            }
            Button("Tersedia") {
                if tempFotoVerifikasi == nil {
                    self.controller.showAlert = true
                    self.controller.responseMessage = "Foto harus diambil jika Asset tersedia"
                } else {
                    self.verifyAsset(isavailable: "1")
                }
            }
        } message: {
            Text("Pilih status ketersediaan Asset : ")
        }
        .sheet(isPresented: $openKamera) {
            ImagePicker(image: $tempFotoVerifikasi, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $openGaleri) {
            ImagePicker(image: $tempFotoVerifikasi, sourceType: .photoLibrary)
        }
    }
    
    // Fungsi Bantuan untuk Menyusun Baris Informasi Suku Kata Sejajar Lurus
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Teks Label Sebelah Kiri (Lebar dikunci pada 140 agar titik dua sejajar lurus ke bawah)
            Text(label)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
                .frame(width: 140, alignment: .leading)
                .lineSpacing(3)
            
            // Teks Nilai Sebelah Kanan
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func verifyAsset(isavailable : String){
        self.controller.verifyAssetData(asset_id: asset_id, branch_id: branch_id, isavailable: isavailable, fotoVerifikasi: tempFotoVerifikasi)
        { jsonResult in
            
            let state = jsonResult["state"] as? Bool ?? false
            let message = jsonResult["message"] as? String ?? "Terjadi kesalahan"
            
            
            DispatchQueue.main.async {
                if state {
                    print("Pesan Sukses Server: \(message)")
                    // if let responseData = jsonResult["data"] as? [String: Any] {
                    //     let newId = responseData["task_id"] as? String ?? ""
                    //     print("ID Baru yang dibuat Server: \(newId)")
                    // }
                    self.controller.toastShow(message: "Data Berhasil Disimpan", style: .success)
                    withAnimation(.easeInOut) {
                        self.controller.pageName = "HOME"
                    }
                } else {
                    self.controller.toastShow(message: "Data Gagal Disimpan", style: .error)
                    print("Gagal Menyimpan Form: \(message)")
                }
            }
        }
    }
    func findVerifyAsset(barcode : String){
        //FIND ASSET
        self.controller.findVerifyAsset(searchText: barcode) { json in
            DispatchQueue.main.async {
                if let data = json {
                    if data["state"] == true {
                        self.asset_selected = true
                        
                        let dataObj = data["data"]
                        print(dataObj["asset_name"])
                        asset_id = dataObj["asset_id"].stringValue
                        asset_name = dataObj["asset_name"].stringValue
                        asset_type = dataObj["asset_type"].stringValue
                        asset_ismonthly = dataObj["asset_ismonthly"].intValue
                        asset_level = dataObj["asset_level"].stringValue
                        asset_image = dataObj["asset_image"].stringValue
                        asset_location = dataObj["asset_location"].stringValue
                        asset_capacity = dataObj["asset_capacity"].stringValue
                        branch_id = dataObj["branch_id"].stringValue
                        brand_name = dataObj["brand_name"].stringValue
                        kode_barcode = dataObj["kode_barcode"].stringValue
                        plan_category = dataObj["plan_category"].stringValue
                        vendor_name = dataObj["vendor_name"].stringValue
                        buying_date = dataObj["buying_date"].stringValue
                        date_checker = dataObj["date_checker"].stringValue
                        username_checker = dataObj["username_checker"].stringValue
                        photo_name = dataObj["photo_name"].stringValue
                        asset_isavailable = dataObj["asset_isavailable"].intValue
                        
                        if asset_isavailable == 1 {
                            asset_status = "Tersedia"
                        } else if asset_isavailable == 0 {
                            asset_status = "Tidak Tersedia"
                        } else {
                            asset_status = "Belum di Verifikasi"
                        }
                        self.branch_name = controller.filterBranch(branchid: branch_id)
                        
                        
                    } else{
                        self.asset_selected = false
                        
                        self.controller.showAlert = true
                        self.controller.responseMessage = data["message"].stringValue
                    }
                } else {
                    self.controller.showAlert = true
                    self.controller.responseMessage = "Gagal Load Data Asset"
                    
                }
            }
        }
    }
}
