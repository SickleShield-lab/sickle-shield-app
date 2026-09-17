import SwiftUI

struct WeightView: View {
    @State private var viewModel = WeightViewModel()
    @State private var targetType = "week"
    @State private var startWeight = ""
    @State private var targetWeight = ""

    private static let targetTypes = ["week", "month", "year"]

    var body: some View {
        Form {
            if viewModel.isLoading && viewModel.status == nil {
                ProgressView()
            }

            Section("Goal period") {
                Picker("Period", selection: $targetType) {
                    ForEach(Self.targetTypes, id: \.self) { Text($0.capitalized) }
                }
            }

            Section("Weight (kg)") {
                TextField("Starting weight", text: $startWeight)
                    .keyboardType(.numberPad)
                TextField("Target weight", text: $targetWeight)
                    .keyboardType(.numberPad)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Section {
                Button {
                    Task {
                        guard let start = Int(startWeight), let target = Int(targetWeight) else { return }
                        await viewModel.save(targetType: targetType, startWeight: start, targetWeight: target)
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text(viewModel.hasGoal ? "Update goal" : "Set goal")
                    }
                }
                .disabled(viewModel.isSaving || startWeight.isEmpty || targetWeight.isEmpty)
            }
        }
        .navigationTitle("Weight")
        .task {
            await viewModel.load()
            prefill()
        }
        .onChange(of: viewModel.status?.id) { _, _ in prefill() }
    }

    private func prefill() {
        guard let status = viewModel.status, status.id != nil else { return }
        targetType = status.targetType
        startWeight = String(status.startWeight)
        targetWeight = String(status.targetWeight)
    }
}

#Preview {
    NavigationStack {
        WeightView()
    }
}
