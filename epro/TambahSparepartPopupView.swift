import SwiftUI

struct TambahSparepartPopupView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    // State untuk menampung input data formulir
    @State private var namaItem: String = ""
    @State private var jumlahQty: Int = 0
    @State private var selectedPartType: String = ""
    @State private var selectedPartTypeName: String = ""
    @State private var deskripsi: String = ""
    
    // Callback ketika data berhasil disimpan
    var onSimpan: (String, Int, String, String) -> Void
    
    let primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.96, blue: 0.98)
    
    @State private var selectedPartTypeObj: PartType? = nil
    
    let editItem: SparepartItem?
    
    init(editItem: SparepartItem? = nil, onSimpan: @escaping (String, Int, String, String) -> Void) {
            self.editItem = editItem
            self.onSimpan = onSimpan
            
            if let item = editItem {
                // Jika mode EDIT: Isi otomatis form dengan data lama [[^15]]
                _namaItem = State(initialValue: item.taskpart_name)
                _jumlahQty = State(initialValue: item.taskpart_qty)
                _selectedPartType = State(initialValue: item.taskpart_type)
                //let cleanDesc = item.taskpart_type.replacingOccurrences(of: "Tipe: ", with: "")
                //_selectedPartType = State(initialValue: cleanDesc)
                _deskripsi = State(initialValue: item.taskpart_descr)
               
            }
        }
    var body: some View {
        VStack(spacing: 20) {
            // 1. JUDUL POPUP
            Text(editItem == nil ? "Tambah Item" : "Ubah Item")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
            
            // 2. FIELD INPUT NAMA ITEM
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                
                TextField("Item", text: $namaItem)
                    .font(.system(size: 16))
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            
            // 3. FIELD CONTROL STEPPER QTY (Angka & Tanda Panah Atas Bawah)
            HStack(spacing: 12) {
                Text("#")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text("\(jumlahQty)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Kontrol Panah Atas Bawah
                VStack(spacing: 4) {
                    Button(action: { jumlahQty += 1 }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Button(action: { if jumlahQty > 0 { jumlahQty -= 1 } }) {
                        Image(systemName: "triangle.fill")
                            .rotationEffect(.degrees(180))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            
            // 4. DROPDOWN SATUAN ITEM (Pcs, Box, dll.)
            Menu {
                ForEach(controller.parttype, id: \.parttype_id) { part in
                    Button(action: {
                        self.selectedPartTypeObj = part
                        self.selectedPartType = part.parttype_id
                        self.selectedPartTypeName = part.parttype_name
                        print("Jenis Part dipilih: \(part.parttype_name) (ID: \(part.parttype_id))")
                    }) {
                        Text(part.parttype_name)
                    }
                }
            } label: {
                HStack {
                    Text(selectedPartType.isEmpty ? "" : selectedPartTypeName)
                        .font(.system(size: 16))
                        .foregroundColor(selectedPartType.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "triangle.fill")
                        .rotationEffect(.degrees(180))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            
             
            
            
            // 5. TEXTEDITOR DESKRIPSI + LIMIT KARAKTER
            VStack(alignment: .trailing, spacing: 4) {
                ZStack(alignment: .topLeading) {
                    if deskripsi.isEmpty {
                        Text("Deskripsi")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $deskripsi)
                        .font(.system(size: 16))
                        .frame(height: 100)
                        .onChange(of: deskripsi) { newValue in
                            if newValue.count > 500 {
                                deskripsi = String(newValue.prefix(500))
                            }
                        }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                
                // Indikator angka karakter 0/500 sesuai gambar
                Text("\(deskripsi.count)/500")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            // 6. TOMBOL AKSI: BATAL & SIMPAN (Horizontal Berwarna Sesuai Gambar)
            HStack(spacing: 16) {
                // Tombol Batal (Abu-abu Gelap)
                Button(action: { dismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Batal")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.33, green: 0.33, blue: 0.35))
                    .cornerRadius(12)
                }
                
                // Tombol Simpan (Ungu CT Corp)
                Button(action: {
                    if namaItem == "" {
                        self.controller.toastShow(message: "Item belum diisi", style: .error)
                    } else if jumlahQty == 0 {
                        self.controller.toastShow(message: "Qty belum di isi", style: .error)
                    } else if selectedPartType == "" {
                        self.controller.toastShow(message: "Tipe belum di pilih", style: .error)
                    } else {
                        onSimpan(namaItem, jumlahQty, selectedPartType, deskripsi)
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("Simpan")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(primaryPurple)
                    .cornerRadius(12)
                }
                
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(24)
        .background(Color(red: 0.95, green: 0.94, blue: 0.96))
        .onAppear() {
            selectedPartTypeName = self.controller.filtePartType(id: selectedPartType)
        }
         
    }
}
