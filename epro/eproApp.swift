 
import SwiftUI 
@main
struct eproApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @StateObject var controller = Controller()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
    }
}
