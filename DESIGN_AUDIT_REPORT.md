# B-Fed Visual Design Audit — Complete Report

**Date:** 2026-04-05  
**Auditor:** Kimi Code CLI  
**Scope:** All 56 Swift source files across Views, DesignSystem, Services, and Models  
**Design System Reference:** `DesignTokens.swift` (colours, typography, spacing, metrics)

---

## How to read this report

- **CRITICAL** — Must fix before shipping. Breaks design system, accessibility, or dark mode.
- **IMPORTANT** — Fix soon. Degrades consistency or user experience.
- **MINOR** — Nice to have. Polish and refinement.

Each entry shows: **File → Line(s) → Issue → Fix → Effort**

---

# CRITICAL

## C1. Dark mode is completely broken
**Files:** Every view file using `.white` or `Color.black.opacity(...)`  
**Issue type:** Colour / Dark Mode  
**Current state:** `Color.white` is used ~40+ times for card backgrounds, input fields, buttons, and pills. `Color.black.opacity(0.06–0.12)` is used for borders and dividers. The design tokens define `dmBackgroundCard` (#2A2727) and `dmInkPrimary` (#F5E6DE) but they are never wired up.  
**Required fix:**
1. Replace every `Color.white` with `Color.backgroundCard`.
2. Replace every `Color.black.opacity(x)` border with a semantic border colour that adapts.
3. Make all palette colours `@Environment(\.colorScheme)` aware or use iOS 17 `Color.init(light:dark:)`.
4. Update `B_FedApp.swift` window background to use dynamic `Color.backgroundBase`.
**Estimated effort:** 1 file (`DesignTokens.swift`) + ~60 line replacements across 15 files.

## C2. Hardcoded hex colours outside the palette
**File:** `WelcomeScreen.swift` line 32, `DashboardView.swift` line 129  
**Issue type:** Colour  
**Current state:** `Color(hex: "FAFAF8")` — this value exists as `Color.backgroundBase`.  
**Required fix:** Replace with `Color.backgroundBase`.  
**Estimated effort:** 2 lines.

## C3. `.shadow()` modifier present
**File:** `LogFeedSheet.swift` line 271  
**Issue type:** Shadow / Visual Effect  
**Current state:** `.shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)` on amount buttons.  
**Required fix:** Remove `.shadow()` entirely; rely on border stroke for depth.  
**Estimated effort:** 1 line.

## C4. Gradient used in chart
**File:** `StatisticsView.swift` line 118  
**Issue type:** Gradient  
**Current state:** `.foregroundStyle(Color.peachDustDark.gradient)` on BarMark.  
**Required fix:** Replace with flat fill: `.foregroundStyle(Color.peachDustDark)`.  
**Estimated effort:** 1 line.

## C5. `.ultraThinMaterial` used
**File:** `DashboardView.swift` line 852 (inside `ReassuranceBubble`)  
**Issue type:** Visual Effect  
**Current state:** `.background(.ultraThinMaterial)` for the reassurance overlay.  
**Required fix:** Replace with solid fill: `.background(Color.backgroundCard)`.  
**Estimated effort:** 1 line.

## C6. Animations exist on dashboard and onboarding
**Files:** `MotionSystem.swift` (entire file), `DashboardView.swift` (lines 594–660, 732–737, 868, 1344), `OnboardingStepView.swift`, `ContentView.swift` line 102, `LogFeedView.swift` lines 36, 255, 282, `BottleView.swift` lines 58–89, `BabyBottleView.swift` lines 57–92, `StatisticsView.swift` line 52, `FeedingTypeScreen.swift` line 83, `BrandSelectionScreen.swift` line 93, `SupportiveMessageView.swift` line 265  
**Issue type:** Animation  
**Current state:** Dozens of `withAnimation()`, `.animation()`, `.transition()`, spring(), easeInOut calls across onboarding, dashboard, and input screens. The audit spec allows **only** native iOS keyboard animations.  
**Required fix:**
- Remove `MotionSystem.swift` entirely (or keep constants but strip all modifiers).
- Remove all `withAnimation` / `.animation` / `.transition` from `DashboardView.swift`, onboarding screens, `LogFeedView.swift`, `BottleView.swift`, `BabyBottleView.swift`, `StatisticsView.swift`.
- Remove `.spring()`, `.easeInOut()`, `.easeOut()` calls.
- `GentlePressEffect` uses `.animation(MotionCurve.interaction, value: ...)` — remove or replace with instant state change.
- Bottle wave animation — remove continuous `withAnimation(...repeatForever)` loops.
**Estimated effort:** 1 file deletion + ~35 line deletions across 10 files.

## C7. Glow/blur visual effects
**Files:** `BottleView.swift` lines 24–33 (glow), `BabyBottleView.swift` line 51 (`.blur(radius: 1)`)  
**Issue type:** Visual Effect  
**Current state:** Glow circle with repeating animation and blur on bottle highlight.  
**Required fix:** Remove glow layer and `.blur()` modifier. Use flat fills only.  
**Estimated effort:** 6 lines.

## C8. Praise/gamification copy flagged by audit
**Files:** `DashboardView.swift`, `ReassuranceEngine`, `TipEngine.swift`, `SupportiveMessageView.swift`, `MonthView.swift`, `FeedingIntelligence.swift`  
**Issue type:** Copy / Tone  
**Current state:**
- "You're doing great tonight" — DashboardView.swift:48
- "You're doing great already" — DashboardView.swift:415
- "Let's go →" — OnboardingStepView.swift:117
- "Let's log your first feed" — DashboardView.swift:407
- "Nice work" — DashboardView.swift:91
- "Perfect progress" — FeedingIntelligence.swift:103
- "Perfect" — ReassuranceEngine.swift:320
- "Perfect month — you're building a beautiful routine" — MonthView.swift:101
- "You're doing great" — FeedingIntelligence.swift:103,123 / TipEngine.swift:90 / SupportiveMessageView.swift:238
- "Keep it up" — ReassuranceEngine.swift:318 / SupportiveMessageView.swift:239
- "Well done" — ReassuranceEngine.swift:319 / SupportiveMessageView.swift:240
- "Nice one" — ReassuranceEngine.swift:316
- "Great growth happening" — ReassuranceEngine.swift:306
- "Doing great today" — FeedingIntelligence.swift:103
**Required fix:** Replace with calm, observational alternatives:
- "You're doing great tonight" → "It's quiet tonight"
- "Let's log your first feed" → "Tap to log your first feed"
- "Let's go →" → "Get started →"
- "Nice work" → "Feed logged"
- "Perfect progress" → "Today is unfolding gently"
- "Perfect month" → "A full month of feeds"
- "You're doing great" → "You're here — that matters"
- "Keep it up" → "One feed at a time"
- "Well done" → "That counts"
- "Nice one" → "Noted"
- "Great growth happening" → "Intake is changing"
- "Doing great today" → "Today is going smoothly"
**Estimated effort:** 15–20 lines across 6 files.

## C9. Clinical/medical phrasing in formula prep
**File:** `FormulaService.swift` lines 228–232, `BottlePrepGuideView.swift` line 17  
**Issue type:** Copy / Safety  
**Current state:** "Boil fresh water and cool to 70°C", "around 70°C if you want to be precise", "Seal and shake gently until dissolved". These are specific medical instructions.  
**Required fix:** Replace with observational framing that directs users to their tin:
- "Boil fresh water and cool to 70°C" → "Boil fresh water, then let it cool. Your formula tin will tell you the right temperature."
- "Seal and shake gently until dissolved" → "Mix gently until the powder has dissolved."
**Estimated effort:** 4 lines.

## C10. `.system()` font calls for icons (violates "DM Sans/Serif only")
**Files:** `ContentView.swift:107`, `OnboardingStepView.swift:65`, `WelcomeScreen.swift:216`, `FeedingTypeScreen.swift:112`, `FeedingTypeSelectionScreen.swift:70`, `BrandSelectionScreen.swift:118`, `CountryScreen.swift:33`, `SettingsView.swift:123,140`, `FormulaSelector.swift:157`, `LogFeedSheet.swift:490`  
**Issue type:** Typography  
**Current state:** SF Symbols are styled with `.font(.system(size: ..., weight: ...))`.  
**Required fix:** For SF Symbols, use `AppFont.sans(size, weight: ...)` instead of `.system(size: ...)`.  
**Estimated effort:** 10 lines.

## C11. Font sizes off the type scale
**Files:** Multiple  
**Issue type:** Typography  
**Current state:** The approved type scale is: 32, 22, 16, 15, 13, 11, 10. Violations:
- 38pt — WelcomeScreen.swift:189 (headline)
- 26pt — OnboardingStepView.swift:101 (question)
- 24pt — DashboardView.swift:181 (header), FeedHistoryView.swift:127 (empty state), GentleGuideCard.swift:53 (value)
- 20pt — LogFeedSheet.swift:70 (title), DashboardView.swift:691 (intake display)
- 18pt — FormulaDetailView.swift:54 (prep title), DashboardView.swift:365 (timer)
- 28pt — FeedConfirmationView.swift:383, BottlePrepGuideView.swift:75, StatCard.swift:268, LogFeedView.swift:184
- 96pt — LogFeedView.swift:177 (amount display)
- 17pt — OnboardingInputField.swift:216, BabyNameScreen.swift:26, etc. (text fields)
- 14pt — PrimaryButton.swift:8, OnboardingStepView.swift:118, etc. (buttons / labels)
- 12pt — OnboardingInputField.swift:213, LogFeedSheet.swift:147, etc. (input labels)
- 9pt — DashboardView.swift:346, FeedBubbleArcView.swift:45 (section labels)
- 8pt — FormulaDetailView.swift:232 (fridge indicator label)
- 7pt — FeedBubbleArcView.swift:127 (time label under bubble)
- 6pt — FeedBubbleArcView.swift:119 ("ml" inside bubble)
**Required fix:** Map every font to the nearest token or add new tokens for intentional deviations (e.g. `display: serif(38)`, `jumbo: serif(96)`). Minimum readable size should be 9–10pt.
**Estimated effort:** ~40 line changes across 18 files, plus adding 3–4 new type scale tokens.

---

# IMPORTANT

## I1. Spacing values not on the 4pt grid
**Files:** Multiple  
**Issue type:** Spacing  
**Current state:** Valid grid: 4, 8, 12, 16, 20, 24, 32, 48. Off-grid values:
- 14pt — DashboardView.swift:369 (BottleTimerCard padding)
- 18pt — DashboardView.swift:240, LogFeedSheet.swift:378, OnboardingStepView.swift:78,92,104,143, WelcomeScreen.swift:230
- 28pt — DashboardView.swift:257 (reassurance top padding)
- 34pt — WelcomeScreen.swift:231 (safe area bottom fallback)
- 58pt — FeedRow.swift:1043 (time column width)
- 60pt — FeedHistoryView.swift:75 (bottom padding)
- 62pt — FeedHistoryView.swift:176 (time group leading padding)
- 80pt — DashboardView.swift:270 (scroll bottom padding)
- 180pt — ReassuranceBubble.swift:856 (frame height)
- 58pt — `AppMetrics.inputHeight` — NOT on grid. Should be 56 or 60.
**Required fix:** Round to nearest grid value (14→12/16, 18→16/20, 28→24/32, 34→32, 58→56/60, 62→60/64, 80→80, 180→reconsider).
**Estimated effort:** ~20 line changes.

## I2. Inconsistent border opacity
**Files:** Multiple  
**Issue type:** Component Consistency  
**Current state:** `AppMetrics.borderOpacity` is `0.07`, but the app uses 0.05, 0.06, 0.07, 0.08, 0.10, 0.12, 0.15, 0.20, 0.30 across different files.
**Required fix:** Standardise on `AppMetrics.borderOpacity` (0.07) for all card borders. Use 0.15 for highlighted/tinted borders only.
**Estimated effort:** ~30 line replacements.

## I3. Section label tracking inconsistent
**File:** `LogFeedSheet.swift` line 149, `DashboardView.swift` line 348  
**Issue type:** Component Consistency  
**Current state:** Section labels use `tracking(0.3)`. Audit spec requires `0.4`.  
**Required fix:** Change all section label tracking to `0.4`.  
**Estimated effort:** 3 lines.

## I4. Primary button height inconsistent across screens
**File:** `Components.swift`, `OnboardingStepView.swift`, `WelcomeScreen.swift`, `LogFeedSheet.swift`  
**Issue type:** Component Consistency  
**Current state:**
- `PrimaryButton` modifier: 52pt height, 14pt radius
- Onboarding CTA: 54pt height, 16pt radius
- Welcome CTA: 58pt height, 16pt radius
- LogFeedSheet save: 52pt height, 14pt radius
- Settings Save Changes: uses `.borderedProminent` (system style)
**Required fix:** Standardise ALL primary CTAs to `AppMetrics.buttonHeight` (54pt) and `AppRadius.button` (14pt), or update `AppMetrics.buttonHeight` to 52pt and use it everywhere.
**Estimated effort:** 6 lines.

## I5. `ContentUnavailableView` in `LogFeedFormulaPickerSheet`
**File:** `LogFeedSheet.swift` lines 496–500  
**Issue type:** Component Consistency  
**Current state:** Uses `ContentUnavailableView` with system default styling.  
**Required fix:** Replace with custom empty state matching `EmptyHistoryView` style.  
**Estimated effort:** 1 small view, ~15 lines.

## I6. Missing accessibility labels on interactive elements
**Files:** Multiple  
**Issue type:** Accessibility  
**Current state:**
- `FeedBubbleArcView` bubbles: no accessibility labels
- `LogFeedSheet` amount buttons: no accessibility labels
- `LogFeedSheet` Toggle: empty label `Toggle("", isOn: $timerActive)` — VoiceOver reads nothing
- `ContentView` tab bar buttons: no `accessibilityLabel`
- `MonthView` `CompletionDay`: no accessibility label
- `FormulaDetailView` prep steps: no accessibility labels
**Required fix:** Add `.accessibilityLabel(...)` to all interactive elements. Change Toggle to `Toggle("Start bottle timer", isOn: $timerActive).labelsHidden()`.
**Estimated effort:** ~15 lines.

## I7. Tap targets below 44×44pt
**Files:** `LogFeedSheet.swift:186`, `DashboardView.swift:1394`, `FeedBubbleArcView.swift:51`  
**Issue type:** Accessibility  
**Current state:**
- "?" button in formula row: 24×24pt frame
- Tip dismiss "×" button: 28×28pt frame
- "see all" text in FeedBubbleArcView: no explicit frame, likely <44pt height
**Required fix:** Wrap all in `.frame(minWidth: 44, minHeight: 44)`.
**Estimated effort:** 3 lines.

## I8. Low contrast in `GuidanceBubble`
**File:** `DashboardView.swift` line 900–903  
**Issue type:** Accessibility / Colour  
**Current state:** Text is `Color.almostAquaDark.opacity(0.9)` on `Color.almostAquaDark.opacity(0.1)` background. Contrast ratio ~1.5:1.  
**Required fix:** Change background to `Color.almostAquaLight` or text to `Color.inkPrimary`.  
**Estimated effort:** 1 line.

## I9. `B_FedApp.swift` hardcoded window background
**File:** `B_FedApp.swift` lines 17–22  
**Issue type:** Colour / Dark Mode  
**Current state:** `UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0, alpha: 1.0)` — hardcoded RGB.  
**Required fix:** Derive from `Color.backgroundBase` dynamically.  
**Estimated effort:** 3 lines.

## I10. Settings Save Changes uses system `.borderedProminent`
**File:** `SettingsView.swift` line 167  
**Issue type:** Component Consistency  
**Current state:** Uses `.buttonStyle(.borderedProminent).tint(Color.inkPrimary)`.  
**Required fix:** Replace with `.primaryButton()`.  
**Estimated effort:** 1 line.

## I11. Text uses default system font instead of AppFont
**File:** `FeedHistoryView.swift` line 1039, `EditFeedView.swift`  
**Issue type:** Typography  
**Current state:** `Text(feed.startTime, style: .time)` uses system default. `Form` sections in `EditFeedView` use default fonts.  
**Required fix:** Apply `.font(AppFont.body)` to time text. For `EditFeedView`, apply AppFont to all inputs.
**Estimated effort:** 6 lines.

---

# MINOR

## M1. `OnboardingStepView` progress bar uses custom code instead of `ProgressBar` component
**File:** `OnboardingStepView.swift` lines 82–92  
**Issue type:** Component Consistency  
**Current state:** Inline progress bar (3pt, inkPrimary). `Components.swift` has a `ProgressBar` struct (4pt, multi-coloured).  
**Required fix:** Either use the `ProgressBar` component or update it to match onboarding styling.  
**Estimated effort:** 1 file.

## M2. `FormulaDetailView` uses hardcoded radius 16 instead of `AppRadius.card`
**File:** `FormulaDetailView.swift` lines 80, 118, 188  
**Issue type:** Spacing / Component  
**Current state:** `.cornerRadius(16)` instead of `AppRadius.card`.  
**Required fix:** Replace with `AppRadius.card`.  
**Estimated effort:** 3 lines.

## M3. `FeedBubbleArcView` tiny font sizes (6pt, 7pt)
**File:** `FeedBubbleArcView.swift` lines 119, 127  
**Issue type:** Typography / Accessibility  
**Current state:** 6pt and 7pt text inside bubbles and below them.  
**Required fix:** Increase to minimum 9pt or remove the "ml" sub-label inside bubbles.  
**Estimated effort:** 2 lines.

## M4. `DashboardView` reassurance uses fixed 180pt height
**File:** `DashboardView.swift` line 856  
**Issue type:** Spacing  
**Current state:** `.frame(height: 180)` on `ReassuranceBubble`.  
**Required fix:** Use `minHeight` or let it size to content.  
**Estimated effort:** 1 line.

## M5. `WelcomeScreen` arrow uses system font
**File:** `WelcomeScreen.swift` line 214  
**Issue type:** Typography  
**Current state:** `Text("→")` with `.font(.system(size: 20))`.  
**Required fix:** Use `AppFont.sans(20, weight: .medium)` or replace with `Image(systemName: "arrow.right")`.  
**Estimated effort:** 1 line.

## M6. `FormulaSelector` search bar height 40pt (off grid)
**File:** `FormulaSelector.swift` line 44  
**Issue type:** Spacing  
**Current state:** `.frame(height: 40)` for search bar.  
**Required fix:** Change to 44 or 48.  
**Estimated effort:** 1 line.

## M7. `AmountScrubber` uses 200pt max width
**File:** `LogFeedView.swift` line 199  
**Issue type:** Spacing  
**Current state:** `.frame(maxWidth: 200)` for accessibility text field.  
**Required fix:** Use 192 or 208 (grid-aligned).  
**Estimated effort:** 1 line.

## M8. `EditFeedView` uses system `Form` styling
**File:** `EditFeedView.swift`  
**Issue type:** Component Consistency  
**Current state:** Uses native `Form` which has system grey backgrounds and default section headers.  
**Required fix:** Wrap in custom-styled `VStack` with `cardStyle()` sections, or accept as exception.  
**Estimated effort:** Significant refactor (~30 lines). Consider leaving as exception.

## M9. `FeedHistoryView` swipe action uses `.tint(Color.orchidTintDark)`
**File:** `FeedHistoryView.swift` line 243  
**Issue type:** Colour  
**Current state:** Edit swipe action is tinted orchid.  
**Required fix:** Standardise on `Color.almostAquaDark` for edit actions or document the exception.  
**Estimated effort:** 1 line.

## M10. Duplicate `LiquidWithWave` and `BottleGlassShape`
**Files:** `DashboardView.swift` and `LogFeedView.swift`  
**Issue type:** Code / Component  
**Current state:** `LiquidWithWave`, `BottleGlassShape`, and `DashboardWaveShape` exist in both files.  
**Required fix:** Extract to a shared `BottleVisuals.swift` file.  
**Estimated effort:** 1 new file, ~30 lines moved.

---

# Summary Table

| Category | Count | Effort |
|----------|-------|--------|
| Colour (hardcoded hex / system white / black borders) | ~60 violations | 1 file + 60 lines |
| Typography (off-scale sizes + .system() calls) | ~45 violations | 18 files |
| Spacing (off-grid values) | ~15 violations | 10 files |
| Component (button height, border opacity, progress bar) | ~10 violations | 8 files |
| Copy (praise/gamification + medical phrasing) | ~20 violations | 6 files |
| Animation (all withAnimation / .animation / .transition) | ~35 violations | 10 files |
| Shadow / Gradient / Visual Effects | 5 violations | 4 files |
| Accessibility (missing labels, small tap targets, contrast) | ~12 violations | 8 files |
| Dark Mode (completely unimplemented) | App-wide | 15 files |

**Total estimated effort:** ~200 line changes across 25 files, plus 1 file deletion (`MotionSystem.swift`) and 1 file creation (shared bottle shapes).

**Recommended order of work:**
1. Fix dark mode tokens in `DesignTokens.swift` first (unblocks everything else).
2. Remove animations (large structural change, affects many files).
3. Replace all `.white` with `Color.backgroundCard` and standardise borders.
4. Fix copy and tone.
5. Fix typography scale and `.system()` calls.
6. Fix accessibility labels and tap targets.
7. Spacing and component polish.

---

*End of report. Awaiting confirmation before making changes.*
