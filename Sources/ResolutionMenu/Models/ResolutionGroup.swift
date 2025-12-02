import CoreGraphics

/// Groups resolutions with the same dimensions but different refresh rates.
struct ResolutionGroup {
    let width: Int
    let height: Int
    let isHiDPI: Bool
    let refreshRates: [DisplayResolution]
    
    /// Returns the best (highest) refresh rate option.
    var bestRefreshRate: DisplayResolution {
        refreshRates.max(by: { $0.refreshRate < $1.refreshRate }) ?? refreshRates[0]
    }
    
    /// Finds a resolution with a specific refresh rate, or returns the best one.
    func resolution(withRefreshRate targetRate: Double) -> DisplayResolution {
        refreshRates.first(where: { abs($0.refreshRate - targetRate) < 0.1 }) ?? bestRefreshRate
    }
}

