import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showFileImporter = false
    @State private var pendingFileData: Data?
    @State private var pendingFileName: String?
    @State private var pendingMimeType: String?
    @State private var showNameSheet = false
    @State private var reportName = ""
    @State private var fileImportError: String?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let allowedFileTypes: [UTType] = [
        .pdf, .zip,
        UTType(filenameExtension: "doc") ?? .data,
        UTType(filenameExtension: "docx") ?? .data,
    ]

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
                                .foregroundStyle(SSColor.textSecondary)
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(viewModel.reports) { report in
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(SSColor.brand)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(report.reportName)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(SSColor.textPrimary)
                                            Text(Self.dateFormatter.string(from: report.date))
                                                .font(.system(size: 10))
                                                .foregroundStyle(SSColor.textSecondary)
                                        }
                                        Spacer()
                                        Button {
                                            Task { await viewModel.delete(report) }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundStyle(SSColor.textSecondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(14)
                                    .neumorphicCard()
                                }
                            }
                        }

                        if let fileImportError {
                            Text(fileImportError)
                                .font(.system(size: 11))
                                .foregroundStyle(SSColor.brand)
                        }

                        HStack(spacing: 10) {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                uploadButtonLabel("Upload photo")
                            }
                            .neumorphicPressed()
                            .disabled(viewModel.isSaving)

                            Button {
                                showFileImporter = true
                            } label: {
                                uploadButtonLabel("Upload file")
                            }
                            .neumorphicPressed()
                            .disabled(viewModel.isSaving)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(SSColor.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                pendingFileData = data
                pendingFileName = "\(UUID().uuidString).jpg"
                pendingMimeType = "image/jpeg"
                reportName = "Report - \(Self.dateFormatter.string(from: Date()))"
                showNameSheet = true
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: Self.allowedFileTypes) { result in
            fileImportError = nil
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    fileImportError = "Couldn't access that file."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let data = try Data(contentsOf: url)
                    let fileExtension = url.pathExtension
                    pendingFileData = data
                    pendingFileName = "\(UUID().uuidString).\(fileExtension)"
                    pendingMimeType = Self.mimeType(forExtension: fileExtension)
                    reportName = url.deletingPathExtension().lastPathComponent
                    showNameSheet = true
                } catch {
                    fileImportError = "Couldn't read that file."
                }
            case .failure(let error):
                fileImportError = error.localizedDescription
            }
        }
        .sheet(isPresented: $showNameSheet) {
            NameReportSheet(
                name: $reportName,
                isSaving: viewModel.isSaving,
                errorMessage: viewModel.errorMessage
            ) {
                guard let pendingFileData, let pendingFileName, let pendingMimeType else { return }
                let saved = await viewModel.upload(name: reportName, fileData: pendingFileData, fileName: pendingFileName, mimeType: pendingMimeType)
                if saved {
                    showNameSheet = false
                    self.pendingFileData = nil
                    self.pendingFileName = nil
                    self.pendingMimeType = nil
                    selectedItem = nil
                }
            }
        }
    }

    private func uploadButtonLabel(_ title: String) -> some View {
        HStack {
            if viewModel.isSaving {
                ProgressView().tint(SSColor.brand)
            } else {
                Text(title)
            }
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(SSColor.brand)
        .frame(maxWidth: .infinity)
        .padding(13)
    }

    private static func mimeType(forExtension ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "zip": return "application/zip"
        default: return "application/octet-stream"
        }
    }
}

#Preview {
    ReportsView()
}
