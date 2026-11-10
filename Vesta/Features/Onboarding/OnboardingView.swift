import SwiftUI

// Multi-step onboarding that collects the user's name, goals, risk level
// and monthly contribution.
struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            header

            // Step content
            Group {
                switch vm.step {
                case .welcome: welcomeStep
                case .name: nameStep
                case .goals: goalsStep
                case .risk: riskStep
                case .contribution: contributionStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(vm.step)

            PrimaryButton(title: vm.primaryButtonTitle, isEnabled: vm.canAdvance) {
                vm.advance { profile in model.completeOnboarding(with: profile) }
            }
        }
        .padding(Theme.Spacing.xl)
        .background(backgroundGlow)
    }

    // MARK: - Header (progress + back)

    private var header: some View {
        VStack(spacing: Theme.Spacing.lg) {
            HStack {
                if vm.step != .welcome {
                    Button {
                        Haptics.tap()
                        vm.back()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(Theme.Palette.textSecondary)
                            .frame(width: 40, height: 40)
                            .background(Theme.Palette.surface, in: Circle())
                    }
                }
                Spacer()
                Text("Vesta")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.Palette.textPrimary)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }

            ProgressView(value: vm.progress)
                .tint(Theme.Palette.brand)
                .animation(.smooth, value: vm.progress)
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Spacer(minLength: Theme.Spacing.xxl)
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(Theme.brandGradient)
            Text("Welcome to Vesta")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Palette.textPrimary)
            Text("Let's set up your account. It only takes a few quick steps.")
                .font(.body)
                .foregroundStyle(Theme.Palette.textSecondary)
            Spacer()
        }
    }

    private var nameStep: some View {
        StepScaffold(title: "What should we call you?",
                     subtitle: "We'll use this to personalize your dashboard.") {
            TextField("First name", text: Binding(
                get: { vm.name },
                set: { vm.name = $0 }
            ))
            .textInputAutocapitalization(.words)
            .font(.title2.weight(.semibold))
            .padding(Theme.Spacing.lg)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Palette.stroke, lineWidth: 1)
            )
        }
    }

    private var goalsStep: some View {
        StepScaffold(title: "What are you investing for?",
                     subtitle: "Pick everything that applies.") {
            FlowGrid(InvestingGoal.allCases) { goal in
                Button {
                    vm.toggleGoal(goal)
                } label: {
                    Pill(text: goal.rawValue, systemImage: goal.systemImage,
                         isSelected: vm.goals.contains(goal))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var riskStep: some View {
        StepScaffold(title: "How do you feel about risk?",
                     subtitle: "This shapes the mix we suggest for you.") {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(RiskLevel.allCases) { level in
                    Button {
                        Haptics.selection()
                        withAnimation(.smooth) { vm.risk = level }
                    } label: {
                        SelectableRow(
                            title: level.rawValue,
                            subtitle: level.detail,
                            systemImage: level.systemImage,
                            isSelected: vm.risk == level
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var contributionStep: some View {
        StepScaffold(title: "Set up recurring investing",
                     subtitle: "Automate your way to your goals. You can change this anytime.") {
            VStack(spacing: Theme.Spacing.xl) {
                Text(Formatters.currency(vm.monthlyContribution, maximumFractionDigits: 0))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.brandGradient)
                    .contentTransition(.numericText(value: vm.monthlyContribution))
                    .animation(.smooth, value: vm.monthlyContribution)
                Text("per month")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)

                Slider(value: Binding(
                    get: { vm.monthlyContribution },
                    set: { vm.monthlyContribution = ($0 / 25).rounded() * 25 }
                ), in: 0...1000, step: 25)
                .tint(Theme.Palette.brand)

                Text("Projected in 10 years at ~8%/yr: \(Formatters.compactCurrency(projectedValue))")
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xl)
        }
    }

    // Future value of the monthly contribution (annuity formula).
    private var projectedValue: Double {
        let monthlyRate = 0.08 / 12
        let months = 120.0
        guard vm.monthlyContribution > 0 else { return 0 }
        return vm.monthlyContribution * ((pow(1 + monthlyRate, months) - 1) / monthlyRate)
    }

    private var backgroundGlow: some View {
        Theme.Palette.background
            .overlay(
                Circle()
                    .fill(Theme.Palette.brand.opacity(0.22))
                    .frame(width: 320, height: 320)
                    .blur(radius: 120)
                    .offset(x: 120, y: -260)
            )
            .ignoresSafeArea()
    }
}

// MARK: - Reusable step pieces

private struct StepScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Palette.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
            content
            Spacer(minLength: 0)
        }
        .padding(.top, Theme.Spacing.lg)
    }
}

private struct SelectableRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(isSelected ? .white : Theme.Palette.brandSoft)
                .frame(width: 44, height: 44)
                .background(
                    isSelected ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.Palette.surfaceElevated),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Theme.Palette.brand : Theme.Palette.textTertiary)
                .font(.title3)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .stroke(isSelected ? Theme.Palette.brand : Theme.Palette.stroke,
                        lineWidth: isSelected ? 1.5 : 1)
        )
    }
}

// Wrapping grid used for the goal chips.
private struct FlowGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    @ViewBuilder let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 130), spacing: Theme.Spacing.md)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.md) {
            ForEach(data) { content($0) }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppModel())
        .preferredColorScheme(.dark)
}
