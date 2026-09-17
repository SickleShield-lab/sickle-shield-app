import SwiftUI

struct WaterIntakeView: View {
    @State private var viewModel = WaterIntakeViewModel()

    private static let quickAdds = [1, 2, 3]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let status = viewModel.status {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .systemGray5), lineWidth: 10)
                            Circle()
                                .trim(from: 0, to: min(status.percentage / 100, 1))
                                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            VStack {
                                Text("\(status.amount)")
                                    .font(.system(size: 34, weight: .bold))
                                Text("of \(status.target) glasses")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 160, height: 160)
                        .padding(.top, 24)
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 60)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                VStack(spacing: 12) {
                    Text("Add glasses")
                        .font(.headline)
                    HStack(spacing: 12) {
                        ForEach(Self.quickAdds, id: \.self) { amount in
                            Button {
                                Task { await viewModel.logGlass(amount) }
                            } label: {
                                Text("+\(amount)")
                                    .font(.headline)
                                    .frame(width: 60, height: 44)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isLogging)
                        }
                    }
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Water intake")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        WaterIntakeView()
    }
}
