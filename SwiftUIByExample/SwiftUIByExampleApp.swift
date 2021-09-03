import SwiftUI

@main
struct SwiftUIByExampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: Model())
                .environmentObject(DataStore()
                                    .insert(data:(1...10_000)
                                                .map { Item(id: $0, _value: $0) }
                                           ))
        }
    }
}
