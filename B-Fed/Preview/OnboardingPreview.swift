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
        // Preview doesn't need a real model context for onboarding
        return store
    }
}

// MARK: - Xcode Canvas Previews

#Preview("Welcome Screen") {
    PreviewContainer {
        WelcomeScreen { }
    }
}

#Preview("Form Screen") {
    PreviewContainer {
        ParentBabyFormScreen(
            parentName: .constant(""),
            parentEmail: .constant(""),
            parentDOB: .constant(Date()),
            country: .constant(""),
            babyName: .constant(""),
            babyDOB: .constant(Date()),
            babyWeight: .constant(""),
            showingValidationErrors: .constant(false),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Form Screen - With Data") {
    PreviewContainer {
        ParentBabyFormScreen(
            parentName: .constant("Sarah"),
            parentEmail: .constant("sarah@email.com"),
            parentDOB: .constant(Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()),
            country: .constant("Australia"),
            babyName: .constant("Lily"),
            babyDOB: .constant(Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()),
            babyWeight: .constant("3.5"),
            showingValidationErrors: .constant(false),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Form Screen - Validation Errors") {
    PreviewContainer {
        ParentBabyFormScreen(
            parentName: .constant(""),
            parentEmail: .constant("invalid"),
            parentDOB: .constant(Date()),
            country: .constant(""),
            babyName: .constant(""),
            babyDOB: .constant(Date()),
            babyWeight: .constant(""),
            showingValidationErrors: .constant(true),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Feeding Type Screen") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant(nil),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Feeding Type - Formula Selected") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant(.formula),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Feeding Type - Breast Selected") {
    PreviewContainer {
        FeedingTypeScreen(
            feedingType: .constant(.breast),
            onContinue: { },
            onBack: { }
        )
    }
}

#Preview("Completion Screen") {
    PreviewContainer {
        CompletionScreen(
            onStart: { },
            onBack: { }
        )
    }
}

#Preview("Full Onboarding Flow") {
    PreviewContainer {
        OnboardingView()
    }
}
