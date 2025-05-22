import SwiftUI

struct LiquidLaunchModifier: ViewModifier {
    @State private var progress: Double = .zero
    @State private var currentStep: Int = .zero
    @State private var spacing: CGFloat = -88

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            Color("swagcolor")

            if currentStep == 2 {
                TravelLogo(finished: true, spacing: -14, geometry: geometry)
            }

            maskedContent(content: content, geometry: geometry)
        }
        .ignoresSafeArea()
        .task {
            await startLaunchSequence()
        }
    }

    private func maskedContent(content: Content, geometry: GeometryProxy) -> some View {
        Group {
            switch currentStep {
            case 1:
                TravelLogo(finished: false, spacing: spacing, geometry: geometry)
            case 2:
                content
            default:
                Color("swagcolor")
            }
        }
        .mask(
            LiquidShape(progress: progress)
                .frame(width: geometry.size.width + 250, height: geometry.size.height + 400)
                .offset(x: 180, y: -190)
                .rotationEffect(Angle(degrees: 2))
                .scaleEffect(y: currentStep == 2 ? -1.0 : 1.0)
        )
    }

    private func startLaunchSequence() async {
        try? await Task.sleep(for: .seconds(0.5))
        startAnimation(speed: 1.0)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.9).delay(0.6)) {
            spacing = -14
        }

        try? await Task.sleep(for: .seconds(1.6))
        startAnimation(speed: 2.0)
    }

    private func startAnimation(speed: Double) {
        currentStep = Int(speed)
        progress = .zero

        withAnimation(.smooth(duration: 0.4 / speed)) {
            progress = 0.4
        }

        Task {
            try? await Task.sleep(for: .seconds(0.4 / speed))
            withAnimation(.smooth(duration: 0.5 - 0.2 * speed)) {
                progress = 0.45
            }

            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.spring(duration: 1.9 - 0.7 * speed)) {
                progress = 1.0
            }
        }
    }
}

extension View {
    func liquidLaunch() -> some View {
        modifier(LiquidLaunchModifier())
    }
}

struct LiquidShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        let rightEdgeX = width * (1.0 - progress)
        let bulgeDepth = width * 0.3 * progress + 200 - progress * 100
        let bottomRightOffset = progress > 0.45 ? progress * -1000 + 450 : .zero

        path.move(to: CGPoint(x: width + 200, y: .zero))
        path.addLine(to: CGPoint(x: width + 200, y: height))
        path.addLine(to: CGPoint(x: rightEdgeX + bottomRightOffset, y: height))

        path.addCurve(
            to: CGPoint(x: rightEdgeX - bulgeDepth, y: height * 0.57),
            control1: CGPoint(x: rightEdgeX - bulgeDepth * 0.4, y: height * 0.75),
            control2: CGPoint(x: rightEdgeX - bulgeDepth, y: height * 0.7)
        )

        path.addCurve(
            to: CGPoint(x: rightEdgeX, y: .zero),
            control1: CGPoint(x: rightEdgeX - bulgeDepth, y: height * 0.45),
            control2: CGPoint(x: rightEdgeX - bulgeDepth * 0.4, y: height * 0.25)
        )

        path.addLine(to: CGPoint(x: width + 200, y: .zero))
        path.closeSubpath()
        return path
    }
}

struct TravelLogo: View {
    @State private var size: CGFloat = 68
    var finished: Bool
    var spacing: CGFloat
    var geometry: GeometryProxy

    var body: some View {
        ZStack {
            Color("coolcolor")

            backgroundRectangles(geometry: geometry)
                .overlay {
                    HStack(spacing: 7) {
                        Image("travelogo").resizable()
                            .frame(width: size, height: size)

                        Image("yatravel").resizable()
                            .frame(width: 175, height: 57)
                    }
                    .padding(.leading, -20)
                }
                .mask(backgroundRectangles(geometry: geometry))
                .onAppear {
                    if !finished { size = 0 }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9).delay(0.6)) {
                        size = 68
                    }
                }
        }
    }

    private func backgroundRectangles(geometry: GeometryProxy) -> some View {
        HStack(spacing: spacing) {
            ForEach(.zero ..< 4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .frame(width: 88, height: 103)
                    .transformEffect(
                        CGAffineTransform(
                            a: 1, b: .zero, c: 0.14,
                            d: 1, tx: .zero, ty: .zero
                        )
                    )
            }
        }
        .padding(.leading, (geometry.size.width - 330) / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
