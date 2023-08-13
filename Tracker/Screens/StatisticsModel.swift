import Foundation

final class StatisticsModel {
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    init() {
        self.trackerRecordStore = TrackerRecordStore(delegate: nil)
    }
    
    func getTrackersRecordCount() -> [TrackerRecord] {
        trackerRecordStore.getCompletedTrackers()
    }    
}
