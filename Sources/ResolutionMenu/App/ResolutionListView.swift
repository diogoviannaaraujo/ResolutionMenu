import SwiftUI

struct ResolutionListView: View {
    var viewModel: AppViewModel
    @State private var currentRoute: NavigationRoute? = nil
    
    var body: some View {
        ZStack {
            if let route = currentRoute {
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Button(action: {
                            withAnimation { currentRoute = nil }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .fontWeight(.semibold)
                                Text("Back")
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(route.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        // Placeholder to balance title
                        Color.clear.frame(width: 50, height: 20)
                    }
                    .padding()
                    .background(Color(nsColor: .windowBackgroundColor))
                    
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
                    
                    HStack {
                        Spacer()
                        Button("Quit") {
                            viewModel.quitApp()
                        }
                        .keyboardShortcut("q")
                        .buttonStyle(.plain)
                        .padding()
                    }
                    .background(Color(nsColor: .windowBackgroundColor))
                }
                .transition(.move(edge: .leading))
            }
        }
        .frame(width: 320)
        .animation(.easeInOut(duration: 0.25), value: currentRoute)
    }
}

enum NavigationRoute: Hashable {
    case resolution(CGDirectDisplayID)
    case refreshRate(CGDirectDisplayID)
    
    var title: String {
        switch self {
        case .resolution: return "Resolution"
        case .refreshRate: return "Refresh Rate"
        }
    }
}

struct DisplayControlsView: View {
    let display: DisplayInfo
    var viewModel: AppViewModel
    @Binding var currentRoute: NavigationRoute?
    
    var body: some View {
        // Resolution Link
        Button {
            withAnimation {
                currentRoute = .resolution(display.id)
            }
        } label: {
            HStack {
                Text("Resolution")
                Spacer()
                Text("\(display.currentWidth) × \(display.currentHeight)")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        
        // Refresh Rate Link
        Button {
            withAnimation {
                currentRoute = .refreshRate(display.id)
            }
        } label: {
            HStack {
                Text("Refresh Rate")
                Spacer()
                Text("\(Int(display.currentRefreshRate)) Hz")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        
        // Hi-DPI Toggle only if there is a counterpart resolution group
        let currentLogical = LogicalResolution(
            width: display.currentWidth, height: display.currentHeight)
        let counterpart = display.resolutionGroup(
            for: currentLogical, isHiDPI: !display.currentIsHiDPI)
        
        if counterpart != nil {
            Toggle(
                "Hi-DPI",
                isOn: Binding(
                    get: { display.currentIsHiDPI },
                    set: { _ in
                        if let targetGroup = counterpart {
                            viewModel.changeResolution(
                                displayID: display.id, resolution: targetGroup.bestRefreshRate)
                        }
                    }
                ))
        }
    }
}

struct ResolutionSelectionView: View {
    let display: DisplayInfo
    var viewModel: AppViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        List {
            ForEach(sortedResolutions, id: \.self) { logical in
                ResolutionRow(display: display, resolution: logical, viewModel: viewModel, onSelect: onDismiss)
            }
        }
    }
    
    var sortedResolutions: [LogicalResolution] {
        let all = display.uniqueLogicalResolutions
        return all.sorted { r1, r2 in
            let p1 = viewModel.isPinned(displayID: display.id, resolution: r1)
            let p2 = viewModel.isPinned(displayID: display.id, resolution: r2)
            if p1 != p2 { return p1 }  // Pinned first
            return r1 < r2  // Default sort (size descending)
        }
    }
}

struct RefreshRateSelectionView: View {
    let display: DisplayInfo
    var viewModel: AppViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        List {
            let currentLogical = LogicalResolution(
                width: display.currentWidth, height: display.currentHeight)
            if let group = display.resolutionGroup(
                for: currentLogical, isHiDPI: display.currentIsHiDPI)
            {
                ForEach(group.refreshRates, id: \.refreshRate) { res in
                    Button {
                        viewModel.changeResolution(displayID: display.id, resolution: res)
                        onDismiss()
                    } label: {
                        HStack {
                            Text(res.refreshRateString)
                            Spacer()
                            if abs(res.refreshRate - display.currentRefreshRate) < 0.1 {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("No refresh rates available")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ResolutionRow: View {
    let display: DisplayInfo
    let resolution: LogicalResolution
    var viewModel: AppViewModel
    let onSelect: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        let isCurrent =
            (resolution.width == display.currentWidth && resolution.height == display.currentHeight)
        let isPinned = viewModel.isPinned(displayID: display.id, resolution: resolution)
        
        HStack {
            Button {
                if let group = display.anyResolutionGroup(for: resolution) {
                    viewModel.changeResolution(
                        displayID: display.id, resolution: group.bestRefreshRate)
                    onSelect()
                }
            } label: {
                HStack {
                    Text(resolution.description)
                    Spacer()
                    if isCurrent {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Pin Button
            Button {
                withAnimation {
                    viewModel.togglePin(for: display.id, resolution: resolution)
                }
            } label: {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.caption)
                    .foregroundColor(isPinned ? .accentColor : .secondary)
                    .opacity(isPinned || isHovering ? 1.0 : 0.2)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
