import SwiftUI
import Observation

@Observable
@MainActor
final class OnboardingViewModel {

    enum Step: Int, CaseIterable {
        case welcome, name, goals, risk, contribution

        var isLast: Bool { self == Step.allCases.last }
    }

    var step: Step = .welcome

    // Collected answers
    var name: String = ""
    var goals: Set<InvestingGoal> = []
    var risk: RiskLevel = .balanced
    var monthlyContribution: Double = 150

    var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    // Can the user move on from the current step?
    var canAdvance: Bool {
        switch step {
        case .welcome: return true
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .goals: return !goals.isEmpty
        case .risk: return true
        case .contribution: return true
        }
    }

    var primaryButtonTitle: String {
        step.isLast ? "Start investing" : "Continue"
    }

    func toggleGoal(_ goal: InvestingGoal) {
        Haptics.selection()
        if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
    }

    func advance(completion: (UserProfile) -> Void) {
        guard canAdvance else { return }
        if step.isLast {
            let profile = UserProfile(
                name: name.trimmingCharacters(in: .whitespaces),
                goals: goals,
                risk: risk,
                monthlyContribution: monthlyContribution
            )
            completion(profile)
        } else if let next = Step(rawValue: step.rawValue + 1) {
            withAnimation(.smooth) { step = next }
        }
    }

    func back() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        withAnimation(.smooth) { step = previous }
    }
}
