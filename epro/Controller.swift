import Foundation
import SwiftData
import SwiftUICore
import UIKit
import SwiftyJSON
import CryptoKit
import Combine

class Controller : ObservableObject{
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var isCorrect = true
    @Published var url_api = "https://apidev.trans-property.com/index.php/api/v1/"
    @Published var imageUrl = "https://apidev.trans-property.com/assets/upload/"
    @Published var imageAssetUrl = "https://eprodev.trans-property.com/assets/upload/maintenance/"
    @Published var isProgress = false
    
    
    @Published var showAlert = false
    @Published var SecretKeyNoLog = ""
    @Published var companyID = ""
    @Published var responseMessage = ""
    @Published var signature = ""
    @Published var apiKey = ""
    @Published var token = ""
    @Published var LoadingDescr = "Loading..."
    @Published var pageName = "Home"
    @Published var version = "1.0.7"
    @Published var lustupdate = "20 Mei 2026"
    @Published var newVersion = false
    @Published var input_type = ""
    //themes
    @Published var theme_id = 0
    @Published var login_logo = "LOGO_69f36bd92b565.png"
    @Published var login_body_color = "255,255,255,0"
    @Published var login_text1_color = "255,255,255,0"
    @Published var login_text2_color = "255,255,255,0"
    
    @Published var main_menu_color = ""
    @Published var main_image_header = ""
    @Published var main_background_image = ""
    @Published var main_header_color = ""
    @Published var main_bottom_nav_color = ""
    @Published var main_table_col_color = ""
    
     
    //User
    @Published var username = ""
    @Published var user_password = ""
    @Published var user_fullname = ""
    @Published var bussinessunit_id = ""
    @Published var bussinessunit_id_old = ""
    @Published var bussinessunit_name = ""
    @Published var strukturunit_id = ""
    @Published var channel_id = ""
    @Published var region_id = ""
    @Published var branch_id = ""
    @Published var branch_name = ""
    @Published var user_changepassword = ""
    @Published var user_changepasswordbaru = ""
    
    //Model
    @Published var dataUser : [DataUser] = []
    @Published var dataBranch : [DataBranch] = [] 
    @Published var themes : [Themes] = []
    
    @Published var loginSlider : [LoginSlider] = []
    @Published var mainSlider : [MainSlider] = []
    @Published var task : [Tasks] = []
    @Published var taskList: [Tasks] = []
    @Published var taskDetil : [TaskDetil] = []
    @Published var taskImage : [TaskImage] = []
//    @Published var taskPartType : [TaskPartType] = []
    @Published var sparepartList: [SparepartItem] = []
    
    @Published var tasktype : [TaskType] = []
    @Published var parttype : [PartType] = []

    @Published var assetsList: [AssetItem] = []
    @Published var dataBranchuser : [DataBranchUser] = []

    
    @Published var selectedTaskForEdit: Tasks? = nil
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastStyle: ToastStyle = .success
    
    enum ToastStyle {
        case success, error
    }

    
    
    // MARK: - Function ----------------------------------------------------------------------------------------------
    
    func filterBranch(branchid: String) -> String {
        if branchid.isEmpty {
            return ""
        }
        if let foundBranch = dataBranch.first(where: { $0.branch_id == branchid }) {
            return foundBranch.branch_name
        }
        print("Branch Tidak Ditemukan")
        return ""
    }
    
    func filteTaskType(id: String) -> String {
        if id.isEmpty {
            return ""
        }
        if let foundData = tasktype.first(where: { $0.tasktype_id == id }) {
            return foundData.tasktype_name
        }
        print("Task Type Tidak Ditemukan")
        return ""
    }
    
    func filtePartType(id: String) -> String {
        if id.isEmpty {
            return ""
        }
        if let foundData = parttype.first(where: { $0.parttype_id == id }) {
            return foundData.parttype_name
        }
        print("Part Type Tidak Ditemukan")
        return ""
    }
    
    func getFormattedDateTimeFull() -> String {
        let formatter = DateFormatter()
        
        
        formatter.locale = Locale(identifier: "id_ID")
        
        
        formatter.dateFormat = "EEEE, dd MMMM yyyy HH:mm:ss zzz"
        
        return formatter.string(from: Date())
    }
    
    func getFormattedDateDDMMMMYYYY() -> String {
        let formatter = DateFormatter()
        
        
        formatter.locale = Locale(identifier: "id_ID")
        
        
        formatter.dateFormat = "dd MMMM yyyy"
        
        return formatter.string(from: Date())
    }
    
