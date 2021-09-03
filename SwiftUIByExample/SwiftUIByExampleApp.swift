import SwiftUI

@main
struct SwiftUIByExampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataStore()
                                    .insert(data:(1...100_000)
                                                .map { Item(id: $0, _value: $0) }
                                           ))
        }
    }
}
