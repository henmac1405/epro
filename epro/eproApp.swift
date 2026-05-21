 
import SwiftUI
import SwiftData
@main
struct eproApp: App {
    @StateObject var controller = Controller()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(controller)
        }.modelContainer(for: [AppConfig.self])
    }
}
