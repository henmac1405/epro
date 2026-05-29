
import Foundation
import SwiftUI
import SwiftData



struct DataUser : Codable {
    var user_id: String
    var user_name: String
    var user_password: String
    var branch_id: String
}

struct DataBranch : Codable {
    var branch_id: String
    var branch_name: String
    var branch_address: String
    var branch_telp: String
    var branch_city: String
}

struct TaskType : Codable {
    var tasktype_id: String
    var tasktype_name: String
}

struct PartType : Codable {
    var parttype_id: String
    var parttype_name: String
}



struct AssetFind : Codable {
    var asset_id: String
    var asset_capacity: String
    var asset_location: String
    var asset_image: String
    var asset_isdaily: Int
    var asset_ismonthly: Int
    var brand_name: String
    var branch_id: String
    var vendor_name: String
    var kode_barcode: String
}

struct Themes : Codable {
    var theme_id: Int
    var login_body_color: String
    var main_menu_color: String 
    var login_text2_color: String
    var main_table_col_color: String
    var bussinessunit_id: String 
    var main_image_header: String
    var main_background_image: String
    //var main_slider_images: String
    var login_logo: String
    var main_header_color: String
    //var login_slider_images: String
    var main_bottom_nav_color: String
    var login_text1_color: String
}

struct LoginSlider : Codable {
    var login_slider_images : String
}

struct MainSlider : Codable {
    var main_slider_images : String
}

struct Tasks : Codable {
    var task_id : String
    var task_date : String
    var task_description : String
    var task_descriptionafter : String
    var task_type : String
    var task_ismonthly : Int
    var asset_id : String
    var branch_id : String
}

struct TaskDetil : Codable {
    var task_id : String
    var task_description : String
    var task_date : String
    var task_descriptionafter : String
    var task_type : String
    var task_ismonthly : Int
    var asset_id : Int
    var asset_name : String
    var asset_type : String
    var asset_location : String
    var asset_image : String
    var kode_barcode : String
    var brand_name : String
    var branch_id : String 
}

struct TaskImage : Identifiable {
    let id = UUID()
    var task_id : String
    var taskimage_type : String
    var taskimage_line : Int
    var taskimage_name : String
    var branch_id : String
    var image : UIImage
}

//struct TaskPartType : Codable {
//    var task_id : String
//    var taskpart_name : String
//    var taskpart_line : Int
//    var taskpart_type : String
//    var taskpart_qty : Int
//    var taskpart_descr : String
//    var branch_id : String
//}

struct SparepartItem: Identifiable {
    let id = UUID()
    var taskpart_name: String
    var taskpart_qty: Int
    var taskpart_type: String
    var taskpart_descr: String
}

struct AssetItem: Identifiable, Decodable {
    var id = UUID()
    var asset_id: String
    
    var scheduletask_id: String
    var periode: String
    var scheduletask_type: String
    var kode_barcode: String
    var generate_line: Int32
    var scheduletaskdetil_line: Int32
    var curr_periode_start: String
    var task_id: String
    var branch_id: String
    var curr_periode_end: String
    var asset_name: String
    var asset_location: String
    var scheduletaskdetil_cycle: String
    var curr_status: String
}

struct DataBranchUser: Codable {
    var branch_id: String
    var branch_name: String
}


struct TaskScheduleDetil:  Decodable {
    var task_id: String
    var taskdetil_line: Int
    var activity: String
    var value: String
}


struct AssetHistory: Identifiable, Decodable {
    var id = UUID()
    var asset_id: String
    var asset_name: String
    var asset_location: String
    var task_date: String
    var task_type: String
    var task_type_name: String
    var task_description: String
    var created_by: String
    var branch_id: String
    var branch_name: String
    var scheduletask_id: String
    var scheduletaskdetil_line: Int32
    var generate_line: Int32
    var kode_barcode: String
    var task_id: String

}

