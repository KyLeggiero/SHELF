#  SHELF • Simple Heckin Entity Library Framework

A simple object-storage solution



## “It's heckin simple!”

The design goal of SHELF is to be as simple to use (or implement yourself!) as possible.

For example, here's an entire functioning SwiftUI app which saves & stores the user's name.

```swift
import SwiftUI
import SHELF



struct App: SwiftUI.App {
    
    @ShelfModel
    private var shelfModel
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.shelfModel, shelfModel)
        }
    }
}


struct ContentView: View {
    
    @ShelfQuery
    private var user: User
    
    @Environment(\.shelfModel)
    private var shelfModel
    
    var body: some View {
        VStack {
            Text("Hello, \(user.name)!")
                .font(.largeTitle)
            
            TextField("Change my name", value: $user.name)
            
            Button("Forget me!") {
                shelfModel.delete(user)
            }
        }
    }
}



struct User: ShelfData {
    let id: UUID
    var name: String = ""
    
    
    init(id: UUID) {
        self.id = id
    }
}
```
