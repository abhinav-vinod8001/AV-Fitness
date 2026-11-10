import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    let controller = engineBridge.flutterViewController
    methodChannel = FlutterMethodChannel(name: "com.irontrack/live_activity", binaryMessenger: controller.binaryMessenger)
    
    methodChannel?.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "startLiveActivity", "updateLiveActivity":
        self?.handleUpdateActivity(call: call, result: result)
      case "stopLiveActivity":
        self?.handleStopActivity(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }
  
  // Handle Deep Links from the Live Activity buttons
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.scheme == "irontrack" {
      if url.host == "skipRest" {
        methodChannel?.invokeMethod("onSkipRest", arguments: nil)
        return true
      } else if url.host == "completeSet" {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            var exerciseId: String? = nil
            var setId: String? = nil
            for item in queryItems {
                if item.name == "ex" { exerciseId = item.value }
                if item.name == "set" { setId = item.value }
            }
            if let ex = exerciseId, let set = setId {
                methodChannel?.invokeMethod("onCompleteSet", arguments: ["exerciseId": ex, "setId": set])
            }
        }
        return true
      }
    }
    return super.application(app, open: url, options: options)
  }

  private func handleUpdateActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let workoutName = args["workoutName"] as? String,
          let currentExercise = args["currentExercise"] as? String,
          let completedSets = args["completedSets"] as? Int,
          let totalSets = args["totalSets"] as? Int,
          let startTimeMillis = args["startTimeMillis"] as? Int64,
          let isResting = args["isResting"] as? Bool,
          let restTimeRemaining = args["restTimeRemaining"] as? Int else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
      return
    }

    if #available(iOS 16.1, *) {
      let contentState = WorkoutAttributes.ContentState(
        currentExercise: currentExercise,
        completedSets: completedSets,
        totalSets: totalSets,
        startTimeMillis: startTimeMillis,
        isResting: isResting,
        restTimeRemaining: restTimeRemaining,
        currentSetNumber: args["currentSetNumber"] as? Int,
        totalExerciseSets: args["totalExerciseSets"] as? Int,
        currentSetWeight: args["currentSetWeight"] as? Double,
        currentSetReps: args["currentSetReps"] as? Int,
        nextSetExerciseId: args["nextSetExerciseId"] as? String,
        nextSetId: args["nextSetId"] as? String
      )
      
      let attributes = WorkoutAttributes(workoutName: workoutName)
      let content = ActivityContent(state: contentState, staleDate: nil)

      if let currentActivity = Activity<WorkoutAttributes>.activities.first {
        Task {
          await currentActivity.update(content)
        }
      } else {
        do {
          _ = try Activity<WorkoutAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil
          )
        } catch {
          print("Error starting Live Activity: \(error.localizedDescription)")
        }
      }
      result(true)
    } else {
      result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.1+", details: nil))
    }
  }

  private func handleStopActivity(result: @escaping FlutterResult) {
    if #available(iOS 16.1, *) {
      Task {
        for activity in Activity<WorkoutAttributes>.activities {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
        result(true)
      }
    } else {
      result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.1+", details: nil))
    }
  }
}
