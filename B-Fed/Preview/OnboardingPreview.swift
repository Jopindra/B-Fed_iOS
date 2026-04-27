import SwiftUI
import SwiftData

// MARK: - Onboarding Preview Helpers

/// Preview container with an in-memory model context for SwiftData previews
@MainActor
struct PreviewContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environment(feedStore)
    }

    private var feedStore: FeedStore {
        let store = FeedStore()
        return store
    }
}

// MARK: - Xcode Canvas Previews

#Preview("Welcome Screen") {
    PreviewContainer {
        WelcomeScreen { }
    }
}

#Preview("Parent Name Screen") {
    PreviewContainer {
        ParentNameScreen(
            parentName: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Parent Email Screen") {
    PreviewContainer {
        ParentEmailScreen(
            parentEmail: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Country Screen") {
    PreviewContainer {
        CountryScreen(
            country: .constant(""),
            countryCode: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Baby Name Screen") {
    PreviewContainer {
        BabyNameScreen(
            babyName: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Baby DOB Screen") {
    PreviewContainer {
        BabyDOBScreen(
            babyDOB: .constant(Date()),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Feeding Type Screen") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant(""),
            formulaBrand: .constant(""),
            formulaStage: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Feeding Type - Formula Selected") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant("formula"),
            formulaBrand: .constant("Aptamil"),
            formulaStage: .constant("stage1"),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Feeding Type - Breast Selected") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant("breast"),
            formulaBrand: .constant(""),
            formulaStage: .constant(""),
            onBack: { },
            onContinue: { }
        )
    }
}

#Preview("Baby Weight Screen") {
    PreviewContainer {
        BabyWeightScreen(
            birthWeight: .constant(""),
            currentWeight: .constant(""),
            weightUnit: .constant("kg"),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Full Onboarding Flow") {
    PreviewContainer {
        OnboardingView(onComplete: {})
    }
}
