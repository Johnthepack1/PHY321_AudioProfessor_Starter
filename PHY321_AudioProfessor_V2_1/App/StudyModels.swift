import Foundation

enum StudyMode: String, CaseIterable, Identifiable {
    case lecture = "Lecture"
    case practice = "Practice"
    case drive = "Drive"

    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .lecture: return "Teach continuously · no microphone"
        case .practice: return "Explain · ask · listen · coach"
        case .drive: return "Hands-free explanations and narrated solutions"
        }
    }
    var symbol: String {
        switch self {
        case .lecture: return "headphones"
        case .practice: return "mic.fill"
        case .drive: return "car.fill"
        }
    }
}

enum StudyFocus: String, CaseIterable, Identifiable {
    case exam5 = "Exam 5"
    case equationFinder = "Equation Finder"
    case chapter19 = "Chapter 19"
    case chapter22 = "Chapter 22"
    case foundations = "Math foundations"
    case all = "Full course"

    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .exam5: return "Momentum, vibration, and equation clues"
        case .equationFinder: return "Practice selecting the correct method"
        case .chapter19: return "Rigid-body impulse and momentum"
        case .chapter22: return "Mechanical vibration and differential equations"
        case .foundations: return "Algebra, calculus, and physical intuition"
        case .all: return "Every lesson and equation drill"
        }
    }
}

enum StudyCatalog {
    static let allTopics: [Lesson] = Curriculum.topics + EquationDrills.topics

    static func topics(for focus: StudyFocus) -> [Lesson] {
        switch focus {
        case .exam5:
            return Curriculum.topics.filter { $0.chapter.contains("Chapter 19") || $0.chapter.contains("Chapter 22") } + EquationDrills.topics
        case .equationFinder:
            return EquationDrills.topics
        case .chapter19:
            return Curriculum.topics.filter { $0.chapter.contains("Chapter 19") } + EquationDrills.topics.filter { $0.chapter.contains("19") }
        case .chapter22:
            return Curriculum.topics.filter { $0.chapter.contains("Chapter 22") } + EquationDrills.topics.filter { $0.chapter.contains("22") }
        case .foundations:
            return Curriculum.topics.filter { !$0.chapter.contains("Chapter 19") && !$0.chapter.contains("Chapter 22") }
        case .all:
            return allTopics
        }
    }

    static func lookup(_ id: String) -> Lesson? {
        allTopics.first(where: { $0.id == id })
    }

    static func isDrill(_ lesson: Lesson) -> Bool { lesson.id.hasPrefix("select_") }
}

struct StudySessionStatistics {
    let confirmed: Int
    let retried: Int
    let reviewTopics: Int
    let completed: Int
}
