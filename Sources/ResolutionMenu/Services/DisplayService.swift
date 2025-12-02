import Cocoa
import CoreGraphics

/// Service responsible for low-level display management and resolution switching.
final class DisplayService {
    
    // MARK: - Public API
    
    /// Fetches information about all connected displays.
    func getAllDisplays() -> [DisplayInfo] {
        NSScreen.screens.enumerated().compactMap { index, screen in
            createDisplayInfo(from: screen, index: index + 1)
        }
    }
    
    /// Changes the resolution of a specific display.
    /// - Returns: Boolean indicating success.
    @discardableResult
    func changeResolution(for displayID: CGDirectDisplayID, to resolution: DisplayResolution) -> Bool {
        let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 1)
        defer { config.deallocate() }
        
        guard CGBeginDisplayConfiguration(config) == .success else { return false }
        
        let result = CGConfigureDisplayWithDisplayMode(config.pointee, displayID, resolution.mode, nil)
        
        if result == .success {
            return CGCompleteDisplayConfiguration(config.pointee, .permanently) == .success
        } else {
            CGCancelDisplayConfiguration(config.pointee)
            return false
        }
    }
    
    // MARK: - Private Helpers
    
    private func createDisplayInfo(from screen: NSScreen, index: Int) -> DisplayInfo? {
        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return nil
        }
        
        let currentMode = CGDisplayCopyDisplayMode(displayID)
        let width = currentMode?.width ?? 0
        let height = currentMode?.height ?? 0
        let refreshRate = currentMode?.refreshRate ?? 0.0
        
        let currentIsHiDPI = currentMode.map { DisplayResolution(from: $0).isHiDPI } ?? false
        
        return DisplayInfo(
            id: displayID,
            index: index,
            name: getDisplayName(for: displayID, screen: screen),
            currentWidth: width,
            currentHeight: height,
            currentRefreshRate: refreshRate,
            currentIsHiDPI: currentIsHiDPI,
            resolutionGroups: fetchResolutionGroups(for: displayID)
        )
    }
    
    private func getDisplayName(for displayID: CGDirectDisplayID, screen: NSScreen) -> String {
        if #available(macOS 10.15, *) {
            return screen.localizedName
        }
        return "Display"
    }
    
    private func fetchResolutionGroups(for displayID: CGDirectDisplayID) -> [ResolutionGroup] {
        let allModes = fetchAllDisplayModes(for: displayID)
        let resolutions = allModes.map { DisplayResolution(from: $0) }
        
        // Group by unique key (width, height, isHiDPI)
        let grouped = Dictionary(grouping: resolutions) { res in
            "\(res.width)x\(res.height)_\(res.isHiDPI)"
        }
        
        // Convert to ResolutionGroup objects
        let resolutionGroups = grouped.compactMap { (_, modes) -> ResolutionGroup? in
            guard let first = modes.first else { return nil }
            
            let sortedRates = modes.sorted { $0.refreshRate > $1.refreshRate }
            
            return ResolutionGroup(
                width: first.width,
                height: first.height,
                isHiDPI: first.isHiDPI,
                refreshRates: sortedRates
            )
        }
        
        // Sort: Width DESC, Height DESC, HiDPI First
        return resolutionGroups.sorted { g1, g2 in
            if g1.width != g2.width { return g1.width > g2.width }
            if g1.height != g2.height { return g1.height > g2.height }
            return g1.isHiDPI && !g2.isHiDPI
        }
    }
    
    private func fetchAllDisplayModes(for displayID: CGDirectDisplayID) -> [CGDisplayMode] {
        // Request all modes including low-resolution (non-HiDPI) duplicates
        let options = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary?
        
        guard let modeList = CGDisplayCopyAllDisplayModes(displayID, options) else {
            return []
        }
        
        var modes: [CGDisplayMode] = []
        let count = CFArrayGetCount(modeList)
        var seenKeys = Set<String>()
        
        for i in 0..<count {
            guard let mode = unsafeBitCast(CFArrayGetValueAtIndex(modeList, i), to: CGDisplayMode?.self) else { continue }
            
            // Deduplicate exact matches based on physical and logical dimensions + refresh rate
            let key = "\(mode.width)x\(mode.height)_\(mode.pixelWidth)x\(mode.pixelHeight)_\(Int(mode.refreshRate))"
            if !seenKeys.contains(key) {
                seenKeys.insert(key)
                modes.append(mode)
            }
        }
        return modes
    }
}
