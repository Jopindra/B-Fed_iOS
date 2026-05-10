import SwiftUI

// MARK: - Blob Configuration

struct BlobConfig {
    let color: Color
    let opacity: CGFloat
    let scale: CGFloat
    let position: BlobPosition
}

enum BlobPosition {
    case topRight
    case bottomLeft
    case bottomRight
}

// MARK: - Onboarding Background

struct OnboardingBackground: View {
    let blobs: [BlobConfig]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<blobs.count, id: \.self) { index in
                    let config = blobs[index]
                    Ellipse()
                        .fill(config.color.opacity(config.opacity))
                        .frame(
                            width: geo.size.width * config.scale * 2,
                            height: geo.size.width * config.scale * 2
                        )
                        .position(
                            x: xPosition(for: config.position, in: geo),
                            y: yPosition(for: config.position, in: geo)
                        )
                        .accessibilityHidden(true)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func xPosition(for position: BlobPosition, in geo: GeometryProxy) -> CGFloat {
        switch position {
        case .topRight, .bottomRight:
            return geo.size.width
        case .bottomLeft:
            return 0
        }
    }

    private func yPosition(for position: BlobPosition, in geo: GeometryProxy) -> CGFloat {
        switch position {
        case .topRight:
            return 0
        case .bottomLeft, .bottomRight:
            return geo.size.height
        }
    }
}

// MARK: - Predefined Backgrounds

extension OnboardingBackground {
    static func parentName() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .peachDust, opacity: AppMetrics.blobOpacityStrong, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .almostAquaLight, opacity: 0.75, scale: AppMetrics.blobScaleMedium, position: .bottomLeft)
        ])
    }

    static func parentEmail() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .orchidTint, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .peachDustLight, opacity: 0.80, scale: AppMetrics.blobScaleMedium, position: .bottomLeft)
        ])
    }

    static func country() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .almostAqua, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .lemonIcing, opacity: 0.75, scale: AppMetrics.blobScaleMedium, position: .bottomLeft)
        ])
    }

    static func babyName() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .lemonIcing, opacity: 0.75, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .orchidTint, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleMedium, position: .bottomLeft)
        ])
    }

    static func babyDOB() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .peachDust, opacity: AppMetrics.blobOpacityStrong, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .almostAqua, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleMedium, position: .bottomLeft)
        ])
    }

    static func feedingType() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .orchidTint, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .peachDust, opacity: AppMetrics.blobOpacityStrong, scale: AppMetrics.blobScaleMedium, position: .bottomLeft),
            BlobConfig(color: .lemonIcing, opacity: AppMetrics.blobOpacitySubtle, scale: AppMetrics.blobScaleSmall, position: .bottomRight)
        ])
    }

    static func babyWeight() -> Self {
        OnboardingBackground(blobs: [
            BlobConfig(color: .almostAqua, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleLarge, position: .topRight),
            BlobConfig(color: .peachDust, opacity: AppMetrics.blobOpacityStrong, scale: AppMetrics.blobScaleMedium, position: .bottomLeft),
            BlobConfig(color: .orchidTint, opacity: AppMetrics.blobOpacityMedium, scale: AppMetrics.blobScaleSmall, position: .bottomRight)
        ])
    }
}
