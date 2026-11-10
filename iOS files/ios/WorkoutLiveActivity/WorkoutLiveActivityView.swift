import WidgetKit
import SwiftUI
import ActivityKit

struct WorkoutLiveActivityView: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            // Lock screen / Banner UI
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(.purple)
                        Text(context.state.currentExercise)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isResting {
                        Text("Resting")
                            .font(.headline)
                            .foregroundColor(.orange)
                    } else {
                        Text("\(context.state.completedSets)/\(context.state.totalSets) Sets")
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.purple)
            } compactTrailing: {
                if context.state.isResting {
                    Text(timerInterval(for: context.state.restTimeRemaining), style: .timer)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                } else {
                    let startTime = Date(timeIntervalSince1970: TimeInterval(context.state.startTimeMillis) / 1000.0)
                    Text(startTime, style: .timer)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                }
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.purple)
            }
        }
    }
    
    // Helper to create a timer range for countdown
    func timerInterval(for remainingSeconds: Int) -> ClosedRange<Date> {
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(remainingSeconds))
        return now...end
    }
}

struct LockScreenView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Workout Name & Timer
            HStack {
                Text(context.attributes.workoutName)
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                
                if context.state.isResting {
                    let now = Date()
                    let end = now.addingTimeInterval(TimeInterval(context.state.restTimeRemaining))
                    Text(now...end, style: .timer)
                        .font(.headline)
                        .foregroundColor(.orange)
                } else {
                    let startTime = Date(timeIntervalSince1970: TimeInterval(context.state.startTimeMillis) / 1000.0)
                    Text(startTime, style: .timer)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            // Middle: Exercise info
            if context.state.isResting {
                Text("Resting before next set...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Text(context.state.currentExercise)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(context.state.completedSets)/\(context.state.totalSets) Sets Done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Next Set Details
                if let setNum = context.state.currentSetNumber,
                   let weight = context.state.currentSetWeight,
                   let reps = context.state.currentSetReps {
                    Text("Set \(setNum): \(String(format: "%.1f", weight)) × \(reps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bottom: Action Buttons
            HStack {
                if context.state.isResting {
                    Link(destination: URL(string: "irontrack://skipRest")!) {
                        Text("Skip Rest")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                } else if let exId = context.state.nextSetExerciseId, let setId = context.state.nextSetId {
                    Link(destination: URL(string: "irontrack://completeSet?ex=\(exId)&set=\(setId)")!) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Complete Set")
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }
                Spacer()
                Link(destination: URL(string: "irontrack://openApp")!) {
                    Text("Open App")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

struct ExpandedBottomView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !context.state.isResting {
                if let setNum = context.state.currentSetNumber,
                   let weight = context.state.currentSetWeight,
                   let reps = context.state.currentSetReps {
                    Text("Set \(setNum): \(String(format: "%.1f", weight)) × \(reps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                if context.state.isResting {
                    Link(destination: URL(string: "irontrack://skipRest")!) {
                        Text("Skip Rest")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                } else if let exId = context.state.nextSetExerciseId, let setId = context.state.nextSetId {
                    Link(destination: URL(string: "irontrack://completeSet?ex=\(exId)&set=\(setId)")!) {
                        Text("Complete Set")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}
