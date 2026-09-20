import Foundation

struct CrisisRiskAssessment {
    let score: Int
    let level: String
    let explanation: String
}

/// A transparent heuristic, not a trained model - the point is that it's
/// computed from this person's own data (their pain trend, their hydration,
/// today's actual weather) rather than a generic static tip.
enum RiskScoreEngine {
    static func assess(
        painRecords: [PainEntry],
        averageRating: Double,
        waterIntake: WaterIntakeStatus?,
        weather: WeatherSnapshot?,
        vitals: VitalsSnapshot? = nil
    ) -> CrisisRiskAssessment {
        var score = 0
        var reasons: [String] = []

        let recentCount = painRecords.count
        score += min(recentCount * 8, 40)
        score += Int(averageRating * 3)
        if recentCount >= 2 {
            reasons.append("\(recentCount) crises logged in the last 7 days")
        }

        if let waterIntake, waterIntake.target > 0 {
            let ratio = Double(waterIntake.amount) / Double(waterIntake.target)
            if ratio < 0.5 {
                score += 20
                reasons.append("hydration well below target today")
            } else if ratio < 0.8 {
                score += 10
                reasons.append("hydration a little behind today")
            }
        }

        if let weather {
            let isCold = weather.temperatureCelsius < 5
            let isDry = weather.humidityPercent < 30
            if isCold && isDry {
                score += 20
                reasons.append("cold, dry conditions today")
            } else if isCold {
                score += 12
                reasons.append("cold conditions today")
            } else if isDry {
                score += 8
                reasons.append("dry conditions today")
            }
        }

        if let oxygen = vitals?.oxygenSaturationPercent, oxygen < 95 {
            score += 15
            reasons.append("blood oxygen reading below 95%")
        }
        if let heartRate = vitals?.heartRate, heartRate > 100 {
            score += 10
            reasons.append("resting heart rate higher than usual")
        }

        score = min(score, 100)

        let level: String
        switch score {
        case 0..<25: level = "Low"
        case 25..<50: level = "Moderate"
        case 50..<75: level = "Elevated"
        default: level = "High"
        }

        let explanation: String
        if reasons.isEmpty {
            explanation = "No unusual risk factors detected right now."
        } else {
            let joined = reasons.prefix(2).joined(separator: " and ")
            explanation = joined.prefix(1).uppercased() + joined.dropFirst() + " - consider extra hydration and rest."
        }

        return CrisisRiskAssessment(score: score, level: level, explanation: explanation)
    }
}
