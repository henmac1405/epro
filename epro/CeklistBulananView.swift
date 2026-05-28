import SwiftUI

struct CeklistBulananView: View {
    @EnvironmentObject var controller: Controller
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBranchID: String = ""
    @State private var selectedBranchName: String = "Pilih Cabang"
    
    

    @State private var selectedLocation: String = ""
    @State private var selectedDate: Date = Date()
    @State private var isSudahDicek: Bool = false
    @State private var selectedRowsLimit: Int = 5
    @State private var currentPage: Int = 1
//    @State private var totalPages: Int = 2
    @State private var selectedTab: String = "INPEKSI"
    @State private var showLogoutAlert: Bool = false
    
    @State private var task_date = ""
    @State private var showCalendar = false
    @State private var showDate = Date()
    @State private var filtertask_id = ""
    
    @State private var assetsList: [AssetItem] = []

    @State private var primaryPurple = Color(red: 0.53, green: 0.00, blue: 0.56)
    let lightGrayBG = Color(red: 0.95, green: 0.94, blue: 0.96)
    let segmentUnselectedBG = Color(red: 0.88, green: 0.87, blue: 0.89)
    let headerTextGray = Color(red: 0.90, green: 0.90, blue: 0.92)
    
    
    @State private var showDatePicker = false
    @State private var tempSelectedDate = Date()   // untuk popup


    @State private var itemsPerPage = 5
    

       
       var totalPages: Int {
           let count = controller.assetsList.count
           return count > 0 ? Int(ceil(Double(count) / Double(itemsPerPage))) : 1
       }
    
       var trxOnCurrentPage: [AssetItem] {
           let startIndex = (currentPage - 1) * itemsPerPage
           let endIndex = min(startIndex + itemsPerPage, controller.assetsList.count)
           
           guard startIndex < controller.assetsList.count else { return [] }
           return Array(controller.assetsList[startIndex..<endIndex])
       }
       
       
    
    
    var body: some View {
        ZStack {
             
            VStack(spacing: 16) {
                 
                Menu {
                    ForEach(controller.dataBranch, id: \.branch_id  ) { branch in
                        
                           Button(branch.branch_name) {
                               selectedLocation = branch.branch_name
                               selectedBranchID = branch.branch_id   // simpan id untuk API berikutnya
                             
                               controller.getCeklistbulanan(
                                branchID: branch.branch_id,
                                taskDate: dateToString(tempSelectedDate),
                                buttoncek: isSudahDicek == false ? 0 : 1
                               )
                               
                            
                             
                           }
                        
                        
                       }
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
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: $tempSelectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()

                        HStack {
                            Button("Cancel") {
                                showDatePicker = false
                            }
                            .padding()
                            .frame(maxWidth: .infinity)

                            Button("OK") {
                                selectedDate = tempSelectedDate
                                showDatePicker = false
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .presentationDetents([.medium]) // optional
                }
                
                .onTapGesture {
                    tempSelectedDate = selectedDate
                    showDatePicker = true
                }
                
                
                
                 
                HStack(spacing: 12) {
                    HStack(spacing: 0) {
                        Button(action: { isSudahDicek = false
                             controller.getCeklistbulanan(
                             branchID: selectedBranchID,
                             taskDate: dateToString(tempSelectedDate),
                             buttoncek: 0
                            )
                            
                        }) {
                            Text("Belum Dicek")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(!isSudahDicek ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(!isSudahDicek ? primaryPurple : Color.clear)
                                .cornerRadius(22)
                        }
                        
                        Button(action: { isSudahDicek = true
                        
                            controller.getCeklistbulanan(
                            branchID: selectedBranchID,
                            taskDate: dateToString(tempSelectedDate),
                            buttoncek: 1
                           )
                            
                        }) {
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
                        Text("Area/Lantai")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Cycle/m")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Bulan Pengecekan")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Status")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .background(Color.fromRGBAString(self.controller.main_table_col_color))
                   
                    
                    Divider()
                     
                   
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            ForEach(self.trxOnCurrentPage) { item in
                               
                                HStack(spacing: 0) {
            
                    
                                    Button {
                                        self.controller.pageName = "INPUT INPEKSI"
                                      
                                    } label: {
                                        Image(systemName: "qrcode")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(primaryPurple)
                                            .frame(width: 60, alignment: .leading)
                                    }
                                     
                               
                                    
                                    Text(item.asset_id)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(width: 90, alignment: .leading)
                                     
                                    Text(item.asset_name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    Text(item.asset_location)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    
                                    Text(item.scheduletaskdetil_cycle)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    
                                    Text(item.curr_periode_start)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    
                                    Text(item.curr_status)
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.task_date = formatter.string(from: Date())
        }
    }
}

 
func dateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
