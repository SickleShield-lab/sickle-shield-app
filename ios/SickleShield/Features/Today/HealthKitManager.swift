import HealthKit

struct VitalsSnapshot {
    var heartRate: Double?
    var oxygenSaturationPercent: Double?
}

struct SleepSample {
    /// Calendar day the sleep session started on.
    let day: Date
    let hours: Double
}

@MainActor
final class HealthKitManager {
    private let store = HKHealthStore()

    /// Best-effort: no HealthKit access (denied, unavailable, or simulator
    /// with no data) should just mean the risk score has one less input,
    /// never an error the user has to deal with.
    func latestVitals() async -> VitalsSnapshot {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
              let oxygenType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
        else {
            return VitalsSnapshot()
        }

        do {
            try await store.requestAuthorization(toShare: [], read: [heartRateType, oxygenType])
        } catch {
            return VitalsSnapshot()
        }

        async let heartRate = latestSample(type: heartRateType, unit: HKUnit.count().unitDivided(by: .minute()))
        async let oxygen = latestSample(type: oxygenType, unit: HKUnit.percent())
        return VitalsSnapshot(heartRate: await heartRate, oxygenSaturationPercent: await oxygen.map { $0 * 100 })
    }

    /// Best-effort, opt-in sleep history for Insights - one total per
    /// calendar day, summed across all "asleep" sample types (core, deep,
    /// REM, unspecified). Excludes "in bed" and "awake" samples.
    func sleepHistory(days: Int) async -> [SleepSample] {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            return []
        }

        do {
            try await store.requestAuthorization(toShare: [], read: [sleepType])
        } catch {
            return []
        }

        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: since, end: Date(), options: .strictStartDate)

        let samples: [HKCategorySample] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
                continuation.resume(returning: (results as? [HKCategorySample]) ?? [])
            }
            store.execute(query)
        }

        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        ]

        let calendar = Calendar.current
        var totalsByDay: [Date: Double] = [:]
        for sample in samples where asleepValues.contains(sample.value) {
            let day = calendar.startOfDay(for: sample.startDate)
            let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600
            totalsByDay[day, default: 0] += hours
        }

        return totalsByDay.map { SleepSample(day: $0.key, hours: $0.value) }.sorted { $0.day < $1.day }
    }

    private func latestSample(type: HKQuantityType, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
