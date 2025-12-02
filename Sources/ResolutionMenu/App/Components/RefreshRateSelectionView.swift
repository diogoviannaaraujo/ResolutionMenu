import SwiftUI

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

