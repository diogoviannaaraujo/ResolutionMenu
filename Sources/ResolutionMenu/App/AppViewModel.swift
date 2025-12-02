import Foundation
import SwiftUI
import Observation
import ServiceManagement

/// ViewModel for the menu bar app, managing display state.
@MainActor
@Observable
class AppViewModel {
    var displays: [DisplayInfo] = []
    var pinnedResolutions: Set<PinnedResolutionService.PinnedItem> = []
    var startOnBoot: Bool = false {
        didSet {
            updateStartOnBoot()
        }
    }
    
    private let displayService = DisplayService()
    private let pinnedService = PinnedResolutionService()
    
    init() {
        refreshDisplays()
        pinnedResolutions = pinnedService.getPinnedResolutions()
        startOnBoot = SMAppService.mainApp.status == .enabled
    }
    
    private func updateStartOnBoot() {
        do {
            if startOnBoot {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("Failed to update start on boot: \(error)")
            // Revert the state if operation failed
            startOnBoot = SMAppService.mainApp.status == .enabled
        }
    }
    
    func refreshDisplays() {
        displays = displayService.getAllDisplays()
    }
    
    func togglePin(for displayID: CGDirectDisplayID, resolution: LogicalResolution) {
        let item = PinnedResolutionService.PinnedItem(displayID: displayID, width: resolution.width, height: resolution.height)
        if pinnedResolutions.contains(item) {
            pinnedResolutions.remove(item)
        } else {
            pinnedResolutions.insert(item)
        }
        pinnedService.save(pinned: pinnedResolutions)
    }
    
    func isPinned(displayID: CGDirectDisplayID, resolution: LogicalResolution) -> Bool {
        pinnedResolutions.contains(PinnedResolutionService.PinnedItem(displayID: displayID, width: resolution.width, height: resolution.height))
    }
    
    func changeResolution(displayID: CGDirectDisplayID, resolution: DisplayResolution) {
        if displayService.changeResolution(for: displayID, to: resolution) {
            // Small delay to allow system to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.refreshDisplays()
            }
        } else {
            // Handle error (could add an error state published property)
            print("Failed to change resolution")
        }
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
