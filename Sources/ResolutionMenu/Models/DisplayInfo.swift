import CoreGraphics

/// Represents a connected display and its properties.
struct DisplayInfo {
    let id: CGDirectDisplayID
    let index: Int
    let name: String
    let currentWidth: Int
    let currentHeight: Int
    let currentRefreshRate: Double
    let currentIsHiDPI: Bool
    let resolutionGroups: [ResolutionGroup]
}

extension DisplayInfo {
    /// Returns unique logical resolutions available for this display.
    var uniqueLogicalResolutions: [LogicalResolution] {
        let allLogical = resolutionGroups.map { LogicalResolution(width: $0.width, height: $0.height) }
        return Array(Set(allLogical)).sorted()
    }
    
    /// Finds a specific resolution group matching the logical resolution and HiDPI status.
    func resolutionGroup(for logical: LogicalResolution, isHiDPI: Bool) -> ResolutionGroup? {
        resolutionGroups.first {
            $0.width == logical.width &&
            $0.height == logical.height &&
            $0.isHiDPI == isHiDPI
        }
    }
    
    /// Finds any resolution group for a logical resolution, preferring the current HiDPI status.
    func anyResolutionGroup(for logical: LogicalResolution) -> ResolutionGroup? {
        // Prefer matching current HiDPI status
        if let match = resolutionGroup(for: logical, isHiDPI: currentIsHiDPI) {
            return match
        }
        // Fallback to any available group with these dimensions
        return resolutionGroups.first {
            $0.width == logical.width &&
            $0.height == logical.height
        }
    }
}

