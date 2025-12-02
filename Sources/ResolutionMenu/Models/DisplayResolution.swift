import CoreGraphics

/// Represents a display resolution with its properties.
struct DisplayResolution {
    let width: Int
    let height: Int
    let refreshRate: Double
    let mode: CGDisplayMode
    let isHiDPI: Bool
    
    init(from mode: CGDisplayMode) {
        self.width = mode.width
        self.height = mode.height
        self.refreshRate = mode.refreshRate
        self.mode = mode
        
        // Check for HiDPI scaling
        let pixelWidth = Double(mode.pixelWidth)
        let pixelHeight = Double(mode.pixelHeight)
        let logicalWidth = Double(mode.width)
        let logicalHeight = Double(mode.height)
        
        // Consider HiDPI if pixel dimensions significantly exceed logical dimensions
        self.isHiDPI = (pixelWidth / logicalWidth > 1.0) || (pixelHeight / logicalHeight > 1.0)
    }
    
    /// Returns a formatted string representation of the resolution dimensions.
    func dimensionsString(showLowResLabel: Bool = false) -> String {
        var result = "\(width) × \(height)"
        if showLowResLabel && !isHiDPI {
            result += " (low resolution)"
        }
        return result
    }
    
    /// Returns a formatted refresh rate string.
    var refreshRateString: String {
        refreshRate > 0 ? "\(Int(refreshRate))Hz" : "Default"
    }
}
