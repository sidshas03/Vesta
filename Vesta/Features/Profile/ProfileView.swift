import SwiftUI
import Charts

// Profile screen: performance numbers, allocation donut and the plan summary.
struct ProfileView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    profileHeader
                    performanceCard
                    allocationCard
                    personalizationCard
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Palette.background)
            .navigationTitle("Profile")
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text(String((model.profile?.name ?? "V").prefix(1)))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(Theme.brandGradient, in: Circle())
            Text(model.profile?.name ?? "Vesta Investor")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.Palette.textPrimary)
            Text("Member since 2026")
                .font(.footnote)
                .foregroundStyle(Theme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Performance

    private var performanceCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Performance")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)
                HStack {
                    metric("Total value", Formatters.currency(model.portfolio.totalValue))
                    Spacer()
                    metric("All-time return",
                           Formatters.signedCurrency(model.portfolio.totalReturn),
                           color: model.portfolio.totalReturn >= 0 ? Theme.Palette.up : Theme.Palette.down)
                }
                Divider().overlay(Theme.Palette.stroke)
                HStack {
                    metric("Invested", Formatters.currency(model.portfolio.investedValue))
                    Spacer()
                    metric("Cash", Formatters.currency(model.portfolio.cash))
                    Spacer()
                    metric("Return %",
                           Formatters.signedPercent(model.portfolio.totalReturnFraction),
                           color: model.portfolio.totalReturn >= 0 ? Theme.Palette.up : Theme.Palette.down)
                }
            }
        }
    }

    // MARK: - Allocation donut

    private var allocationCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Allocation")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)

                HStack(spacing: Theme.Spacing.xl) {
                    Chart(model.portfolio.allocation) { slice in
                        SectorMark(
                            angle: .value("Value", slice.value),
                            innerRadius: .ratio(0.62),
                            angularInset: 2
                        )
                        .cornerRadius(4)
                        .foregroundStyle(color(for: slice))
                    }
                    .frame(width: 130, height: 130)

                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        ForEach(model.portfolio.allocation) { slice in
                            HStack(spacing: Theme.Spacing.sm) {
                                Circle()
                                    .fill(color(for: slice))
                                    .frame(width: 10, height: 10)
                                Text(slice.label)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.Palette.textPrimary)
                                Spacer()
                                Text(percent(of: slice))
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.Palette.textSecondary)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Personalization

    private var personalizationCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Your plan")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)

                infoRow("Risk profile", model.profile?.risk.rawValue ?? "Balanced",
                        icon: model.profile?.risk.systemImage ?? "scalemass.fill")
                Divider().overlay(Theme.Palette.stroke)
                infoRow("Monthly investing",
                        Formatters.currency(model.profile?.monthlyContribution ?? 0, maximumFractionDigits: 0),
                        icon: "arrow.triangle.2.circlepath")

                if let goals = model.profile?.goals, !goals.isEmpty {
                    Divider().overlay(Theme.Palette.stroke)
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Goals")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.Palette.textSecondary)
                        FlowChips(goals: Array(goals))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func metric(_ label: String, _ value: String, color: Color = Theme.Palette.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.Palette.textTertiary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }

    private func infoRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Palette.brandSoft)
                .frame(width: 28)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.textPrimary)
        }
    }

    private func color(for slice: AllocationSlice) -> Color {
        slice.colorIndex == 99
            ? Theme.Palette.textTertiary
            : Theme.Palette.accents[abs(slice.colorIndex) % Theme.Palette.accents.count]
    }

    private func percent(of slice: AllocationSlice) -> String {
        let total = model.portfolio.totalValue
        guard total > 0 else { return "0%" }
        return (slice.value / total).formatted(.percent.precision(.fractionLength(0...1)))
    }
}

// MARK: - Goal chips

private struct FlowChips: View {
    let goals: [InvestingGoal]

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 120), spacing: Theme.Spacing.sm)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Spacing.sm) {
            ForEach(goals) { goal in
                Pill(text: goal.rawValue, systemImage: goal.systemImage, isSelected: false)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment({
            let m = AppModel()
            m.profile = UserProfile(name: "Alex", goals: [.retirement, .buildWealth],
                                    risk: .aggressive, monthlyContribution: 250)
            return m
        }())
        .preferredColorScheme(.dark)
}
