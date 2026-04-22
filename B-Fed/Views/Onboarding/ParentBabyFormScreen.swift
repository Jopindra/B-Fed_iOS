import SwiftUI
import SwiftData

// MARK: - Screen 2: Parent & Baby Form
struct ParentBabyFormScreen: View {
    @Binding var parentName: String
    @Binding var parentEmail: String
    @Binding var parentDOB: Date
    @Binding var country: String
    @Binding var babyName: String
    @Binding var babyDOB: Date
    @Binding var babyWeight: String
    @Binding var showingValidationErrors: Bool
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @FocusState private var focusedField: Field?
    @State private var appear = false
    
    enum Field: Hashable {
        case parentName, parentEmail, country, babyName, babyWeight
    }
    
    var isValid: Bool {
        !parentName.isEmpty &&
        !parentEmail.isEmpty &&
        parentEmail.contains("@") &&
        !country.isEmpty &&
        !babyName.isEmpty &&
        !babyWeight.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation header with back button
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About you")
                            .font(AppFont.heroTitle)
                            .foregroundStyle(Color.inkPrimary)
                        Text("This helps us personalise your experience")
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    
                    // Parent section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Parent", icon: "person.fill")
                        
                        FormField(
                            label: "Your name",
                            text: $parentName,
                            placeholder: "e.g. Sarah",
                            isRequired: true,
                            showError: showingValidationErrors && parentName.isEmpty
                        )
                        .focused($focusedField, equals: .parentName)
                        
                        FormField(
                            label: "Email address",
                            text: $parentEmail,
                            placeholder: "e.g. sarah@email.com",
                            isRequired: true,
                            showError: showingValidationErrors && (parentEmail.isEmpty || !parentEmail.contains("@"))
                        )
                        .focused($focusedField, equals: .parentEmail)
                        
                        DateField(
                            label: "Date of birth",
                            date: $parentDOB,
                            isRequired: false
                        )
                        
                        FormField(
                            label: "Country",
                            text: $country,
                            placeholder: "e.g. Australia",
                            isRequired: true,
                            showError: showingValidationErrors && country.isEmpty
                        )
                        .focused($focusedField, equals: .country)
                    }
                    
                    // Baby section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Baby", icon: "heart.fill")
                        
                        FormField(
                            label: "Name or nickname",
                            text: $babyName,
                            placeholder: "e.g. Lily",
                            isRequired: true,
                            showError: showingValidationErrors && babyName.isEmpty
                        )
                        .focused($focusedField, equals: .babyName)
                        
                        DateField(
                            label: "Date of birth",
                            date: $babyDOB,
                            isRequired: true
                        )
                        
                        FormField(
                            label: "Weight (kg)",
                            text: $babyWeight,
                            placeholder: "e.g. 3.5",
                            isRequired: true,
                            showError: showingValidationErrors && babyWeight.isEmpty,
                            suffix: "kg"
                        )
                        .focused($focusedField, equals: .babyWeight)
                    }
                    
                    Spacer().frame(height: AppSpacing.xxl)
                }
                .padding(.horizontal, AppSpacing.xl)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // CTA
            Button(action: onContinue) {
                Text("Continue")
                    .font(AppFont.bodyLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .primaryButton()
            .opacity(isValid ? 1.0 : 0.4)
            .buttonStyle(GentlePressEffect())
            .disabled(!isValid && showingValidationErrors)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xxl)
            .animation(.easeOut(duration: 0.2), value: isValid)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(AppFont.body)
                .foregroundStyle(Color.almostAquaDark)
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(Color.inkPrimary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Form Field
struct FormField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var isRequired: Bool = false
    var showError: Bool = false
    var suffix: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkPrimary)
                if isRequired {
                    Text("*")
                        .font(AppFont.sectionTitle)
                        .foregroundStyle(Color.peachDustDark)
                }
            }
            
            HStack {
                TextField(placeholder, text: $text)
                    .font(AppFont.bodyLarge)
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(AppFont.bodyLarge)
                        .foregroundStyle(Color.inkSecondary.opacity(0.6))
                }
            }
            .cardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(showError ? Color.peachDustDark.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
            
            if showError {
                Text("This field is required")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.peachDustDark)
                    .padding(.leading, 4)
                    .transition(.opacity)
            }
        }
    }
}

struct DateField: View {
    let label: String
    @Binding var date: Date
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkPrimary)
                if isRequired {
                    Text("*")
                        .font(AppFont.sectionTitle)
                        .foregroundStyle(Color.peachDustDark)
                }
            }
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(AppFont.bodyLarge)
                .cardStyle()
        }
    }
}

#Preview {
    ParentBabyFormScreen(
        parentName: .constant(""),
        parentEmail: .constant(""),
        parentDOB: .constant(Date()),
        country: .constant(""),
        babyName: .constant(""),
        babyDOB: .constant(Date()),
        babyWeight: .constant(""),
        showingValidationErrors: .constant(false),
        onContinue: {},
        onBack: {}
    )
}
