//
//  WorkoutsModel.swift
//  zoomies
//
//  Created by Jakub Michalak on 29/01/2023.
//

import Foundation
import HealthKit

let HealthKitStore = HKHealthStore()

// Funkcja żądająca dostępu do danych z HealthKit
func requestPermission () async -> Bool {
    let write: Set<HKSampleType> = [.workoutType()]
    let read: Set = [
        .workoutType(),
        HKSeriesType.activitySummaryType(),
        HKSeriesType.workoutType()]
    let res: ()? = try? await HealthKitStore.requestAuthorization(toShare: write, read: read)
    guard res != nil else {
        return false
    }
    return true
}
struct WorkoutData: Identifiable, Encodable{
    var id: Int
    var workoutType: String
    var workoutDistance: Double
    var workoutCalories: Double
    var workoutStart: Date
    var workoutEnd: Date
    var workoutTime: String
}
class WorkoutsModel: ObservableObject {
    let dateFormatter = DateFormatter()
    @Published var list = [WorkoutData]()
    // Funkcja wysyłająca treningi do GCP
    func uploadWorkouts(){
        var jsonString: String?
        do {
            let data = try JSONEncoder().encode(list)
            let json = String(data: data, encoding: .utf8)
            jsonString = json
            print(json!)
        } catch {
            print(error)
        }
        functions.httpsCallable("syncActivities").call(["activities": jsonString]){ result, error in
            if let error = error as NSError? {
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print("syncActivities: "+response)
            }
        }
    }
    // Funkcja odczytująca treningi z Healthkit
    func readWorkouts() async -> [HKWorkout]? {
        let running = HKQuery.predicateForWorkouts(with: .running)
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
        dateComponentsFormatter.unitsStyle = .short
        dateComponentsFormatter.zeroFormattingBehavior = [.dropLeading, .dropTrailing]
        
        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            HealthKitStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: running, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }
                continuation.resume(returning: samples)
            }))
        }
        guard let workouts = samples as? [HKWorkout] else {
            return nil
        }
        // Dodnie treningów do tablicy obiektów WorkoutData
        self.list = workouts.map {workout in
            return WorkoutData(
                id: UUID().hashValue,
                workoutType: String(workout.workoutActivityType.rawValue),
                workoutDistance: workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0,
                workoutCalories: workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0,
                workoutStart: workout.startDate,
                workoutEnd: workout.endDate,
                workoutTime: dateComponentsFormatter.string(from: workout.startDate, to: workout.endDate)!
            )
        }
        return workouts
    }
}
