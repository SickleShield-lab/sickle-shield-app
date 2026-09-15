import SwiftUI
import PhotosUI

struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var pendingImageData: Data?
    @State private var showNameSheet = false
    @State private var reportName = ""

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GlassHeader {
                    Text("Latest reports")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(height: 90)

                if let errorMessage = viewModel.errorMessage, viewModel.reports.isEmpty {
                    ErrorState(message: errorMessage) {
                        Task { await viewModel.load() }
                    }
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 14) {
                        if viewModel.reports.isEmpty {
                            Text(viewModel.isLoading ? "Loading..." : "No reports yet")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.muted)
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(viewModel.reports) { report in
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Theme.accent)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(report.reportName)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                            Text(Self.dateFormatter.string(from: report.date))
                                                .font(.system(size: 10))
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        Button {
                                            Task { await viewModel.delete(report) }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Theme.muted)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(14)
                                    .neumorphicCard()
                                }
                            }
                        }

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                if viewModel.isSaving {
                                    ProgressView().tint(Theme.accent)
                                } else {
                                    Text("Upload report")
                                }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                        }
                        .neumorphicPressed()
                        .disabled(viewModel.isSaving)
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                pendingImageData = data
                reportName = "Report - \(Self.dateFormatter.string(from: Date()))"
                showNameSheet = true
            }
        }
        .sheet(isPresented: $showNameSheet) {
            NameReportSheet(
                name: $reportName,
                isSaving: viewModel.isSaving,
                errorMessage: viewModel.errorMessage
            ) {
                guard let pendingImageData else { return }
                let saved = await viewModel.upload(name: reportName, imageData: pendingImageData)
                if saved {
                    showNameSheet = false
                    self.pendingImageData = nil
                    selectedItem = nil
                }
            }
        }
    }
}

#Preview {
    ReportsView()
}
