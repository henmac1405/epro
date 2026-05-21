
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

struct Task : Codable {
    var task_id : String
    var task_date : String
    var task_description : String
    var task_descriptionafter : String
    var task_type : String
    var task_ismonthly : Int
    var asset_id : String
}
