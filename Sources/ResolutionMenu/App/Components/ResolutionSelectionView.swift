import SwiftUI

struct ResolutionSelectionView: View {
    let display: DisplayInfo
    var viewModel: AppViewModel
    let onDismiss: () -> Void
    
    @State private var showAll = false
    
    var body: some View {
        List {
            ForEach(displayedResolutions, id: \.self) { logical in
                ResolutionRow(display: display, resolution: logical, viewModel: viewModel, onSelect: onDismiss)
            }
            
            if shouldShowMoreButton {
                Button {
                    withAnimation {
                        showAll = true
                    }
                } label: {
                    Text("Show More...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var allResolutions: [LogicalResolution] {
        display.uniqueLogicalResolutions
    }
    
    private var hasPinned: Bool {
        allResolutions.contains { viewModel.isPinned(displayID: display.id, resolution: $0) }
    }
    
    private var shouldShowMoreButton: Bool {
        hasPinned && !showAll
    }

    var displayedResolutions: [LogicalResolution] {
        let all = allResolutions
        
        // Sorting logic: Pinned first, then size descending
        let sorted = all.sorted { r1, r2 in
            let p1 = viewModel.isPinned(displayID: display.id, resolution: r1)
            let p2 = viewModel.isPinned(displayID: display.id, resolution: r2)
            if p1 != p2 { return p1 }  // Pinned first
            return r1 < r2  // Default sort (size descending)
        }
        
        if !hasPinned || showAll {
            return sorted
        } else {
            return sorted.filter { resolution in
                let isPinned = viewModel.isPinned(displayID: display.id, resolution: resolution)
                let isCurrent = (resolution.width == display.currentWidth && resolution.height == display.currentHeight)
                return isPinned || isCurrent
            }
        }
    }
}

