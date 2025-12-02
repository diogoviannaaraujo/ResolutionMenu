import SwiftUI

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

