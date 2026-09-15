import AppIntents

struct LogCrisisIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a pain crisis"
    static var description = IntentDescription("Quickly log a sickle cell pain crisis in Sickle Shield.")

    @Parameter(title: "Severity", description: "Pain severity from 0 to 10", default: 5)
    var severity: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log a crisis with severity \(\.$severity)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard KeychainHelper.shared.token != nil else {
            return .result(dialog: "Open Sickle Shield and log in first, then try again.")
        }
        let clamped = max(0, min(severity, 10))
        do {
            _ = try await PainAPI.createPain(
                pain: "Crisis",
                sensation: "Logged via Siri",
                frequency: "Unspecified",
                rating: clamped
            )
            return .result(dialog: "Logged a pain crisis at severity \(clamped) out of 10.")
        } catch {
            return .result(dialog: "Couldn't log that - check your connection and try again in the app.")
        }
    }
}

struct SickleShieldShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogCrisisIntent(),
            phrases: [
                "Log a pain crisis in \(.applicationName)",
                "Log a crisis in \(.applicationName)",
            ],
            shortTitle: "Log crisis",
            systemImageName: "bandage.fill"
        )
    }
}
