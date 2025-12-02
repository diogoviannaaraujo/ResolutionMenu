import Foundation

/// Represents a logical resolution (width x height) for grouping purposes.
struct LogicalResolution: Hashable, Comparable {
    let width: Int
    let height: Int
    
    static func < (lhs: LogicalResolution, rhs: LogicalResolution) -> Bool {
        if lhs.width != rhs.width {
            return lhs.width > rhs.width // Largest first
        }
        return lhs.height > rhs.height
    }
    
    var description: String {
        "\(width) × \(height)"
    }
}

