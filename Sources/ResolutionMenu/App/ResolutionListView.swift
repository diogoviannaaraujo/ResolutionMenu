import SwiftUI

struct ResolutionListView: View {
    var viewModel: AppViewModel
    @State private var currentRoute: NavigationRoute? = nil
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            if let route = currentRoute {
                VStack(spacing: 0) {
                    DetailHeaderView(title: route.title) {
                        withAnimation { currentRoute = nil }
                    }
                    
                    Divider()
                    
                    switch route {
                    case .resolution(let displayId):
                        if let display = viewModel.displays.first(where: { $0.id == displayId }) {
                            ResolutionSelectionView(display: display, viewModel: viewModel) {
                                withAnimation { currentRoute = nil }
                            }
                        }
                    case .refreshRate(let displayId):
                        if let display = viewModel.displays.first(where: { $0.id == displayId }) {
                            RefreshRateSelectionView(display: display, viewModel: viewModel) {
                                withAnimation { currentRoute = nil }
                            }
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            } else {
                VStack(spacing: 0) {
                    MenuHeaderView()
                    
                    Divider()
                    
                    Form {
                        ForEach(viewModel.displays, id: \.id) { display in
                            Section(display.name) {
                                DisplayControlsView(display: display, viewModel: viewModel, currentRoute: $currentRoute)
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .scrollContentBackground(.hidden)
                    
                    Divider()
                    
                    MenuFooterView(onSettings: {
                        openWindow(id: "settings")
                        NSApp.activate(ignoringOtherApps: true)
                    }, onQuit: {
                        viewModel.quitApp()
                    })
                }
                .transition(.move(edge: .leading))
            }
        }
        .frame(width: 320)
        .animation(.easeInOut(duration: 0.25), value: currentRoute)
    }
}
