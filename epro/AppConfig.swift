import Foundation
import SwiftData

@Model
class AppConfig {
    var bussinessunit_id: String
    
    init(bussinessunit_id: String) {
        self.bussinessunit_id = bussinessunit_id
    }
}
 
