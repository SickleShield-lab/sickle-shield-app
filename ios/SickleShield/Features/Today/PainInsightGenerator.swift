import Foundation
import FoundationModels

/// A plain-language summary of a pain trend plus practical, non-diagnostic
/// tips and crisis guidance. Never a diagnosis - phrasing is steered by the
/// `@Guide` descriptions below, matching the "transparent heuristic, not an
/// AI doctor" rule the rest of the app follows (see `RiskScoreEngine`).
@Generable
struct PainTrendInsight {
    @Guide(description: "A 2-3 sentence plain-language summary of this person's recent pain trend, referencing their own average, highest, and number of episodes. Supportive tone, never a diagnosis, never invents facts not given in the prompt.")
    var summary: String

    @Guide(description: "2-4 short, practical self-care tips relevant to the observed trend (e.g. hydration, rest, warmth, pacing activity). Not medical advice, never suggests a specific medication or dosage.", .maximumCount(4))
    var tips: [String]

    @Guide(description: "One or two sentences on when to seek urgent or emergency care, tailored to whether recent pain has reached a high severity (above 6 out of 10) or not.")
    var whenToSeekCare: String
}

/// Stats computed locally from the user's own pain history - the only
/// input either generation path (on-device model or fallback) is given.
struct PainTrendStats {
    let average: Double
    let highest: Int
    let lowest: Int
    let episodeCount: Int
    let hadCrisisAboveSix: Bool
}

enum PainInsightGenerator {
    static func generate(from stats: PainTrendStats) async -> PainTrendInsight {
        guard stats.episodeCount > 0 else {
            return PainTrendInsight(
                summary: "No pain entries logged recently - once you log a few, you'll see a trend summary here.",
                tips: ["Log a crisis or a quiet day alike - trends are more useful with regular entries."],
                whenToSeekCare: "If you're in a crisis right now, use the Emergency tab to reach your contacts or emergency services."
            )
        }

        if case .available = SystemLanguageModel.default.availability {
            do {
                let session = LanguageModelSession()
                let prompt = """
                Here is a person's recent sickle cell pain history, computed on-device from their own logs:
                - Average pain rating: \(String(format: "%.1f", stats.average)) out of 10
                - Highest recorded rating: \(stats.highest) out of 10
                - Lowest recorded rating: \(stats.lowest) out of 10
                - Number of episodes logged: \(stats.episodeCount)
                - At least one episode above 6/10: \(stats.hadCrisisAboveSix ? "yes" : "no")

                Summarize this trend for them in a supportive, non-alarming way, suggest a few practical self-care tips, and note when they should seek urgent or emergency care.
                """
                let response = try await session.respond(to: prompt, generating: PainTrendInsight.self)
                return response.content
            } catch {
                return fallback(from: stats)
            }
        } else {
            return fallback(from: stats)
        }
    }

    /// Deterministic fallback used when Apple Intelligence isn't available
    /// (unsupported hardware/OS) or the on-device model call fails/refuses.
    /// Same voice and thresholds as the on-device path, just template-based -
    /// mirrors `RiskScoreEngine`'s existing "transparent heuristic" approach.
    private static func fallback(from stats: PainTrendStats) -> PainTrendInsight {
        let summary = "Your average pain recently has been \(String(format: "%.1f", stats.average))/10 across \(stats.episodeCount) episode\(stats.episodeCount == 1 ? "" : "s"), ranging from \(stats.lowest) to \(stats.highest)."

        var tips = [
            "Stay ahead of hydration - even mild dehydration can make pain harder to manage.",
            "Keep warm and avoid sudden temperature changes where possible.",
            "Pace activity and rest before you're fully exhausted, not after."
        ]
        if stats.average >= 5 {
            tips.append("Consider sharing this trend with your care team at your next visit.")
        }

        let whenToSeekCare = stats.hadCrisisAboveSix
            ? "Since a recent episode reached above 6/10, treat any pain at that level as a crisis: follow your Personal Pain Plan, contact your care team, and use the Emergency tab if it escalates or doesn't respond to your usual care."
            : "If any pain reaches above 6/10, treat it as a crisis - follow your usual crisis care steps and use the Emergency tab if you need help reaching a contact or emergency services."

        return PainTrendInsight(summary: summary, tips: Array(tips.prefix(4)), whenToSeekCare: whenToSeekCare)
    }
}
