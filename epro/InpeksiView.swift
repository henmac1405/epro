import SwiftUI

struct InpeksiView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedRowsLimit: Int = 5
    @State private var selectedTab: String = "INPEKSI"
    @State private var showLogoutAlert: Bool = false
    @State private var currentPage: Int = 1
    @State private var task_date = "Semua Tanggal"
    @State private var showCalendar = false
    @State private var showDate = Date()
    @State private var filtertask_id = ""
    @State private var filtertask_date = ""
    @State private var filtertask_descr = ""
    @State private var filtertask_type = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.96, green: 0.95, blue: 0.97)
    
    
     
    var filteredTasks: [Tasks] {
        let allTasks = controller.task
         
        if searchText.isEmpty && filtertask_date.isEmpty {
            return allTasks
        }
        
        return allTasks.filter { item in
            let kataKunci = searchText.lowercased()
            let cocokTeks = !searchText.isEmpty && (
                item.task_description.lowercased().contains(kataKunci) ||
                item.task_id.lowercased().contains(kataKunci) ||
                item.task_type.lowercased().contains(kataKunci) ||
                item.asset_id.lowercased().contains(kataKunci)
            )
            let cocokTanggal = !filtertask_date.isEmpty &&
                item.task_date.contains(filtertask_date)
             
            return cocokTeks || cocokTanggal
        }
    }


      
    @State private var itemsPerPage = 5
    
    var totalPages: Int {
        let count = filteredTasks.count
        return count > 0 ? Int(ceil(Double(count) / Double(itemsPerPage))) : 1
    }
 
    var tasksOnCurrentPage: [Tasks] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, filteredTasks.count)
        
        guard startIndex < filteredTasks.count else { return [] }
        return Array(filteredTasks[startIndex..<endIndex])
    }

    
    var body: some View {
        ZStack() {
            
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(spacing: 8) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 20, weight: .bold))
                    Text("INPEKSI")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(primaryPurple)
                .padding(.horizontal, 16)
                
                HStack {
                    Button(action: {
                        self.showCalendar = true
                    }){
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text(task_date)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .sheet(isPresented: $showCalendar) {
                        VStack {
                            DatePicker("Pilih Tanggal", selection: $showDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                            Button("Selesai")
                            {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                self.task_date = formatter.string(from: self.showDate)
                                self.filtertask_date = formatter.string(from: self.showDate)
                                
                                showCalendar = false
                            }
                            .padding()
                        }
                        .presentationDetents([.medium])
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(lightGrayBG)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                
                
                HStack(spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(primaryPurple)
                                .frame(width: 32, height: 32)
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                        
                        TextField("Cari deskripsi...", text: $searchText)
                            .font(.system(size: 16))
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .focused($isSearchFieldFocused)
//                            .onChange(of: searchText) { oldValue, newValue in
//                                     
//                                    if newValue.count >= 3 {
//                                        self.controller.getInpeksiByUser(filter: newValue, taskid: filtertask_id, taskdate: filtertask_date, tasktype: filtertask_type)
//                                    }
//                                }
                        
                    }
                    .padding(.leading, 8)
                    .frame(height: 48)
                    .background(lightGrayBG)
                    .cornerRadius(10)
                    
                    Menu {
                        Button("5", action: {
                            itemsPerPage = 5
                            selectedRowsLimit = 5
                        })
                        Button("10", action: {
                            itemsPerPage = 10
                            selectedRowsLimit = 10})
                        Button("20", action: {
                            itemsPerPage = 20
                            selectedRowsLimit = 20 })
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
                        .background(lightGrayBG)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                
                HStack(spacing: 12) {
                    Button(action: {
//                        self.controller.getInpeksiByUser(filter: searchText, taskid: filtertask_id, taskdate: filtertask_date, tasktype: filtertask_type)
                        searchText = ""
                        filtertask_id = ""
                        filtertask_date = ""
                        filtertask_type = ""
                        selectedRowsLimit = 5
                    }) {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            Text("Filter")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(primaryPurple)
                        .cornerRadius(24)
                    }
                    
                    Button(action: {
                        searchText = ""
                        filtertask_id = ""
                        filtertask_date = ""
                        filtertask_type = ""
                        selectedRowsLimit = 5
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(primaryPurple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    self.controller.input_type = "NEW"
                    print("NEW")
                    self.controller.selectedTaskForEdit = nil
                    self.controller.sparepartList.removeAll()
                    self.controller.taskImage.removeAll()
                    self.controller.pageName = "INPUT INPEKSI"
                }) {
                    HStack {
                        Text("+")
                            .font(.system(size: 20, weight: .medium))
                        Text("Input Inpeksi")
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
                
                if self.controller.isLoading == false {
                    if self.filteredTasks.count == 0 {
                        HStack {
                            Spacer()
                            Text("Tidak ada data")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: true) {
                            //Header tabel
                            HStack(spacing: 0) {
                                Text("ID")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Description")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Tanggal")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Aksi")
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(.white))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.fromRGBAString(self.controller.main_table_col_color))
                            
                            Divider()
                                .background(Color(.systemGray4))
                            
                            //Detil Table
                            
                            VStack(spacing: 0) {
                                ForEach(self.tasksOnCurrentPage, id: \.task_id) { item in
                                    HStack(spacing: 0) {
                                        // Kolom 1: ID
                                        Text(item.task_id)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                        
                                        // Kolom 2: Deskripsi
                                        Text(item.task_description)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                        
                                        // Kolom 3: Tanggal
                                        Text(item.task_date)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                        
                                        // Kolom 4: Aksi Edit
                                        Button(action: {
                                            print("Mengedit item: \(item.task_description)")
                                            self.controller.selectedTaskForEdit = item
                                            self.controller.pageName = "INPUT INPEKSI"
                                            self.controller.input_type = "EDIT"
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(primaryPurple)
                                                .frame(width: 60, alignment: .trailing)
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    
                                    Divider()
                                        .padding(.horizontal, 16)
                                }
                            }
                             
                        }
                        
                        //Kontrol Halaman
                        HStack(spacing: 24) {
                            Button(action: {
                                if currentPage > 1 { currentPage -= 1 }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .disabled(currentPage == 1)
                            
                            // Teks Informasi Halaman Aktif
                            Text("Halaman \(currentPage) dari \(totalPages)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.8))
                            
                            // Tombol Halaman Berikutnya
                            Button(action: {
                                if currentPage < totalPages { currentPage += 1 }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .disabled(currentPage == totalPages)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                    }
                } else {
                    ProgressView()
                }
                
                
            }
            
            Spacer().frame(height: 120)
            
            
        }
        .onAppear() {
            controller.getInpeksiByUser(filter: searchText, taskid: filtertask_id, taskdate: filtertask_date, tasktype: filtertask_type)
            primaryPurple = Color.fromRGBAString(self.controller.main_menu_color)
            
        }
        .ignoresSafeArea(edges: .top)
        .padding(.bottom, -100)
        
        
        
    }
}

