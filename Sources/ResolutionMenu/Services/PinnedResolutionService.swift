import Foundation
import CoreGraphics

class PinnedResolutionService {
    private let key = "PinnedResolutions"
    
    struct PinnedItem: Codable, Hashable {
        let displayID: UInt32
        let width: Int
        let height: Int
    }
    
    func getPinnedResolutions() -> Set<PinnedItem> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode(Set<PinnedItem>.self, from: data) else {
            return []
        }
        return items
    }
    
    func save(pinned: Set<PinnedItem>) {
        if let data = try? JSONEncoder().encode(pinned) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

