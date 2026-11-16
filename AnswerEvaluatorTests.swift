import Foundation

@main
struct OfflineTests {
    static func main() {
        let affirmative: [(String, String)] = [
            ("math_variables", "I divide both sides by the mass"),
            ("math_units", "divide"),
            ("math_trig", "cosine"),
            ("math_radians", "two pi"),
            ("math_derivative", "acceleration"),
            ("math_chain", "omega"),
            ("math_integral", "time"),
            ("math_quadratic", "the discriminant"),
            ("physics_newton", "a restoring force"),
            ("physics_moment", "perpendicular"),
            ("physics_inertia", "parallel axis"),
            ("physics_energy", "impulse momentum"),
            ("ch19_linear", "zero"),
            ("ch19_angular", "moment of inertia times angular velocity"),
            ("ch19_impulse", "you integrate it"),
            ("ch19_conservation", "pivot has zero moment"),
            ("ch22_shm", "increase"),
            ("ch22_springs", "add"),
            ("ch22_ode", "characteristic"),
            ("ch22_forced", "resonance"),
            ("ch22_damping", "underdamped"),
            ("ch22_forced_damped", "steady state")
        ]
        for (id, answer) in affirmative {
            let lesson = StudyCatalog.lookup(id)!
            let result = AnswerEvaluator.evaluate(answer, for: lesson)
            precondition(result == .confirmed, "Should confirm \(id): \(answer)")
        }
        for drill in EquationDrills.topics {
            precondition(!drill.acceptedPhrases.isEmpty, "No phrases for \(drill.id)")
            precondition(AnswerEvaluator.evaluate(drill.acceptedPhrases[0], for: drill) == .confirmed,
                         "Cannot recognize own answer for \(drill.id)")
            precondition(!drill.explanation.isEmpty && !drill.remediation.isEmpty, "Missing teaching content")
        }
        let shouldNotMatch: [(String, String)] = [
            ("math_variables", "multiply by mass"),
            ("math_variables", "mass divided by force"),
            ("math_trig", "not cosine"),
            ("math_derivative", "velocity"),
            ("ch19_angular", "just moment of inertia"),
            ("ch19_angular", "omega only"),
            ("ch22_damping", "overdamped"),
            ("select_19_torque_time", "work energy"),
            ("select_22_frequency", "omega over two pi"),
            ("select_22_natural", "square root of m over k")
        ]
        for (id, answer) in shouldNotMatch {
            precondition(AnswerEvaluator.evaluate(answer, for: StudyCatalog.lookup(id)!) == .uncertain,
                         "Incorrect acceptance for \(id): \(answer)")
        }
        let commands: [(String, VoiceCommand)] = [
            ("Stop session", .stop), ("please pause", .pause), ("Repeat question", .repeatQuestion),
            ("Explain that again", .repeatLesson), ("I don't know", .showAnswer),
            ("give me an example", .example), ("slow down", .slower),
            ("please speak faster", .faster), ("skip", .skip)
        ]
        for (words, command) in commands {
            precondition(AnswerEvaluator.command(in: words) == command, "Command failed: \(words)")
        }
        precondition(AnswerEvaluator.command(in: "I think I can stop the wheel") == nil)
        precondition(AnswerEvaluator.command(in: "momentum stops changing") == nil)
        precondition(AnswerEvaluator.command(in: "the force is decreasing") == nil)
        precondition(StudyCatalog.topics(for: .exam5).count > 30)
        precondition(StudyCatalog.topics(for: .chapter19).allSatisfy { $0.chapter.contains("19") })
        precondition(StudyCatalog.topics(for: .chapter22).allSatisfy { $0.chapter.contains("22") })
        precondition(StudyCatalog.topics(for: .equationFinder).allSatisfy { $0.id.hasPrefix("select_") })
        precondition(StudyCatalog.allTopics.count == Curriculum.topics.count + EquationDrills.topics.count)
        precondition(SpeechText.readable("ω_n, ζ, ẍ, I_G and m/s²").contains("omega naught"))
        let allIDs = StudyCatalog.allTopics.map { $0.id }
        precondition(Set(allIDs).count == allIDs.count, "Duplicate lesson IDs")
        print("PASS: \(affirmative.count) core answers, \(EquationDrills.topics.count) equation drills, " +
              "\(shouldNotMatch.count) uncertain answers, \(commands.count) commands, 7 catalog checks")
    }
}
