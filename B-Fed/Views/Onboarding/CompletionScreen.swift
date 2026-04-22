import SwiftUI
import SwiftData

struct CompletionScreen: View {
    let onStart: () -> Void
    let onBack: () -> Void
    
    @State private var appear = false
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(AppFont.bodyLarge)
                        Text("Back")
                            .font(AppFont.bodyLarge)
                    }
                }
                .ghostButton()
                Spacer()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, 8)
            
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .stroke(Color.almostAquaDark.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1 + (pulse ? 0.1 : 0))
                
                Circle()
                    .fill(Color.almostAquaDark.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1 + (pulse ? 0.08 : 0))
                
                Circle()
                    .fill(Color.almostAquaDark.opacity(0.08))
                    .frame(width: 140, height: 140)
                
                ZStack {
                    Circle()
                        .fill(Color.backgroundCard)
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "checkmark")
                        .font(AppFont.serif(38))
                        .foregroundStyle(Color.almostAquaDark)
                }
                .scaleEffect(appear ? 1 : 0)
            }
            .padding(.bottom, AppSpacing.xxl)
            
            // Text
            VStack(spacing: 12) {
                Text("You're all set")
                    .font(AppFont.heroTitle)
                    .foregroundStyle(Color.inkPrimary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Let's start tracking your\nbaby's next feed")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(Color.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)
            }
            
            Spacer()
            
            // CTA
            Button(action: onStart) {
                HStack(spacing: 10) {
                    Text("Start tracking")
                        .font(AppFont.bodyLarge)
                    Image(systemName: "arrow.right")
                        .font(AppFont.bodyLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .buttonStyle(GentlePressEffect())
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appear = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) { pulse = true }
        }
    }
}

#Preview {
    CompletionScreen(
        onStart: {},
        onBack: {}
    )
}
