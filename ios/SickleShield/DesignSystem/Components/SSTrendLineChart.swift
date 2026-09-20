import SwiftUI

/// A minimal hand-drawn line chart for a sequence of values (e.g. pain
/// ratings over time) - no external charting dependency. Shared between
/// `InsightsView` and `PainView`, both of which plot the same kind of data.
struct SSTrendLineChart: View {
    let values: [Double]
    var color: Color = SSColor.brand

    var body: some View {
        GeometryReader { geo in
            let maxVal = max(values.max() ?? 1, 1)
            let points = values.enumerated().map { index, value -> CGPoint in
                let x = geo.size.width * CGFloat(index) / CGFloat(max(values.count - 1, 1))
                let y = geo.size.height * (1 - CGFloat(value / maxVal))
                return CGPoint(x: x, y: y)
            }
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
        .padding(SSSpacing.md)
    }
}

#Preview {
    SSTrendLineChart(values: [3, 5, 2, 6, 4, 7, 3])
        .frame(height: 120)
        .background(SSColor.surface)
        .padding()
        .background(SSColor.background)
}
