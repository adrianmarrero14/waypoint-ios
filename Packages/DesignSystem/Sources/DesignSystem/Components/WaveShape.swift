import SwiftUI

/// The brand's wave motif: a run of smooth quadratic arcs. Use stroked for
/// decorative lines or filled (closed) as a section divider.
public struct WaveShape: Shape {
    let wavelength: CGFloat
    let amplitude: CGFloat
    let closed: Bool

    /// - Parameters:
    ///   - wavelength: width of one full arc pair.
    ///   - amplitude: crest height above the midline.
    ///   - closed: when true, closes the path down to the bottom edge so it can be filled.
    public init(wavelength: CGFloat = 56, amplitude: CGFloat = 16, closed: Bool = false) {
        self.wavelength = wavelength
        self.amplitude = amplitude
        self.closed = closed
    }

    nonisolated public func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = closed ? rect.minY + amplitude : rect.midY
        path.move(to: CGPoint(x: rect.minX, y: midY))
        var x = rect.minX
        while x < rect.maxX {
            let next = min(x + wavelength, rect.maxX)
            path.addQuadCurve(
                to: CGPoint(x: next, y: midY),
                control: CGPoint(x: x + wavelength / 2, y: midY - amplitude * 2)
            )
            x = next
        }
        if closed {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
        return path
    }
}

/// Brand bubble: a filled circle that always carries a navy outline.
public struct Bubble: View {
    let diameter: CGFloat
    let fill: Color

    public init(diameter: CGFloat = 18, fill: Color = .wpSplashSky) {
        self.diameter = diameter
        self.fill = fill
    }

    public var body: some View {
        Circle()
            .fill(fill)
            .strokeBorder(Color.wpDeepNavy, lineWidth: 3)
            .frame(width: diameter, height: diameter)
    }
}

#Preview {
    VStack(spacing: 0) {
        VStack(spacing: 24) {
            WaveShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .frame(height: 40)
            HStack(spacing: 12) {
                Bubble(fill: .wpSplashSky)
                Bubble(diameter: 12, fill: .white)
                Bubble(diameter: 24, fill: .wpWhaleBlue)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.wpOceanBlue)

        WaveShape(closed: true)
            .fill(Color.wpOceanBlue)
            .frame(height: 46)
            .background(Color.wpFoam)
    }
}
