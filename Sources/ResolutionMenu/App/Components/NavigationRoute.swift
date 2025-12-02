import SwiftUI
import CoreGraphics

enum NavigationRoute: Hashable {
    case resolution(CGDirectDisplayID)
    case refreshRate(CGDirectDisplayID)
    
    var title: String {
        switch self {
        case .resolution: return "Resolution"
        case .refreshRate: return "Refresh Rate"
        }
    }
}

