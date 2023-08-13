import Foundation

final class StatisticsViewModel {
    @Observable
    private(set)var trackersCompletedTotaly: [TrackerRecord] = []
    
    private let model: StatisticsModel
    
    init(model: StatisticsModel) {
        self.model = model
    }
    
    func getCompletedTrackersCount() {
        let traclersRecords = model.getTrackersRecordCount()
        trackersCompletedTotaly = traclersRecords
    }
}
