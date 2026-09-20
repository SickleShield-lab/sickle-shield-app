import SwiftUI

struct EducationalResourcesView: View {
    @State private var viewModel = EducationalResourcesViewModel()

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage, viewModel.resources.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't load resources", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try again") { Task { await viewModel.load() } }
                }
            } else if viewModel.resources.isEmpty {
                ContentUnavailableView(
                    "No resources yet",
                    systemImage: "book.closed",
                    description: Text("Educational articles will show up here.")
                )
            } else {
                ForEach(viewModel.resources) { resource in
                    NavigationLink {
                        ResourceDetailView(resourceId: resource.id, fallback: resource)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(resource.title)
                                .font(.headline)
                            Text(resource.subTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Educational resources")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}

private struct ResourceDetailView: View {
    let resourceId: String
    let fallback: EduResource

    @State private var resource: EduResource?
    @State private var errorMessage: String?

    private var displayed: EduResource { resource ?? fallback }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let imageURL = displayed.resourceImages.first.flatMap(URL.init(string:)) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(uiColor: .secondarySystemBackground)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Text(displayed.title)
                    .font(.title2.weight(.semibold))
                Text(displayed.subTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(displayed.description)
                    .font(.body)
                    .padding(.top, 4)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Placeholder resources aren't backed by the API - skip the
            // fetch rather than showing a spurious 404 under fine content.
            guard !resourceId.hasPrefix(PlaceholderResources.placeholderIDPrefix) else { return }
            do {
                resource = try await ResourceAPI.single(id: resourceId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        EducationalResourcesView()
    }
}
