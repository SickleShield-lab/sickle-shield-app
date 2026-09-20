import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    var body: some View {
        List {
            Section {
                ForEach(AppAppearance.allCases) { option in
                    Button {
                        appearanceRaw = option.rawValue
                    } label: {
                        HStack {
                            Text(option.label)
                                .foregroundStyle(SSColor.textPrimary)
                            Spacer()
                            if appearanceRaw == option.rawValue {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(SSColor.brand)
                            }
                        }
                    }
                }
            } footer: {
                Text("Choose how Sickle Shield looks, or match your device's system setting.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
