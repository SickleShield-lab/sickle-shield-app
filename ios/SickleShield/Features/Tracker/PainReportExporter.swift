import UIKit

enum PainReportExporter {
    static func makePDF(user: User?, records: [PainEntry], averageRating: Double) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 40

            "Sickle Shield - pain crisis report".draw(
                at: CGPoint(x: 40, y: y),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)]
            )
            y += 32

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            "Generated \(dateFormatter.string(from: Date()))".draw(
                at: CGPoint(x: 40, y: y),
                withAttributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.darkGray]
            )
            y += 22

            if let user {
                var parts = ["Patient: \(user.username)"]
                if let bloodGroup = user.bloodGroup, !bloodGroup.isEmpty { parts.append("Blood group: \(bloodGroup)") }
                if let diagnosis = user.diagnosis, !diagnosis.isEmpty { parts.append("Diagnosis: \(diagnosis)") }
                parts.joined(separator: "  ·  ").draw(
                    at: CGPoint(x: 40, y: y),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 12)]
                )
                y += 24
            }

            "Entries: \(records.count)   Average severity: \(String(format: "%.1f", averageRating))/10".draw(
                at: CGPoint(x: 40, y: y),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)]
            )
            y += 30

            if records.count >= 2 {
                let chartRect = CGRect(x: 40, y: y, width: pageWidth - 80, height: 140)
                drawChart(records: records, in: chartRect, context: context.cgContext)
                y += 160
            }

            let headerFont = UIFont.boldSystemFont(ofSize: 11)
            let rowFont = UIFont.systemFont(ofSize: 11)
            let columns: [CGFloat] = [40, 150, 230, 350]
            zip(columns, ["Date", "Severity", "Location", "Trigger / notes"]).forEach { x, text in
                text.draw(at: CGPoint(x: x, y: y), withAttributes: [.font: headerFont])
            }
            y += 16
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: 40, y: y))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 40, y: y))
            context.cgContext.strokePath()
            y += 10

            let rowFormatter = DateFormatter()
            rowFormatter.dateStyle = .short
            rowFormatter.timeStyle = .short

            for record in records.sorted(by: { $0.createdAt > $1.createdAt }) {
                if y > pageHeight - 60 {
                    context.beginPage()
                    y = 40
                }
                rowFormatter.string(from: record.createdAt).draw(at: CGPoint(x: columns[0], y: y), withAttributes: [.font: rowFont])
                "\(record.rating)/10".draw(at: CGPoint(x: columns[1], y: y), withAttributes: [.font: rowFont])
                record.pain.draw(at: CGPoint(x: columns[2], y: y), withAttributes: [.font: rowFont])
                record.frequency.draw(at: CGPoint(x: columns[3], y: y), withAttributes: [.font: rowFont])
                y += 18
            }
        }
    }

    private static func drawChart(records: [PainEntry], in rect: CGRect, context: CGContext) {
        let sorted = records.sorted(by: { $0.createdAt < $1.createdAt })
        guard sorted.count >= 2 else { return }

        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.strokePath()

        context.setStrokeColor(UIColor(red: 0.88, green: 0.02, blue: 0.15, alpha: 1).cgColor)
        context.setLineWidth(2)
        let points = sorted.enumerated().map { index, record -> CGPoint in
            let x = rect.minX + rect.width * CGFloat(index) / CGFloat(sorted.count - 1)
            let y = rect.maxY - rect.height * CGFloat(record.rating) / 10
            return CGPoint(x: x, y: y)
        }
        context.move(to: points[0])
        for point in points.dropFirst() { context.addLine(to: point) }
        context.strokePath()
    }
}