    func getFormattedDateYYYYMMdd() -> String {
        let formatter = DateFormatter()
        
        
        formatter.locale = Locale(identifier: "id_ID")
        
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: Date())
    }
    
    func getFormattedTime() -> String {
        let formatter = DateFormatter()
        
        
        formatter.locale = Locale(identifier: "id_ID")
        
        
        formatter.dateFormat = "HH:mm:ss"
        
        return formatter.string(from: Date())
    }
    
    func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    func generateToken() -> String {
        
        let headerDict = ["typ": "API", "alg": "SHA256"]
        guard let headerData = try? JSONEncoder().encode(headerDict) else { return "" }
        let headerBase64 = headerData.base64EncodedString()
        
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestampStr = formatter.string(from: Date())
        
        let timestampBase64 = Data(timestampStr.utf8).base64EncodedString()
        print("timestamp : \(timestampBase64)")
        
        //let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        
        
        let randomHex = generateRandomHexString(length: 20)
        let payloadBase64 = Data(randomHex.utf8).base64EncodedString()
        
        
        let combined = "\(headerBase64).\(timestampBase64).\(payloadBase64)"
        let finalToken = Data(combined.utf8).base64EncodedString()
        
        return finalToken
    }
    
    func generateRandomHexString(length: Int) -> String {
        let letters = "0123456789abcdef"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func generateSignature(secretKey: String) -> String {
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        
        let headerDict = ["typ": "API", "alg": "SHA256"]
        guard let headerData = try? JSONEncoder().encode(headerDict) else { return "" }
        let headerBase64 = headerData.base64EncodedString()
        
        let payloadBase64 = Data(secretKey.utf8).base64EncodedString()
        
        let tsBase64 = Data(timestampWithZ.utf8).base64EncodedString()
        
        let combinedSecretKey = "\(headerBase64).\(payloadBase64).\(tsBase64)"
        
        return Data(combinedSecretKey.utf8).base64EncodedString()
    }
     

    func SaveConfig(context: ModelContext) {
        do {
            try context.delete(
                        model: AppConfig.self
                    )
            try context.save()
            
            let newData = AppConfig(bussinessunit_id: self.bussinessunit_id)
            
            context.insert(newData)
            try context.save()
            
            print("bussinessunit_id dengan id \(self.bussinessunit_id) berhasil diperbarui.")
            
        } catch {
            print("Gagal memperbarui data bussinessunit_id : \(error.localizedDescription)")
        }
    }
    
    func toastShow(message: String, style: ToastStyle) {
        self.toastMessage = message
        self.toastStyle = style
        
        withAnimation(.spring()) {
            self.showToast = true
        }
        
        // Otomatis hilangkan Toast setelah 3 detik
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut) {
                self.showToast = false
            }
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Menghitung rasio baru agar gambar tidak gepeng (tetap proporsional)
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Membuat konteks grafis baru untuk menggambar ulang foto dalam ukuran kecil
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }

    // MARK: - API ----------------------------------------------------------------------------------------------
       
    
    func getToken() {
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        let apiname = "token/show"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = ["":""]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print(message)
            print(json["state"])
            DispatchQueue.main.async {
                self.responseMessage = message
                if (json["state"] == true) {
                    self.token = json["data"].stringValue
                    self.isCorrect = true
                    self.getThemes()
                    
                    self.isLoggedIn = true
                    
                } else {
                    self.isCorrect = false
                    self.isLoading = false
                    self.isLoggedIn = false
                    self.showAlert = true
                }
            }
        }.resume()
    }
  
    func getVersion(context: ModelContext) {
        let apiname = "app/version"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.SecretKeyNoLog = self.generateToken()
        
        request.setValue(self.SecretKeyNoLog, forHTTPHeaderField: "SECRETKEY")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "businessunitid", value: self.bussinessunit_id),
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print(json)
            print(message)
            print(json["state"])
             
            DispatchQueue.main.async {
                self.themes.removeAll()
                self.loginSlider.removeAll()
                self.mainSlider.removeAll()
                
                self.responseMessage = message
                if (json["state"] == true) {
                    self.isLoading = false
                    let dataObj = json["data"]
                    
                    if self.version == dataObj["appbuild_version"].stringValue {
                        self.getLogin(context: context)
                    } else {
                        self.responseMessage = "Bukan Versi terbaru, segera update aplikasi anda"
                        print("error : \(self.responseMessage)")
                        self.isCorrect = false
                        self.isLoading = false
                        self.showAlert = true
                    }
                     
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    
    func getLogin(context: ModelContext) {
         
        let apiname = "auth/login-new-version"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
         
        self.SecretKeyNoLog = self.generateToken()
        
        print("username : \(self.username)")
        print("password : \(self.user_password)")
        print("SecretKeyNoLog : \(self.SecretKeyNoLog)")
         
        request.setValue(self.SecretKeyNoLog, forHTTPHeaderField: "SECRETKEY")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: self.username),
            URLQueryItem(name: "password", value: self.user_password),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
            DispatchQueue.main.async {
                self.responseMessage = message
                if (json["state"] == true) {
                    self.isCorrect = true
                    self.showAlert = false
                    self.isLoading = false
                    
                    let dataObj = json["data"]
                    
                    self.channel_id = dataObj["user_default_channel_id"].stringValue
                    self.region_id = dataObj["region_id"].stringValue
                    self.branch_id = dataObj["branch_id"].stringValue
                    self.branch_name = dataObj["branch_name"].stringValue
                    self.bussinessunit_id = dataObj["bussinessunit_id"].stringValue
                    self.bussinessunit_name = dataObj["bussinessunit_name"].stringValue
                    self.user_fullname = dataObj["user_fullname"].stringValue
                    self.apiKey = dataObj["api"].stringValue
                    
                    print("user_fullname : \(self.user_fullname)")
                    print("branch_name : \(self.branch_name)")
                    print("bussinessunit_name : \(self.bussinessunit_name)")
                    print("apiKey : \(self.apiKey)")
                    
                    self.SaveConfig(context: context)
                    
                    self.getToken()
                     
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.isLoggedIn = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    
    
    func getChangePassword() {
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        let apiname = "auth/change-password"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
   
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: self.username),
            URLQueryItem(name: "password", value: self.user_changepassword),
            URLQueryItem(name: "newpassword", value: self.user_changepasswordbaru),
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
  
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let error = error {
                print("Error:", error.localizedDescription)
                self.showAlert = true
                self.responseMessage = "Error : \(error.localizedDescription)"
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print(json)

            print(message)
            print(json["state"])
            
            
            DispatchQueue.main.async {
                self.responseMessage = message
                if (json["state"] == true){
                   
                    self.showAlert = true
                    self.responseMessage = message
                    self.user_password = self.user_changepasswordbaru
                    
           
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    
    
    func getThemes() {
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        let apiname = "apptheme/theme"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        print("tutup")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
   
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "businessunitid", value: self.bussinessunit_id),
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print(json)

            print(message)
            print(json["state"])
            DispatchQueue.main.async {
                self.themes.removeAll()
                self.loginSlider.removeAll()
                self.mainSlider.removeAll()
                
                self.responseMessage = message
                if (json["state"] == true) {
                    self.isLoading = false
                    let dataObj = json["data"]
                    
                    self.theme_id = dataObj["theme_id"].intValue
                    self.login_body_color = dataObj["login_body_color"].stringValue
                    self.main_menu_color = dataObj["main_menu_color"].stringValue
                    self.login_text2_color = dataObj["login_text2_color"].stringValue
                    self.main_table_col_color = dataObj["main_table_col_color"].stringValue
                    self.bussinessunit_id = dataObj["bussinessunit_id"].stringValue
                    self.main_image_header = dataObj["main_image_header"].stringValue
                    self.main_background_image = dataObj["main_background_image"].stringValue
                    self.login_logo = dataObj["login_logo"].stringValue
                    self.main_header_color = dataObj["main_header_color"].stringValue
                    self.main_bottom_nav_color = dataObj["main_bottom_nav_color"].stringValue
                    self.login_text1_color = dataObj["login_text1_color"].stringValue
                    print("login_logo : \(self.login_logo)")
                    
                    self.themes.append(Themes(
                        theme_id: self.theme_id,
                        login_body_color: self.login_body_color,
                        main_menu_color: self.main_menu_color,
                        login_text2_color: self.login_text2_color,
                        main_table_col_color: self.main_table_col_color,
                        bussinessunit_id: self.bussinessunit_id,
                        main_image_header: self.main_image_header,
                        main_background_image: self.main_background_image,
                        login_logo: self.login_logo,
                        main_header_color: self.main_header_color,
                        main_bottom_nav_color: self.main_bottom_nav_color,
                        login_text1_color: self.login_text1_color
                    ))
                    
                    for (_, subJson):(String, JSON) in dataObj["login_slider_images"] {
                        let imgString = subJson.stringValue
                        print("login_slider_images : \(imgString)")
                        if !imgString.isEmpty {
                            self.loginSlider.append(LoginSlider(login_slider_images: imgString))
                        }
                    }
                    
                    for (_, subJson):(String, JSON) in dataObj["main_slider_images"] {
                        let imgString = subJson.stringValue
                        print("main_slider_images : \(imgString)")
                        if !imgString.isEmpty {
                            self.mainSlider.append(MainSlider(main_slider_images: imgString))
                        }
                    }
                     
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    
    func getInpeksiByUser(filter : String, taskid : String, taskdate : String,  tasktype : String) {
        let apiname = "inpeksi/show-byuser"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
        
        print("username : \(self.username)")
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: self.username),
            URLQueryItem(name: "task_id", value: taskid),
            URLQueryItem(name: "task_date", value: taskdate),
            URLQueryItem(name: "task_type", value: tasktype),
            URLQueryItem(name: "filter", value: filter),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
            DispatchQueue.main.async {
                self.task.removeAll()
                
                
                if (json["state"] == true) {
                    self.isLoading = false
                    
                    for (_, subJson):(String, JSON) in json["data"] {
                        let task_id = subJson["task_id"].stringValue
                        let task_description = subJson["task_description"].stringValue
                        let task_descriptionafter = subJson["task_descriptionafter"].stringValue
                        let task_type = subJson["task_type"].stringValue
                        let task_ismonthly = subJson["task_ismonthly"].intValue
                        let asset_id = subJson["asset_id"].stringValue
                        let rawDateString = subJson["task_date"].stringValue
                        let branch_id = subJson["branch_id"].stringValue
                        
                        print("task_id \(task_id)")
                        self.task.append(Tasks(task_id: task_id, task_date : rawDateString, task_description: task_description, task_descriptionafter: task_descriptionafter, task_type: task_type, task_ismonthly: task_ismonthly, asset_id: asset_id, branch_id: branch_id))
                    }
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    func getInpeksiByUserByID(taskid : String, completion: @escaping () -> Void) {
        let apiname = "task/show-detil"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isProgress = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "task_id", value: taskid),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isProgress = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
            DispatchQueue.main.async {
                self.taskDetil.removeAll()
//                self.taskPartType.removeAll()
                self.sparepartList.removeAll()
                self.taskImage.removeAll()
                self.responseMessage = message
                self.isProgress = false
                
                if (json["state"] == true) {
                    
                    let dataObj = json["data"]
                     
                    let task_id = dataObj["task_id"].stringValue
                    let task_description = dataObj["task_description"].stringValue
                    let task_date = dataObj["task_date"].stringValue
                    let task_descriptionafter = dataObj["task_descriptionafter"].stringValue
                    let task_type = dataObj["task_type"].stringValue
                    let task_ismonthly = dataObj["task_ismonthly"].intValue
                    let asset_id  = dataObj["asset_id"].intValue
                    let asset_name = dataObj["asset_name"].stringValue
                    let asset_type = dataObj["asset_type"].stringValue
                    let asset_location = dataObj["asset_location"].stringValue
                    let asset_image = dataObj["asset_image"].stringValue
                    let kode_barcode = dataObj["kode_barcode"].stringValue
                    let brand_name = dataObj["brand_name"].stringValue
                    let branch_id = dataObj["branch_id"].stringValue
                    
                    self.taskDetil.append(TaskDetil(
                        task_id: task_id,
                        task_description: task_description,
                        task_date: task_date,
                        task_descriptionafter: task_descriptionafter,
                        task_type: task_type,
                        task_ismonthly: task_ismonthly,
                        asset_id: asset_id,
                        asset_name: asset_name,
                        asset_type: asset_type,
                        asset_location: asset_location,
                        asset_image: asset_image,
                        kode_barcode: kode_barcode,
                        brand_name: brand_name,
                        branch_id: branch_id
                        ))

                    print("kode_barcode \(kode_barcode)")
                    for (_, subJson):(String, JSON) in dataObj["image"] {
                        
                        let task_id = subJson["task_id"].stringValue
                        let taskimage_type = subJson["taskimage_type"].stringValue
                        let taskimage_line = subJson["taskimage_line"].intValue
                        let taskimage_name = subJson["taskimage_name"].stringValue
                        let branch_id = subJson["branch_id"].stringValue
                        print("taskimage_name \(taskimage_name)")
                        let urlGambarNetwork = self.imageUrl + "maintenance/" + taskimage_name
                        
                        Task {
                            if let img = await self.downloadUIImage(from: urlGambarNetwork) {
                                withAnimation {
                                    self.taskImage.append(
                                        TaskImage(
                                            task_id: task_id,
                                            taskimage_type: taskimage_type,
                                            taskimage_line: taskimage_line,
                                            taskimage_name: taskimage_name,
                                            branch_id: branch_id,
                                            image: img
                                        )
                                    )
                                }
                            }
                        }

                        
                    }
                    
                    for (_, subJson):(String, JSON) in dataObj["part"] {
                        let task_id = subJson["task_id"].stringValue
                        let taskpart_name = subJson["taskpart_name"].stringValue
                        let taskpart_line = subJson["taskpart_line"].intValue
                        let taskpart_type = subJson["taskpart_type"].stringValue
                        let taskpart_qty = subJson["taskpart_qty"].intValue
                        let taskpart_descr = subJson["taskpart_descr"].stringValue
                        let branch_id = subJson["branch_id"].stringValue
                        
                        print("taskpart_name \(taskpart_name)")
//                        self.taskPartType.append(TaskPartType(task_id: task_id, taskpart_name: taskpart_name, taskpart_line: taskpart_line, taskpart_type: taskpart_type, taskpart_qty: taskpart_qty,taskpart_descr: taskpart_descr,  branch_id: branch_id))
                        
                        self.sparepartList.append(SparepartItem(taskpart_name: taskpart_name, taskpart_qty: taskpart_qty,taskpart_type: taskpart_type, taskpart_descr: taskpart_descr))
                        
                        
                    }
                    completion()
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isProgress = false
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    func saveInpeksi(task_id : String, task_date : String, task_description : String, task_descriptionafter : String, task_type : String, task_ismonthly : Int,  asset_id : String, branch_id : String, completion: @escaping () -> Void) {
        let apiname = "task/save"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        var queryItems = [
                URLQueryItem(name: "task_id", value: task_id),
                URLQueryItem(name: "task_date", value: task_date),
                URLQueryItem(name: "task_description", value: task_description),
                URLQueryItem(name: "task_descriptionafter", value: task_descriptionafter),
                URLQueryItem(name: "task_type", value: task_type),
                URLQueryItem(name: "task_ismonthly", value: String(task_ismonthly)),
                URLQueryItem(name: "asset_id", value: asset_id),
                URLQueryItem(name: "branch_id", value: branch_id),
                URLQueryItem(name: "username", value: self.username),
            ]
            
            // 2. BARU: Lakukan perulangan (loop) untuk memasukkan isi array spareparts ke queryItems
            for (index, part) in sparepartList.enumerated() {
                queryItems.append(URLQueryItem(name: "taskpart[\(index)][taskpart_name]", value: part.taskpart_name))
                queryItems.append(URLQueryItem(name: "taskpart[\(index)][taskpart_qty]", value: String(part.taskpart_qty)))
                queryItems.append(URLQueryItem(name: "taskpart[\(index)][taskpart_type]", value: part.taskpart_type))
                queryItems.append(URLQueryItem(name: "taskpart[\(index)][taskpart_descr]", value: part.taskpart_descr))
            }
            
            // Masukkan semua query items yang digabung ke komponen URL
        components.queryItems = queryItems
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
            DispatchQueue.main.async {
                self.responseMessage = message
                self.showAlert = true
                self.isLoading = false
                if (json["state"] == true) {
                    completion() 
                } else {
                }
            }
        }.resume()
    }
    
    func submitTasksWithImages(
        task_id: String,
        task_date: String,
        task_description: String,
        task_descriptionafter: String,
        task_type: String,
        task_ismonthly: Int,
        asset_id: String,
        branch_id: String,
        spareparts: [SparepartItem],
        completion: @escaping ([String: Any]) -> Void
    ) {
        // 1. Bersihkan URL, JANGAN kirim query param di URL lagi agar PHP tidak bingung
        var apiname = ""
        if self.input_type == "NEW" {
              apiname = "task/save"
        } else if self.input_type == "EDIT" {
              apiname = "task/update"
        }
        
        self.isProgress = true
        
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let completeUrl = URL(string: self.url_api + apiname) else { return }
        print(completeUrl)
        var request = URLRequest(url: completeUrl)
        request.httpMethod = "POST"
        
        // Set Header Otentikasi Security
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        // Set Boundary Multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 2. PINDAHKAN SEMUA PARAMETER TEKS KE SINI (MULTIPART BODY)
        let textParameters: [String: String] = [
            "task_id": task_id,
            "task_date": task_date,
            "task_description": task_description,
            "task_descriptionafter": task_descriptionafter,
            "task_type": task_type,
            "task_ismonthly": String(task_ismonthly),
            "asset_id": asset_id,        // Sekarang dikirim via POST Body, CodeIgniter PASTI bisa baca
            "branch_id": branch_id,
            "username": self.username
        ]
        print(textParameters)
        // Bungkus semua teks ke format multipart biner
        for (key, value) in textParameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 3.  Sparepart (Kebutuhan Suku Cadang)
        let sparepartArrayMap = spareparts.map { item -> [String: Any] in
            return [
                "taskpart_name": item.taskpart_name,
                "taskpart_qty": item.taskpart_qty,
                "taskpart_type": Int(item.taskpart_type) ?? 0,
                "taskpart_descr": item.taskpart_descr
            ]
        }
        print(sparepartArrayMap)
        
        let jsonString: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: sparepartArrayMap, options: []),
           let convertedString = String(data: jsonData, encoding: .utf8) {
            jsonString = convertedString
        } else {
            jsonString = "[]"
        }

        // PERBAIKAN: Menyusun baris multipart biner secara presisi dan bersih
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"taskpart\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(jsonString)\r\n".data(using: .utf8)!) // Pastikan ada \r\n di akhir nilai string JSON

        
//         4. Masukkan File Gambar dari Array taskImage
        for (index, taskImg) in self.taskImage.enumerated() {
            let gambarKecil = resizeImage(image: taskImg.image, targetSize: CGSize(width: 1024, height: 1024))
                 
            guard let imageData = gambarKecil.jpegData(compressionQuality: 0.3) else { continue }
                  
            let namaFieldGrup: String
            if taskImg.taskimage_type == "2" {
                namaFieldGrup = "foto_after[]"
            } else {
                namaFieldGrup = "foto_before[]"
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(namaFieldGrup)\"; filename=\"\(taskImg.taskimage_name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        // =========================================================================

        
        // Penutup Akhir Baris Multipart Body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 5. Eksekusi pengiriman data ke server
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Gagal Koneksi: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProgress = false
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // 1. Ambil data biner dan pastikan tidak kosong
                if let dataTemp = data {
                    do {
                        // 2. Dekode data biner menjadi Dictionary Swift [String: Any]
                        if let jsonResponse = try JSONSerialization.jsonObject(with: dataTemp, options: []) as? [String: Any] {
                            
                            // 3. Ekstrak nilai dari properti JSON backend Anda
                            let statusSukses = jsonResponse["state"] as? Bool ?? false
                            let pesanServer = jsonResponse["message"] as? String ?? "Tidak ada pesan"
                            let kodeServer = jsonResponse["code"] as? Int ?? httpResponse.statusCode
                            
                            completion(jsonResponse)
                            
                            DispatchQueue.main.async {
                                self.isProgress = false
                            }
                            
                            
                            print("================ RESPONS JSON SERVER ================")
                            print("State: \(statusSukses)")
                            print("Code: \(kodeServer)")
                            print("Message: \(pesanServer)")
                            print("====================================================")
                            
                            // 4. Cek validasi berdasarkan state dari backend, bukan cuma status code HTTP
                            if statusSukses && (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                print("🎉 BERHASIL! Server SQL Server sukses menyimpan seluruh data!")
                                
                                // Lakukan aksi sukses di Main Thread (UI Thread)
                                DispatchQueue.main.async {
                                    //self.taskImage.removeAll()
                                    // Anda bisa mengosongkan list sparepart juga di sini jika diperlukan:
                                    // self.sparepartList.removeAll()
                                }
                            } else {
                                print("Gagal Validasi Backend: \(pesanServer)")
                            }
                        }
                    } catch {
                        // Menangkap error jika respons dari server bukan format JSON yang valid (misal teks HTML error)
                        if let rawResponseString = String(data: dataTemp, encoding: .utf8) {
                            print("Respons Bukan JSON (Raw Text): \(rawResponseString)")
                        } else {
                            print("Gagal mengurai JSON: \(error.localizedDescription)")
                        }
                    }
                }
            }

        }.resume()
    }
    
    func verifyAssetData(
        asset_id: String,
        branch_id: String,
        isavailable: String,
        fotoVerifikasi: UIImage?,
        completion: @escaping ([String: Any]) -> Void
    ) {
        let apiname = "assetverify/save"
        
        self.isProgress = true
        
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set Header Security & Otentikasi
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        // Set Boundary Multipart Form-Data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 2. Susun Semua Parameter Teks POST yang Diminta CodeIgniter
        let textParameters: [String: String] = [
            "asset_id": asset_id,
            "username": self.username,
            "branch_id": branch_id,
            "isavailable": isavailable
        ]
        
        for (key, value) in textParameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 3. Masukkan File Gambar Tunggal ke Field Berlabel name="file" (Jika asset_id tersedia / isavailable == "1")
        if isavailable == "1", let uiImage = fotoVerifikasi {
            // Optimasi: Perkecil resolusi & kompresi foto verifikasi agar hemat harddisk server dan di bawah batas max_size (5MB)
            let gambarKecil = resizeImage(image: uiImage, targetSize: CGSize(width: 1024, height: 1024))
            if let imageData = gambarKecil.jpegData(compressionQuality: 0.4) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                // PERBAIKAN UTAMA: Menggunakan name="file" sesuai perintah backend $this->upload->do_upload('file')
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"verifikasi_asset_\(Date().timeIntervalSince1970).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 4. Jalankan Request Network
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(["state": false, "message": error.localizedDescription])
                self.isProgress = false
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, let dataTemp = data {
                self.isProgress = false
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: dataTemp, options: []) as? [String: Any] {
                        completion(jsonResponse)
                    }
                } catch {
                    completion(["state": false, "message": "Gagal mengurai respons server."])
                }
            }
        }.resume()
    }

    
    func submitVerifyAssetWithImages(
        asset_isavailable: Int,
        asset_id: String,
        branch_id: String,
        image : UIImage,
        completion: @escaping ([String: Any]) -> Void
    ) {
        // 1. Bersihkan URL, JANGAN kirim query param di URL lagi agar PHP tidak bingung
         
        let apiname = "assetverify/save"
        
        self.isProgress = true
        
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let completeUrl = URL(string: self.url_api + apiname) else { return }
        print(completeUrl)
        var request = URLRequest(url: completeUrl)
        request.httpMethod = "POST"
        
        // Set Header Otentikasi Security
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        // Set Boundary Multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 2. PINDAHKAN SEMUA PARAMETER TEKS KE SINI (MULTIPART BODY)
        let textParameters: [String: String] = [
            "isavailable": String(asset_isavailable),
            "asset_id": asset_id,
            "branch_id": branch_id,
            "username": self.username
        ]
        print(textParameters)
        // Bungkus semua teks ke format multipart biner
        for (key, value) in textParameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
         
         
//         4. Masukkan File Gambar dari Array taskImage
        for (index, taskImg) in self.taskImage.enumerated() {
            let gambarKecil = resizeImage(image: taskImg.image, targetSize: CGSize(width: 1024, height: 1024))
                 
            guard let imageData = gambarKecil.jpegData(compressionQuality: 0.3) else { continue }
                  
            let namaFieldGrup: String
            if taskImg.taskimage_type == "2" {
                namaFieldGrup = "foto_after[]"
            } else {
                namaFieldGrup = "foto_before[]"
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(namaFieldGrup)\"; filename=\"\(taskImg.taskimage_name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        // =========================================================================

        
        // Penutup Akhir Baris Multipart Body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 5. Eksekusi pengiriman data ke server
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Gagal Koneksi: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProgress = false
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // 1. Ambil data biner dan pastikan tidak kosong
                if let dataTemp = data {
                    do {
                        // 2. Dekode data biner menjadi Dictionary Swift [String: Any]
                        if let jsonResponse = try JSONSerialization.jsonObject(with: dataTemp, options: []) as? [String: Any] {
                            
                            // 3. Ekstrak nilai dari properti JSON backend Anda
                            let statusSukses = jsonResponse["state"] as? Bool ?? false
                            let pesanServer = jsonResponse["message"] as? String ?? "Tidak ada pesan"
                            let kodeServer = jsonResponse["code"] as? Int ?? httpResponse.statusCode
                            
                            completion(jsonResponse)
                            
                            DispatchQueue.main.async {
                                self.isProgress = false 
                            }
                            
                            
                            print("================ RESPONS JSON SERVER ================")
                            print("State: \(statusSukses)")
                            print("Code: \(kodeServer)")
                            print("Message: \(pesanServer)")
                            print("====================================================")
                            
                            // 4. Cek validasi berdasarkan state dari backend, bukan cuma status code HTTP
                            if statusSukses && (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                print("🎉 BERHASIL! Server SQL Server sukses menyimpan seluruh data!")
                                
                                // Lakukan aksi sukses di Main Thread (UI Thread)
                                DispatchQueue.main.async {
                                    //self.taskImage.removeAll()
                                    // Anda bisa mengosongkan list sparepart juga di sini jika diperlukan:
                                    // self.sparepartList.removeAll()
                                }
                            } else {
                                print("Gagal Validasi Backend: \(pesanServer)")
                            }
                        }
                    } catch {
                        // Menangkap error jika respons dari server bukan format JSON yang valid (misal teks HTML error)
                        if let rawResponseString = String(data: dataTemp, encoding: .utf8) {
                            print("Respons Bukan JSON (Raw Text): \(rawResponseString)")
                        } else {
                            print("Gagal mengurai JSON: \(error.localizedDescription)")
                        }
                    }
                }
            }

        }.resume()
    }

 
    
    func getBranchByUser() {
        let apiname = "branch/branch-user"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
         
        print("username : \(self.username)")
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: self.username),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.dataBranch.removeAll()
                self.responseMessage = message
                
                if (json["state"] == true) {
                    self.isLoading = false
                    
                    for (_, subJson):(String, JSON) in json["data"] {
                        let branch_id = subJson["branch_id"].stringValue
                        let branch_name = subJson["branch_name"].stringValue
                        
                        print("branch_name \(branch_name)")
                        self.dataBranch.append(DataBranch(branch_id: branch_id, branch_name : branch_name, branch_address: "", branch_telp: "", branch_city: ""))
                    }
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    
    func getTaskType() {
        let apiname = "task/type"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
        
        print("username : \(self.username)")
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "PARAM", value: "0"),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
            
            DispatchQueue.main.async {
                self.tasktype.removeAll()
                self.responseMessage = message
                
                if (json["state"] == true) {
                    self.isLoading = false
                    
                    for (_, subJson):(String, JSON) in json["data"] {
                        let tasktype_id = subJson["setting_value"].stringValue
                        let tasktype_name = subJson["setting_value2"].stringValue
                        
                        print("tasktype_name \(tasktype_name)")
                        self.tasktype.append(TaskType(tasktype_id: tasktype_id, tasktype_name: tasktype_name))
                    }
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    func getPartType() {
        let apiname = "task/parttype"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
        
        print("username : \(self.username)")
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "PARAM", value: "0"),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.parttype.removeAll()
                self.responseMessage = message
                
                if (json["state"] == true) {
                    self.isLoading = false
                    
                    for (_, subJson):(String, JSON) in json["data"] {
                        let parttype_id = subJson["setting_value"].stringValue
                        let parttype_name = subJson["setting_value2"].stringValue
                        
                        print("parttype_name \(parttype_name)")
                        self.parttype.append(PartType(parttype_id: parttype_id, parttype_name: parttype_name))
                    }
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    func findAssetbyUser(searchText : String, completion: @escaping (JSON?) -> Void) {
        let apiname = "asset/scan-byuser-new"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isProgress = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "barcode", value: searchText),
            URLQueryItem(name: "username", value: self.username),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isProgress = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.responseMessage = message
                self.isProgress = false
                completion(json)
                if (json["state"] == true) {
                    
                    self.responseMessage = message
                    print("sukses : \(self.responseMessage)")
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                }
            }
        }.resume()
    }
    
    func findVerifyAsset(searchText : String, completion: @escaping (JSON?) -> Void) {
        let apiname = "assetverify/scan"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isProgress = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "barcode", value: searchText),
            URLQueryItem(name: "username", value: self.username),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isProgress = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.responseMessage = message
                self.isProgress = false
                completion(json)
                if (json["state"] == true) {
                    
                    self.responseMessage = message
                    print("sukses : \(self.responseMessage)")
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                }
            }
        }.resume()
    }
    
    func findHistoryAsset(searchText : String) {
        let apiname = "assethistory/show"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isProgress = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "barcode", value: searchText),
            URLQueryItem(name: "username", value: self.username),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isProgress = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.responseMessage = message
                self.isProgress = false
                if (json["state"] == true) {
                    
                    
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                }
            }
        }.resume()
    }
    
    func getBranchAll() {
        let apiname = "branch/show"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
         
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "branch_id", value: ""),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.dataBranch.removeAll()
                self.responseMessage = message
                
                if (json["state"] == true) {
                    self.isCorrect = true
                    self.isLoading = false
                    
                    for (_, subJson):(String, JSON) in json["data"] {
                        let branch_id = subJson["branch_id"].stringValue
                        let branch_name = subJson["setting_value2"].stringValue
                        
                        print("branch_name \(branch_name)")
                        self.dataBranch.append(DataBranch(branch_id: branch_id, branch_name: branch_name, branch_address: "", branch_telp: "", branch_city: ""))
                    }
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    func getBranchbyID(branch_id : String, completion: @escaping (JSON?) -> Void) {
        let apiname = "branch/show"
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.isLoading = true
        
        print("branch_id : \(branch_id)")
         
        request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue(self.token, forHTTPHeaderField: "TOKEN")
        request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "branch_id", value: branch_id),
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error2 :", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.responseMessage = "Error : \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else { return }
            
            let json = JSON(data)
            let message = json["message"].stringValue
            print("json : \(json)")
            print("message : \(message)")
            print(json["state"])
              
            DispatchQueue.main.async {
                self.responseMessage = message
                
                if (json["state"] == true) {
                    self.isCorrect = true
                    self.isLoading = false
                    completion(json) 
                    
                } else {
                    self.responseMessage = message
                    print("error : \(self.responseMessage)")
                    self.isCorrect = false
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    
    
    func getbranch() {
        
        print("cobaaaa")

            let timestampWithZ = ISO8601DateFormatter().string(from: Date())
            let apiname = "monthlyschedule/getuserbranch"

            guard let url = URL(string: self.url_api + apiname) else { return }

            print(url)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
            request.setValue(self.token, forHTTPHeaderField: "TOKEN")
            request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")

            var components = URLComponents()

            components.queryItems = [
                URLQueryItem(name: "username", value: self.username),
            ]

            request.httpBody = components.query?.data(using: .utf8)

            request.setValue(
                "application/x-www-form-urlencoded",
                forHTTPHeaderField: "Content-Type"
            )

            URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    DispatchQueue.main.async {
                        print("Error2 :", error.localizedDescription)
                        self.showAlert = true
                        self.responseMessage = "Error : \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let data = data else { return }
                
                let json = JSON(data)
                let message = json["message"].stringValue
                print("json : \(json)")
                print("message : \(message)")
                print(json["state"])
                
                

                DispatchQueue.main.async {
                    self.dataBranchuser.removeAll()
                    self.responseMessage = message
                    if (json["state"] == true){
                        self.isCorrect = true
                        self.showAlert = false
                        self.isLoading = false
                        for (_, subJson):(String, JSON) in json["data"] {
                            let branch_id = subJson["branch_id"].stringValue
                            let branch_name = subJson["branch_name"].stringValue
                          
                            print("branch_id \(branch_name)")
                            self.dataBranchuser.append(DataBranchUser(branch_id: branch_id, branch_name : branch_name))
                        }
                         
                        
                         
                         
                    } else {
                        self.responseMessage = message
                        print("error : \(self.responseMessage)")
                        self.isCorrect = false
                        self.isLoading = false
                        self.showAlert = true
                    }
                }

            }.resume()
        }
    
    
    
    
    func getCeklistbulanan(branchID: String, taskDate: String,buttoncek: Int32) {

            let timestampWithZ = ISO8601DateFormatter().string(from: Date())
            let apiname = "monthlyschedule/show"

            guard let url = URL(string: self.url_api + apiname) else { return }

            print(url)

        
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            request.setValue(self.apiKey, forHTTPHeaderField: "APIKEY")
            request.setValue(self.token, forHTTPHeaderField: "TOKEN")
            request.setValue(timestampWithZ, forHTTPHeaderField: "TIMESTAMP")

            var components = URLComponents()

            components.queryItems = [
                URLQueryItem(name: "username", value: self.username),
                URLQueryItem(name: "task_date", value: taskDate),
                URLQueryItem(name: "branch_id", value: branchID),
                URLQueryItem(name: "buttoncek", value: String(buttoncek))
                
            ]
        


            request.httpBody = components.query?.data(using: .utf8)

            request.setValue(
                "application/x-www-form-urlencoded",
                forHTTPHeaderField: "Content-Type"
            )

            URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    DispatchQueue.main.async {
                        print("Error2 :", error.localizedDescription)
                        self.showAlert = true
                        self.responseMessage = "Error : \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let data = data else { return }
                
                let json = JSON(data)
                let message = json["message"].stringValue
                print("json : \(json)")
                print("message : \(message)")
                print(json["state"])
                
                
                DispatchQueue.main.async {
                    self.assetsList.removeAll()
                    
                    self.responseMessage = message
                    if (json["state"] == true){
                        self.isCorrect = true
                        self.showAlert = false
                        self.isLoading = false
                        for (_, subJson):(String, JSON) in json["data"] {
                            let asset_id = subJson["asset_id"].stringValue
                            let asset_name = subJson["asset_name"].stringValue
                            let asset_location = subJson["asset_location"].stringValue
                            let scheduletaskdetil_cycle = subJson["scheduletaskdetil_cycle"].stringValue
                            let curr_periode_start = subJson["curr_periode_start"].stringValue
                            let curr_status = subJson["curr_status"].stringValue
                              
                              
                            self.assetsList.append(AssetItem(asset_id: asset_id,
                                                             asset_name : asset_name,
                                                             asset_location : asset_location,
                                                             scheduletaskdetil_cycle : scheduletaskdetil_cycle,
                                                             curr_periode_start : curr_periode_start,
                                                             curr_status : curr_status
                                                            ))
                        }
                         
                        
                         
                         
                    } else {
                        self.responseMessage = message
                        print("error : \(self.responseMessage)")
                        self.isCorrect = false
                        self.isLoading = false
                        self.showAlert = true
                    }
                }
                
                
                
                
//                do {
//
//                    // kalau response langsung array
//                    let result = try JSONDecoder().decode([AssetItem].self, from: data)
//
//                    DispatchQueue.main.async {
//                        self.assetsList = result
//                    }
//
//                } catch {
//
//                    print("DECODE ERROR :", error)
//
//                    if let jsonString = String(data: data, encoding: .utf8) {
//                        print(jsonString)
//                    }
//                }

            }.resume()
        }
    
    
    
    
    func downloadUIImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            // Mengunduh data dari internet
            let (data, _) = try await URLSession.shared.data(from: url)
            // Mengonversi Data menjadi UIImage
            return UIImage(data: data)
        } catch {
            print("Error download gambar: \(error)")
            return nil
        }
    }


    
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}



