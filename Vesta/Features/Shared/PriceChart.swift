import SwiftUI
import Charts

// Line + area price chart with a draggable scrubber. Uses Swift Charts.
struct PriceChart: View {
    let points: [PricePoint]
    var isUp: Bool
    var onScrub: ((PricePoint?) -> Void)? = nil   // nil when the drag ends

    @State private var selectedDate: Date?

    private var lineColor: Color { isUp ? Theme.Palette.up : Theme.Palette.down }

    private var yDomain: ClosedRange<Double> {
        let values = points.map(\.value)
        guard let min = values.min(), let max = values.max(), min < max else {
            return 0...1
        }
        let padding = (max - min) * 0.12
        return (min - padding)...(max + padding)
    }

    private var selectedPoint: PricePoint? {
        guard let selectedDate else { return nil }
        return points.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })
    }

    var body: some View {
        Chart {
            ForEach(points) { point in
                LineMark(
                    x: .value("Time", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(lineColor)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                AreaMark(
                    x: .value("Time", point.date),
                    yStart: .value("Min", yDomain.lowerBound),
                    yEnd: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Theme.directionGradient(isUp: isUp))
            }

            if let selectedPoint {
                RuleMark(x: .value("Selected", selectedPoint.date))
                    .foregroundStyle(Theme.Palette.textTertiary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(
                    x: .value("Time", selectedPoint.date),
                    y: .value("Value", selectedPoint.value)
                )
                .foregroundStyle(lineColor)
                .symbolSize(90)
            }
        }
        .chartYScale(domain: yDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard let plotFrame = proxy.plotFrame else { return }
                                let origin = geo[plotFrame].origin
                                let xPosition = value.location.x - origin.x
                                if let date: Date = proxy.value(atX: xPosition) {
                                    selectedDate = date
                                    onScrub?(selectedPoint)
                                    Haptics.selection()
                                }
                            }
                            .onEnded { _ in
                                selectedDate = nil
                                onScrub?(nil)
                            }
                    )
            }
        }
    }
}

// Row of range buttons (1D / 1W / ...).
struct RangeSelector: View {
    @Binding var selection: ChartRange

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(ChartRange.allCases) { range in
                Button {
                    Haptics.selection()
                    withAnimation(.smooth) { selection = range }
                } label: {
                    Text(range.rawValue)
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .foregroundStyle(selection == range ? Color.white : Theme.Palette.textSecondary)
                        .background(
                            selection == range
                                ? AnyShapeStyle(Theme.Palette.brand)
                                : AnyShapeStyle(Color.clear),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.Palette.surface, in: Capsule())
    }
}
