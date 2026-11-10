import ActivityKit
import Foundation

struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state updated during the workout
        var currentExercise: String
        var completedSets: Int
        var totalSets: Int
        var startTimeMillis: Int64
        var isResting: Bool
        var restTimeRemaining: Int
        
        // Next uncompleted set details
        var currentSetNumber: Int?
        var totalExerciseSets: Int?
        var currentSetWeight: Double?
        var currentSetReps: Int?
        
        // Used to identify which set to complete
        var nextSetExerciseId: String?
        var nextSetId: String?
    }

    // Static properties of the workout
    var workoutName: String
}
