import SwiftUI

struct InpeksiInputView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchAsset: String = ""
    @State private var selectedBranch: String = ""
    @State private var selectedBranchID: String = ""
    @State private var selectedJenisPekerjaan: String = ""
    @State private var selectedTaskTypeID: String = ""
    @State private var asset_image: String = ""
    @State private var asset_id: String = ""
    @State private var task_id: String = ""
    @State private var taskDate: String = ""
    
    @State private var deskripsiPekerjaan: String = ""
    
    @State private var showCalendar: Bool = false
    @State private var calendarDate: Date = Date()
    
    @State private var selectedTab: String = "INPEKSI"
    @State private var showLogoutAlert: Bool = false
    @State private var deskripsiSetelahPekerjaan: String = ""
    
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.96, blue: 0.98)
    
    @State private var selectedBranchObj: DataBranch? = nil
    @State private var selectedTaskTypeObj: TaskType? = nil
    
    @State private var showPhotoOptions = false
    @State private var openKamera = false
    @State private var openGaleri = false
    @State private var fotoSebelum: UIImage? = nil
    
    @State private var fotoSebelumList: [UIImage] = []
    
    
    @State private var showPhotoOptionsSetelah = false
    @State private var openKameraSetelah = false
    @State private var openGaleriSetelah = false
    @State private var fotoSetelah: UIImage? = nil
    @State private var showTambahSparepart: Bool = false
    
    //    @State private var sparepartList: [SparepartItem] = []
    
    @State private var AssetDescr = ""
    
    @State private var sparepartYangSedangDiedit: SparepartItem? = nil
    
    @State private var showQRScanner: Bool = false
    
    let menuColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var filteredTaskImageSebelum: [TaskImage] {
        let allTaskImage = controller.taskImage
        return allTaskImage.filter { item in
            let fotosebelum = item.taskimage_type.contains("1")
            return   fotosebelum
        }
    }
    
    var filteredTaskImageSetelah: [TaskImage] {
        let allTaskImage = controller.taskImage
        return allTaskImage.filter { item in
            let fotosebelum = item.taskimage_type.contains("2")
            return   fotosebelum
        }
    }
    
    @State private var fotoTerpilihUntukDiperbesar: TaskImage? = nil
    @State private var fotoTerpilihUntukZoom: TaskImage? = nil
    @State private var tempFotoSebelum: UIImage? = nil
    @State private var tempFotoSetelah: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(primaryPurple)
                    }
                    
                    Text("INPUT INPEKSI")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(primaryPurple)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(primaryPurple.opacity(0.12))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // 2. BAR PENCARIAN ASET & TOMBOL SCAN QR (Horizontal)
                        if self.controller.input_type != "HISTORY" {
                            HStack(spacing: 12) {
                                
                                HStack {
                                    Button(action:{
                                        findAsset(barcode : searchAsset)
                                        
                                    }){
                                        ZStack {
                                            Circle()
                                                .fill(primaryPurple)
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "magnifyingglass")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                    }
                                    
                                    TextField("Cari Asset", text: $searchAsset)
                                        .font(.system(size: 16))
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                        .submitLabel(.search)
                                        .onSubmit {
                                            findAsset(barcode : searchAsset)
                                        }
                                }
                                .padding(.leading, 6)
                                .frame(height: 52)
                                .background(Color.white)
                                .cornerRadius(26)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                
                                // Tombol Kotak Scan QR
                                Button(action: {
                                    self.showQRScanner = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(primaryPurple)
                                            .frame(width: 52, height: 52)
                                        Image(systemName: "qrcode")
                                            .foregroundColor(.white)
                                            .font(.system(size: 26, weight: .medium))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // MODAL POPUP KAMERA SCANNER QR/BARCODE
                                .sheet(isPresented: $showQRScanner) {
                                    QRScannerView { hasilBarcode in
                                        print("QR Code Terdeteksi: \(hasilBarcode)")
                                        
                                        self.searchAsset = hasilBarcode
                                        
                                        self.findAsset(barcode : searchAsset)
                                    }
                                    .ignoresSafeArea()
                                }
                                
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        // 3. KARTU DETAIL INFORMASI ASET (Gambar No Image & Status Card)
                        HStack(spacing: 16) {
                            if asset_image.isEmpty == true {
                                VStack {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.red)
                                    Text("NO IMAGE AVAILABLE")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 120, height: 156)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            } else {
                                AsyncImage(url: URL(string: self.controller.imageAssetUrl + self.asset_image)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 156)
                                            .clipped()
                                        
                                    } else {
                                        Color.clear
                                            .frame(maxWidth: .infinity)
                                            .frame(width: 120, height: 156)
                                            .clipped()
                                    }
                                }
                            }
                            VStack(spacing: 0) {
                                primaryPurple
                                    .frame(height: 36)
                                Text(AssetDescr).frame(height: 120).background(.white)
                                //                                Color.white
                                //                                    .frame(height: 54)
                            }
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // 4. DROPDOWN: PILIH BRANCH
                        Menu {
                            ForEach(controller.dataBranch, id: \.branch_id) { branch in
                                Button(action: {
                                    self.selectedBranchObj = branch
                                    self.selectedBranch = branch.branch_name
                                    print("Branch dipilih: \(branch.branch_name) (ID: \(branch.branch_id))")
                                }) {
                                    Text(branch.branch_name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedBranch.isEmpty ? "Pilih Branch" : selectedBranch)
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedBranch.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // 5. DROPDOWN: PILIH JENIS PEKERJAAN
                        Menu {
                            ForEach(controller.tasktype, id: \.tasktype_id) { task in
                                Button(action: {
                                    self.selectedTaskTypeObj = task
                                    self.selectedJenisPekerjaan = task.tasktype_name
                                    self.selectedTaskTypeID = task.tasktype_id
                                    print("Jenis Pekerjaan dipilih: \(task.tasktype_name) (ID: \(task.tasktype_id))")
                                }) {
                                    Text(task.tasktype_name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedJenisPekerjaan.isEmpty ? "Pilih Jenis Pekerjaan" : selectedJenisPekerjaan)
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedJenisPekerjaan.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // 6. INPUT TANGGAL PEKERJAAN (Picu Kalender Sheet)
                        Button(action: { showCalendar = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(primaryPurple)
                                
                                Text(taskDate.isEmpty ? "Tanggal Pekerjaan" : taskDate)
                                    .font(.system(size: 16))
                                    .foregroundColor(taskDate.isEmpty ? .gray : .black)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                        
                        // 7. TOMBOL UNGHAH FOTO SEBELUM PEKERJAAN
                        if self.controller.input_type != "HISTORY" {
                            Button(action: {
                                self.showPhotoOptions = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 18))
                                    Text("PILIH FOTO SEBELUM PEKERJAAN")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(primaryPurple)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            
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
                        }
                    
                        if !self.filteredTaskImageSebelum.isEmpty {
                            LazyVGrid(columns: menuColumns, spacing: 5) {
                                ForEach(self.filteredTaskImageSebelum) { item in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.45, alignment: .leading)
                                            .clipped()
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            .onTapGesture {
                                                self.fotoTerpilihUntukZoom = item
                                            }
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                self.controller.taskImage.removeAll(where: { $0.id == item.id })
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(Color.black.opacity(0.7))
                                                .background(Color.white.clipShape(Circle()))
                                                .padding(4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }


 
                            else {
                                Text("Belum ada foto sebelum pekerjaan")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.top, 4)
                            }
//                            
//                        }
                        
                        
                        // 9. TEXT EDITOR DESKRIPSI SEBELUM PEKERJAAN
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                if deskripsiPekerjaan.isEmpty {
                                    Text("Deskripsi Sebelum Pekerjaan")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                }
                                
                                TextEditor(text: $deskripsiPekerjaan)
                                    .font(.system(size: 16))
                                    .frame(minHeight: 100)
                                    .opacity(deskripsiPekerjaan.isEmpty ? 0.8 : 1)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(12)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // 10. TOMBOL UNGGAH FOTO SETELAH PEKERJAAN
                        if self.controller.input_type != "HISTORY" {
                            Button(action: {
                                self.showPhotoOptionsSetelah = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 18))
                                    Text("PILIH FOTO SETELAH PEKERJAAN")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(primaryPurple)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // POPUP DIALOG PILIHAN AKSES (Action Sheet Setelah Pekerjaan)
                            .confirmationDialog("Pilih Sumber Foto Setelah Pekerjaan", isPresented: $showPhotoOptionsSetelah, titleVisibility: .visible) {
                                Button("Kamera") {
                                    self.openKameraSetelah = true
                                }
                                Button("Galeri Foto") {
                                    self.openGaleriSetelah = true
                                }
                                Button("Batal", role: .cancel) { }
                            }
                        }
                         
                        if !self.filteredTaskImageSetelah.isEmpty {
                                LazyVGrid(columns: menuColumns, spacing: 5) {
                                    ForEach(self.filteredTaskImageSetelah) { item in
                                        HStack {
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: item.image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(height: 200)
                                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.45, alignment: .leading)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                                    .onTapGesture {
                                                        self.fotoTerpilihUntukZoom = item
                                                    }
                                                Button(action: {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        self.controller.taskImage.removeAll(where: { $0.id == item.id })
                                                    }
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 22))
                                                        .foregroundColor(Color.black.opacity(0.7))
                                                        .background(Color.white.clipShape(Circle()))
                                                        .padding(4)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Belum ada foto setelah pekerjaan")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.top, 4)
                            }
//                        }
                        
                        
                        // 12. TEXT EDITOR DESKRIPSI SETELAH PEKERJAAN
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                if deskripsiSetelahPekerjaan.isEmpty {
                                    Text("Deskripsi Setelah Pekerjaan")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                    
                                }
                                
                                TextEditor(text: $deskripsiSetelahPekerjaan)
                                    .font(.system(size: 16))
                                    .frame(minHeight: 100)
                                    .opacity(deskripsiSetelahPekerjaan.isEmpty ? 0.8 : 1)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(12)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // 13. TOMBOL TAMBAH SPAREPART (Picu munculnya popup sheet)
                        if self.controller.input_type != "HISTORY" {
                            Button(action: {
                                self.showTambahSparepart = true
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .font(.system(size: 18))
                                    Text("TAMBAH SPAREPART")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(primaryPurple)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                        }
                        // 14. LIST DATA SPAREPART
                        if !self.controller.sparepartList.isEmpty {
                            VStack(spacing: 12) {
                                LazyVGrid(columns: menuColumns, spacing: 5) {
                                    ForEach(self.controller.sparepartList) { item in
                                        let taskpart_type_name = self.controller.filtePartType(id: item.taskpart_type)
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                // Judul Utama (Nama Item & Qty)
                                                Text("\(item.taskpart_name) (\(item.taskpart_qty) Pcs)")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.black)
                                                
                                                // Tipe Pekerjaan
                                                Text("Tipe: \(taskpart_type_name)")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.8))
                                                    .lineSpacing(4)
                                                
                                                // Deskripsi atau Tipe Pekerjaan
                                                Text(item.taskpart_descr)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.8))
                                                    .lineSpacing(4)
                                                Text("")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.8))
                                                    .lineSpacing(4)
                                                
                                                // Tombol Edit Bundar Ungu di Pojok Kanan Bawah
                                                HStack {
                                                    Spacer()
                                                    Button(action: {
                                                        print("Mengedit sparepart: \(item.taskpart_name)")
                                                        self.sparepartYangSedangDiedit = item
                                                        self.showTambahSparepart = true
                                                    }) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(primaryPurple)
                                                                .frame(width: 32, height: 32)
                                                            Image(systemName: "pencil")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 14, weight: .bold))
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                                .padding(.top, -10)
                                                
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.top, 16)
                                        .padding(.bottom, 12)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.45, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 10)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        } else {
                            // JIKA KOSONG: Tampilkan pesan status default lama Anda
                            Text("Belum ada data sparepart yang dipakai dalam pekerjaan")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 4)
                        }
                        
                        
                        // 15. TOMBOL UTAMA "SIMPAN" DATA INSPEKSI
                        if self.controller.input_type != "HISTORY" {
                            Button(action: {
                                if asset_id == "" {
                                    self.controller.toastShow(message: "Data Gagal Disimpan, anda belum memilih Asset", style: .error)
                                } else if selectedBranchID == "" {
                                    self.controller.toastShow(message: "Data Gagal Disimpan, anda belum memilih Branch", style: .error)
                                } else if selectedTaskTypeID == "" {
                                    self.controller.toastShow(message: "Gagal menyimpan, anda belum memilih jenis pekerjaan", style: .error)
                                } else if taskDate == "" {
                                    self.controller.toastShow(message: "Gagal menyimpan, anda belum memilih Tanggal pekerjaan", style: .error)
                                } else {
                                    self.controller.submitTasksWithImages(task_id: task_id, task_date: taskDate, task_description: deskripsiPekerjaan, task_descriptionafter: deskripsiSetelahPekerjaan, task_type: selectedTaskTypeID, task_ismonthly: 0, asset_id: asset_id, branch_id: selectedBranchID, spareparts: self.controller.sparepartList)
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
                                                    self.controller.pageName = "INPEKSI"
                                                }
                                            } else {
                                                self.controller.toastShow(message: "Data Gagal Disimpan", style: .error)
                                                print("Gagal Menyimpan Form: \(message)")
                                            }
                                        }
                                    }
                                }
                            }) {
                                Text("SIMPAN")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(primaryPurple)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            
            
        }
        
        .onAppear() {
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
            if let taskToEdit = controller.selectedTaskForEdit {
                self.task_id = taskToEdit.task_id
                self.taskDate = taskToEdit.task_date
                self.deskripsiPekerjaan = taskToEdit.task_description
                self.selectedBranchID = taskToEdit.branch_id
                self.selectedBranch = controller.filterBranch(branchid: selectedBranchID)
                self.selectedTaskTypeID = taskToEdit.task_type
                self.selectedJenisPekerjaan = controller.filteTaskType(id: selectedTaskTypeID)
                
                
                controller.getInpeksiByUserByID(taskid: taskToEdit.task_id){
                    self.findAsset(barcode : self.controller.taskDetil.count > 0 ? self.controller.taskDetil[0].kode_barcode : "")
                    self.searchAsset = self.controller.taskDetil.count > 0 ? self.controller.taskDetil[0].kode_barcode : ""
                    self.asset_image = self.controller.taskDetil.count > 0 ? self.controller.taskDetil[0].asset_image : ""
                    self.deskripsiSetelahPekerjaan = self.controller.taskDetil.count > 0 ? self.controller.taskDetil[0].task_descriptionafter : ""
                     
                    
                    print(self.controller.imageAssetUrl + self.asset_image)
                    
                }
                
            }
        }
        // POPUP MODAL KALENDER DIALOG
        .sheet(isPresented: $showCalendar) {
            VStack {
                DatePicker("Pilih Tanggal", selection: $calendarDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .accentColor(primaryPurple)
                    .padding()
                
                Button(action: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.taskDate = formatter.string(from: self.calendarDate)
                    self.showCalendar = false
                }) {
                    Text("Selesai")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(primaryPurple)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $openKamera) {
            ImagePicker(image: $tempFotoSebelum, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $openGaleri) {
            ImagePicker(image: $tempFotoSebelum, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $openKameraSetelah) {
            ImagePicker(image: $tempFotoSetelah, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $openGaleriSetelah) {
            ImagePicker(image: $tempFotoSetelah, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showTambahSparepart, onDismiss: {
            self.sparepartYangSedangDiedit = nil
        }) {
            TambahSparepartPopupView(editItem: self.sparepartYangSedangDiedit) { item, qty, type, desc in
                withAnimation {
                    
                    if let itemLama = self.sparepartYangSedangDiedit,
                       let index = self.controller.sparepartList.firstIndex(where: { $0.id == itemLama.id }) {
                        self.controller.sparepartList[index].taskpart_name = item
                        self.controller.sparepartList[index].taskpart_qty = qty
                        self.controller.sparepartList[index].taskpart_type = type
                        self.controller.sparepartList[index].taskpart_descr = desc
                    } else {
                        let newSparepart = SparepartItem(taskpart_name: item, taskpart_qty: qty, taskpart_type: type, taskpart_descr: desc)
                        self.controller.sparepartList.append(newSparepart)
                    }
                }
            }
            .presentationDetents([.fraction(0.68)])
            .presentationDragIndicator(.visible)
        }
        
        // MARK: - FULL SCREEN PREVIEW UNTUK MEMPERBESAR GAMBAR
        .fullScreenCover(item: $fotoTerpilihUntukZoom) { selectedItem in
            ZStack {
                // Background Hitam Transparan khas Lightbox
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Klik di area kosong untuk menutup kembali gambar
                        fotoTerpilihUntukZoom = nil
                    }
                
                VStack {
                    // Tombol Tutup di Pojok Kanan Atas
                    HStack {
                        Spacer()
                        Button(action: {
                            fotoTerpilihUntukZoom = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding(16)
                        }
                    }
                    
                    Spacer()
                    
                    // Gambar Utama Ukuran Besar
                    Image(uiImage: selectedItem.image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    // Teks Informasi Tambahan (Opsional)
//                    if let name = selectedItem.taskimage_name {
//                        Text(name)
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.white)
//                            .padding(.top, 16)
//                    }
                    
                    Spacer()
                }
            }
        }
        .onChange(of: tempFotoSebelum) { oldValue, newValue in
            if let fotoBaru = newValue {
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.controller.taskImage.append(
                            TaskImage(
                                task_id: "tasksid",
                                taskimage_type: "1",
                                taskimage_line: 10,
                                taskimage_name: "foto_sebelum_\(Date().timeIntervalSince1970).jpg",
                                branch_id: self.controller.branch_id,
                                image: fotoBaru
                            )
                        )
                    } 
                    await MainActor.run {
                        tempFotoSebelum = nil
                    }
                }
            }
        }
        .onChange(of: tempFotoSetelah) { oldValue, newValue in
            if let fotoBaruSetelah = newValue {
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.controller.taskImage.append(
                            TaskImage(
                                task_id: "tasksid",
                                taskimage_type: "2",
                                taskimage_line: 20,
                                taskimage_name: "foto_setelah_\(Date().timeIntervalSince1970).jpg",
                                branch_id: self.controller.branch_id,
                                image: fotoBaruSetelah
                            )
                        )
                    }
                    await MainActor.run {
                        tempFotoSetelah = nil
                    }
                }
            }
        }

        .alert("Konfirmasi Keluar", isPresented: $showLogoutAlert) {
            Button("BATAL", role: .cancel) { }
            Button("KELUAR", role: .destructive) { }
        } message: {
            Text("Apakah Anda yakin ingin keluar dari aplikasi?")
        }
    }
    
    func findAsset(barcode : String){
        //FIND ASSET
        self.controller.findAssetbyUser(searchText: barcode) { json in
            DispatchQueue.main.async {
                if let data = json {
                    if data["state"] == true {
                        let dataObj = data["data"]
                        print(dataObj["asset_name"])
                        //1310140
                        self.AssetDescr = "ID Asset : \(dataObj["asset_id"]) \nNama Asset : \(dataObj["asset_name"]) \nLokasi : \(dataObj["asset_location"]) \nTipe : \(dataObj["asset_type"])"
                        print(self.AssetDescr)
                        selectedBranchID = dataObj["branch_id"].stringValue
                        asset_image = dataObj["asset_image"].stringValue
                        asset_id = dataObj["asset_id"].stringValue
                        print("asset_image : \(asset_image)")
                        // FIND BRANCH BY ID
                        selectedBranch = self.controller.filterBranch(branchid: selectedBranchID)
                        
                    } else{
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


