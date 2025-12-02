import SwiftUI

@main
struct ResolutionMenuApp: App {
    @State private var viewModel = AppViewModel()
    
    var body: some Scene {
        MenuBarExtra("Resolution Menu", systemImage: "display") {
            ResolutionListView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

