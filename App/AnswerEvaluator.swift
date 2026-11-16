import Foundation

enum AnswerEvaluation: Equatable {
    case confirmed
    case uncertain
}

enum VoiceCommand: String, Equatable {
    case stop, pause, repeatQuestion, repeatLesson, showAnswer, example, slower, faster, skip
}

/// A transparent, conservative offline rule checker—not an AI grader.
/// It should never count an uncertain transcription as a proven wrong answer.
enum AnswerEvaluator {
    static func normalized(_ input: String) -> String {
        input.lowercased()
            .replacingOccurrences(of: "don’t", with: "do not")
            .replacingOccurrences(of: "don't", with: "do not")
            .replacingOccurrences(of: "isn't", with: "is not")
            .replacingOccurrences(of: "can't", with: "can not")
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    private static func containsSupportedPhrase(_ source: String, phrase: String) -> Bool {
        let words = source.split(separator: " ").map(String.init)
        let phraseWords = normalized(phrase).split(separator: " ").map(String.init)
        guard !phraseWords.isEmpty && phraseWords.count <= words.count else { return false }
        for index in 0...(words.count - phraseWords.count) {
            guard Array(words[index..<(index + phraseWords.count)]) == phraseWords else { continue }
            let context = words[max(index - 3, 0)..<index]
            let prior = Array(context)
            let recent = prior.suffix(2)
            if prior.last == "not" || prior.last == "never" || prior.last == "without" ||
                Array(recent) == ["do", "not"] || Array(recent) == ["is", "not"] ||
                Array(recent) == ["not", "use"] || Array(recent) == ["not", "by"] {
                continue
            }
            return true
        }
        return false
    }

    private static func any(_ text: String, _ phrases: [String]) -> Bool {
        phrases.contains { containsSupportedPhrase(text, phrase: $0) }
    }

    static func command(in input: String) -> VoiceCommand? {
        var text = normalized(input)
        if text.hasPrefix("please ") { text = String(text.dropFirst(7)) }
        if text.hasSuffix(" please") { text = String(text.dropLast(7)) }
        switch text {
        case "stop", "stop session", "end session", "turn off", "end lesson": return .stop
        case "pause", "hold on", "wait a second", "pause lesson": return .pause
        case "repeat", "again", "repeat question", "say that again", "what was the question": return .repeatQuestion
        case "repeat lesson", "start lesson over", "explain that again": return .repeatLesson
        case "i do not know", "do not know", "not sure", "i am not sure", "no idea", "show answer", "tell me the answer", "show me the answer": return .showAnswer
        case "give me an example", "example", "another example", "explain more", "give an example": return .example
        case "slower", "slow down", "speak slower": return .slower
        case "faster", "speed up", "speak faster": return .faster
        case "skip", "next", "next question", "skip this": return .skip
        default: return nil
        }
    }

    static func evaluate(_ answer: String, for lesson: Lesson) -> AnswerEvaluation {
        let text = normalized(answer)
        guard !text.isEmpty else { return .uncertain }

        // All inner concept groups must match at least one affirmative synonym.
        let groups: [[String]]
        switch lesson.id {
        case "math_variables":
            groups = [["divide by mass", "divide by the mass", "divide both sides by mass",
                       "divide both sides by the mass", "divide it by mass", "dividing by mass",
                       "force over mass", "force divided by mass", "force divided by the mass"]]
        case "math_units": groups = [["divide", "dividing", "division", "over"]]
        case "math_trig": groups = [["cosine", "cos"]]
        case "math_radians": groups = [["two pi", "2 pi", "two times pi", "6 point 28", "six point two eight"]]
        case "math_derivative": groups = [["acceleration", "accelerating"]]
        case "math_chain": groups = [["omega", "angular frequency"]]
        case "math_integral": groups = [["time", "seconds", "with respect to t"]]
        case "math_quadratic": groups = [["discriminant", "b squared minus four a c", "b 2 minus 4 a c"]]
        case "physics_newton": groups = [["opposite", "restoring", "restores", "toward equilibrium", "back to equilibrium", "against displacement", "opposes"]]
        case "physics_moment": groups = [["perpendicular", "shortest distance", "lever arm"]]
        case "physics_inertia": groups = [["parallel axis", "parallel axes"]]
        case "physics_energy": groups = [["impulse", "impulse momentum", "momentum method"]]
        case "ch19_linear": groups = [["zero", "none", "no linear momentum"]]
        case "ch19_angular": groups = [["moment of inertia", "mass moment of inertia", "inertia", "i g"], ["angular velocity", "omega", "angular speed"]]
        case "ch19_impulse": groups = [["integrate", "integration", "integral", "area under"]]
        case "ch19_conservation":
            groups = [["pivot", "hinge", "pin", "pinned", "axis"], ["zero moment", "no moment", "no torque", "zero lever arm", "no lever arm", "moment is zero"]]
        case "ch22_shm": groups = [["increase", "increases", "higher", "faster", "goes up", "rises"]]
        case "ch22_springs": groups = [["add", "sum", "add stiffness", "stiffnesses add", "directly"]]
        case "ch22_ode": groups = [["characteristic", "auxiliary"]]
        case "ch22_forced": groups = [["resonance", "resonant"]]
        case "ch22_damping": groups = [["underdamped", "under damped", "lightly damped"]]
        case "ch22_forced_damped": groups = [["steady", "steady state", "particular", "forced response"]]
        default: groups = [lesson.acceptedPhrases]
        }
        return groups.allSatisfy { any(text, $0) } ? .confirmed : .uncertain
    }
}
