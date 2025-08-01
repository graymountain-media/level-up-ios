import SwiftUI
import Vortex

struct ParticleTest: View {
    // Position of the particle emitter, normalized (0.0 to 1.0)
    @State private var emitterPosition: SIMD2<Double> = [0.5, 0.5]

    // State for the curved path
    @State private var path = Path()
    @State private var pathPoints: [CGPoint] = []
    @State private var controlPoints: [CGPoint] = []
    @State private var currentSegmentIndex = 0
    @State private var animationProgress: CGFloat = 0.0
    let animationDuration: TimeInterval = 2.0

    // Timer to drive the animation along the path
    let timer = Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                // The curved path visualization
                path
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // The particle system
                VortexViewReader { proxy in
                    VortexView(createTrailSystem()) {
                        Circle()
                            .fill(.white)
                            .blur(radius: 2)
                            .frame(width: 8)
                            .tag("trail")
                        
                        Circle()
                            .fill(Color.minor)
                            .blur(radius: 1)
                            .frame(width: 6)
                            .tag("trail2")
                        
                        Circle()
                            .fill(Color.textOrange)
                            .blur(radius: 1)
                            .frame(width: 4)
                            .tag("trail3")
                    }
                    .onChange(of: emitterPosition) { _, newPosition in
                        // Update the particle system's emitter position
                        proxy.particleSystem?.position = newPosition
                    }
                }
            }
            .onAppear {
                setupPath(size: geometry.size)
            }
            .onReceive(timer) { _ in
                updateEmitterPosition(size: geometry.size)
            }
        }
    }
    
    // Configures the particle system
    func createTrailSystem() -> VortexSystem {
        let system = VortexSystem(
            tags: ["trail", "trail2", "trail3"],
            position: emitterPosition,
            birthRate: 200,
            lifespan: 1,
            lifespanVariation: 0.5,
            speed: 0.1,
            speedVariation: 0.1,
            angleRange: .degrees(360),
            acceleration: [0, 0.1],
//            opacity: 0.5,
//            opacitySpeed: -0.5,
//            scaleVariation: 0.1,
//            scaleSpeed: -0.1
        )
        return system
    }
    
    // Sets up the points and generates the curved path
    private func setupPath(size: CGSize) {
        pathPoints = [
            CGPoint(x: -size.width * 0.4, y: -size.height * 0.3),
            CGPoint(x: size.width * 0.3, y: -size.height * 0.4),
            CGPoint(x: size.width * 0.2, y: size.height * 0.3),
            CGPoint(x: -size.width * 0.3, y: size.height * 0.2),
            CGPoint(x: -size.width * 0.4, y: -size.height * 0.3) // Loop back
        ]

        // Pre-calculate control points
        controlPoints = []
        for i in 0..<(pathPoints.count - 1) {
            let p1 = pathPoints[i]
            let p2 = pathPoints[i+1]
            controlPoints.append(calculateControlPoint(p1: p1, p2: p2))
        }

        self.path = createCurvedPath(points: pathPoints, controls: controlPoints)

        // Set initial position
        let initialPoint = pathPoints[0]
        emitterPosition = normalizePoint(initialPoint, size: size)
    }

    // Moves the emitter to the next point on the path
    private func updateEmitterPosition(size: CGSize) {
        guard !pathPoints.isEmpty, !controlPoints.isEmpty else { return }

        // Increment progress
        animationProgress += (1.0 / 60.0) / animationDuration

        // If segment is complete, move to the next one
        if animationProgress >= 1.0 {
            animationProgress = 0
            currentSegmentIndex = (currentSegmentIndex + 1) % controlPoints.count
        }

        // Get points for the current segment
        let p0 = pathPoints[currentSegmentIndex]
        let p1 = controlPoints[currentSegmentIndex]
        let p2 = pathPoints[currentSegmentIndex + 1]

        // Calculate position on the curve using quadratic Bézier formula
        let t = animationProgress
        let oneMinusT = 1 - t

        let x = oneMinusT * oneMinusT * p0.x + 2 * oneMinusT * t * p1.x + t * t * p2.x
        let y = oneMinusT * oneMinusT * p0.y + 2 * oneMinusT * t * p1.y + t * t * p2.y

        let currentPoint = CGPoint(x: x, y: y)

        // Update emitter position (normalized)
        emitterPosition = normalizePoint(currentPoint, size: size)
    }

    private func normalizePoint(_ point: CGPoint, size: CGSize) -> SIMD2<Double> {
        return [
            (point.x + size.width / 2) / size.width,
            (point.y + size.height / 2) / size.height
        ]
    }

    // Generates a Path object from a series of points using quadratic curves
    private func createCurvedPath(points: [CGPoint], controls: [CGPoint]) -> Path {
        var path = Path()
        guard !points.isEmpty, points.count == controls.count + 1 else { return path }

        path.move(to: points[0])

        for i in 0..<controls.count {
            path.addQuadCurve(to: points[i+1], control: controls[i])
        }

        return path
    }

    // Calculates a control point to create a curve between two points
    private func calculateControlPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        let midPoint = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        
        // Offset the midpoint perpendicularly to create the curve
        return CGPoint(x: midPoint.x - dy * 0.4, y: midPoint.y + dx * 0.4)
    }
}

#Preview {
    ParticleTest()
}
