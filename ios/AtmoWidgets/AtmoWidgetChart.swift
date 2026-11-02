import SwiftUI

struct AtmoSparkline: View {
    let pressures: [Double]
    let currentIndex: Int
    let lineColor: Color

    var body: some View {
        Canvas { context, size in
            guard pressures.count > 1, size.width > 0, size.height > 0 else { return }

            let minimum = pressures.min() ?? 0
            let maximum = pressures.max() ?? minimum
            let valueRange = max(maximum - minimum, 2.0)
            let horizontalStep = size.width / CGFloat(pressures.count - 1)
            let points = pressures.enumerated().map { index, value in
                let normalized = (value - minimum) / valueRange
                return CGPoint(
                    x: CGFloat(index) * horizontalStep,
                    y: size.height * AtmoWidgetDesign.Chart.plotBottom
                        - CGFloat(normalized) * size.height * AtmoWidgetDesign.Chart.plotHeight
                )
            }

            var path = Path()
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            context.stroke(
                path,
                with: .color(lineColor),
                style: StrokeStyle(
                    lineWidth: AtmoWidgetDesign.Chart.strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            if currentIndex >= 0 && currentIndex < points.count {
                let point = points[currentIndex]
                var guide = Path()
                guide.move(to: CGPoint(x: point.x, y: AtmoWidgetDesign.Chart.guideTop))
                guide.addLine(to: CGPoint(x: point.x, y: size.height))
                context.stroke(
                    guide,
                    with: .color(AtmoWidgetDesign.guide),
                    style: StrokeStyle(
                        lineWidth: AtmoWidgetDesign.Chart.guideStrokeWidth,
                        dash: AtmoWidgetDesign.Chart.guideDash
                    )
                )
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: point.x - AtmoWidgetDesign.Chart.outerDotRadius,
                            y: point.y - AtmoWidgetDesign.Chart.outerDotRadius,
                            width: AtmoWidgetDesign.Chart.outerDotRadius * 2,
                            height: AtmoWidgetDesign.Chart.outerDotRadius * 2
                        )
                    ),
                    with: .color(AtmoWidgetDesign.surface)
                )
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: point.x - AtmoWidgetDesign.Chart.innerDotRadius,
                            y: point.y - AtmoWidgetDesign.Chart.innerDotRadius,
                            width: AtmoWidgetDesign.Chart.innerDotRadius * 2,
                            height: AtmoWidgetDesign.Chart.innerDotRadius * 2
                        )
                    ),
                    with: .color(.white)
                )
            }
        }
    }
}
