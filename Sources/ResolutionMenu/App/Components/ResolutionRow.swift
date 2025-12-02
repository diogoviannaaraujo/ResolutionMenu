import SwiftUI

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

