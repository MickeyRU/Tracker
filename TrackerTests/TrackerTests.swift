import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackersViewControllerLightSnapshot() throws {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkSnapshot() throws {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
