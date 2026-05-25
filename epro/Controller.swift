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
    @Published var imageUrl = "https://api.trans-property.com/assets/upload/themes/"
    
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
    
    
    
    //Model
    @Published var dataUser : [DataUser] = []
    @Published var dataBranch : [DataBranch] = [] 
    @Published var themes : [Themes] = []
    
    @Published var loginSlider : [LoginSlider] = []
    @Published var mainSlider : [MainSlider] = []
    @Published var task : [Task] = []
    @Published var taskList: [Task] = []
    
    @Published var tasktype : [TaskType] = []
    @Published var parttype : [PartType] = []
    
    @Published var selectedTaskForEdit: Task? = nil
    
    

    
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
    
    // MARK: - API ----------------------------------------------------------------------------------------------
      
//    func getAPIKey() {
//        
//        let apiname = "apikey/show"
//        
//        self.signature = generateSignature(secretKey: branch_id)
//        print("signature : \(self.signature)")
//        
//        guard let url = URL(string: self.url_api + apiname) else { return }
//        print(url)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let body: [String: Any] = ["":""]
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        request.setValue(self.signature, forHTTPHeaderField: "SECRETKEY")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            
//            
//            if let error = error {
//                print("Error:", error.localizedDescription)
//                self.showAlert = true
//                self.responseMessage = "Error : \(error.localizedDescription)"
//                self.isLoading = false
//                return
//            }
//            
//            guard let data = data else { return }
//            
//            
//            let json = JSON(data)
//            let message = json["message"].stringValue
//            print(message)
//            print(json["state"])
//            
//            DispatchQueue.main.async {
//                self.responseMessage = message
//                if (json["state"] == true){
//                    self.apiKey = json["data"].stringValue
//                    print(self.apiKey)
//                    self.isCorrect = true
//                    self.showAlert = false
//                    self.getToken()
//                } else {
//                    self.isCorrect = false
//                    self.responseMessage = message
//                    self.showAlert = true
//                }
//            }
//        }.resume()
//    }
    
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

    
    func getThemes() {
        let timestampWithZ = ISO8601DateFormatter().string(from: Date())
        let apiname = "apptheme/theme"
        
        guard let url = URL(string: self.url_api + apiname) else { return }
        print(url)
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
                self.responseMessage = message
                
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
                        self.task.append(Task(task_id: task_id, task_date : rawDateString, task_description: task_description, task_descriptionafter: task_descriptionafter, task_type: task_type, task_ismonthly: task_ismonthly, asset_id: asset_id, branch_id: branch_id))
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
        
        self.isLoading = true
         
         
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

}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
