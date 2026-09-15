import HealthKit

struct VitalsSnapshot {
    var heartRate: Double?
    var oxygenSaturationPercent: Double?
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
